"""Per-day driver — parses DayN_*/SLIDE_SOURCE.md §10 blueprint + emits out/DayN.pptx.

The §10 "Slide blueprint" markdown IS the declarative slide list (single source of
truth). This driver walks every `#### Slide D{N}-S### — label` block, reads its
Format / Title / Body / Image / Notes fields, maps the G01-G12 format tag to an
L1-L8 layout, and renders. Screenshots resolve from slides/screenshots/dayN/;
missing ones render as red-dashed placeholders (handled in templates).

Usage:
    cd slides
    python build_day.py 1   # -> out/Day1.pptx
"""

import json
import os
import re
import sys
from pathlib import Path

import theme
import templates as tpl
import syntax_table
from pptx import Presentation

DAY_FOLDERS = {
    1: "Day1_Pong_Game",
    2: "Day2_Maze_Game",
    3: "Day3_BaseDef_Game",
    4: "Day4_Fighter_Game",
    5: "Day5_Racing_Game",
}

REPO = Path(__file__).parent.parent
SHOTS = Path(__file__).parent / "screenshots"

# Bridge: the §10 blueprint Image fields use ad-hoc `d{N}_*` names; the LOCKED
# SCREENSHOTS_CAPTURE_GUIDE.md (what the user actually captures by) uses WalkA1 /
# D1C1a / D1Beat1Step1 names. Until the blueprint is reconciled to the guide,
# map blueprint basenames -> guide basenames here. Walk shots live in shared/.
ALIASES = {
    # Day 1 walks (shared across days)
    "d1_walkA_step1.png": "WalkA1.png", "d1_walkA_step2.png": "WalkA2.png",
    "d1_walkA_step3.png": "WalkA3.png", "d1_walkA_step4.png": "WalkA4.png",
    "d1_walkA_step5.png": "WalkA5.png",
    "d1_walkB_step1.png": "WalkB1.png", "d1_walkB_step2.png": "WalkB2.png",
    "d1_walkB_step3.png": "WalkB3.png",
    "d1_walkC_step1.png": "WalkC1.png", "d1_walkC_step2.png": "WalkC2.png",
    "d1_walkC_step3.png": "WalkC3.png", "d1_walkC_step4.png": "WalkC4.png",
    "d1_walkD_step1.png": "WalkD1.png", "d1_walkD_step3.png": "WalkD3.png",
    "d1_walkD_step4.png": "WalkD4.png",
    # Day 1 per-task #@todo shots (one guide file serves both where+todo slides)
    "d1_chunk1a_hole.png": "D1C1a.png", "d1_chunk1a_todo.png": "D1C1a.png",
    "d1_chunk1b_where.png": "D1C1b.png", "d1_chunk1b_todo.png": "D1C1b.png",
    "d1_chunk6a_where.png": "D1C6a.png", "d1_chunk6a_todo.png": "D1C6a.png",
    "d1_chunk6b_where.png": "D1C6b.png", "d1_chunk6b_todo.png": "D1C6b.png",
    "d1_chunk2_todo.png": "D1C2.png",
    "d1_chunk4_where.png": "D1C4.png", "d1_chunk4_todo.png": "D1C4.png",
    "d1_chunk3_todo.png": "D1C3.png",
    "d1_chunk5_where.png": "D1C5.png", "d1_chunk5_todo.png": "D1C5.png",
    # Day 1 historical image
    "d1_pong_history.png": "D1Pong1.png",
}

SLIDE_HEADER = re.compile(r"^####\s+Slide\s+D\d+-S(\S+)\s+—\s+(.*)$")
SUBSECTION = re.compile(r"^###\s+")
# Field name = any text up to the FIRST colon (so labels with commas/parens like
# "Body LHS (board example, big monospace centred in left half):" still parse).
FIELD = re.compile(r"^-\s+([A-Za-z][^:]*?):\s?(.*)$")
GTAG = re.compile(r"\b(G\d{2})\b")
# Match a `....png` token inside backticks WITHOUT requiring a closing backtick
# right after — some blueprints write `D4C1.png -- not done --` (marker inside the
# backticks), and the old strict form silently failed to find the screenshot.
PNG = re.compile(r"`([\w./\-]+\.png)")


# ------------------------------------------------------------
#  Parse the blueprint into a list of slide dicts
# ------------------------------------------------------------

def parse_blueprint(md_text):
    lines = md_text.splitlines()
    slides = []
    i = 0
    n = len(lines)
    while i < n:
        m = SLIDE_HEADER.match(lines[i])
        if not m:
            i += 1
            continue
        sid, label = m.group(1), m.group(2).strip()
        # collect block body until next slide header or subsection heading
        block = []
        i += 1
        while i < n and not SLIDE_HEADER.match(lines[i]) and not SUBSECTION.match(lines[i]):
            block.append(lines[i])
            i += 1
        slides.append({"id": sid, "label": label, "fields": _parse_fields(block)})
    return slides


def _parse_fields(block):
    """Group block lines into named fields. Body/Caption-ish names merge into one
    key. Lines inside ``` fences never count as field markers."""
    fields = {}
    current = None
    in_code = False
    for line in block:
        if line.strip().startswith("```"):
            in_code = not in_code
            if current:
                fields[current].append(line)
            continue
        m = FIELD.match(line) if not in_code else None
        if m:
            name = m.group(1).strip()
            key = _norm_field(name)
            current = key
            fields.setdefault(key, [])
            if m.group(2).strip():
                fields[key].append(m.group(2))
        elif current is not None:
            fields[current].append(line)
    return fields


def _norm_field(name):
    low = name.lower()
    if low.startswith("body lhs"):
        return "BodyLHS"
    if low.startswith("body rhs"):
        return "BodyRHS"
    if low.startswith("body"):
        return "Body"
    if low.startswith("caption"):
        return "Caption"
    if low.startswith("title"):
        return "Title"
    if low.startswith("subtitle"):
        return "Subtitle"
    if low.startswith("syntax"):
        return "Syntax"
    if low.startswith("format"):
        return "Format"
    if low.startswith("image"):
        return "Image"
    if low.startswith("notes"):
        return "Notes"
    return name


# ------------------------------------------------------------
#  Field helpers
# ------------------------------------------------------------

def _first(fields, key, default=""):
    vals = fields.get(key)
    return vals[0].strip() if vals else default


def _clean(text):
    """Strip wrapping quotes / bold markers from a body string."""
    t = text.strip()
    t = re.sub(r"^[\"'](.*)[\"']$", r"\1", t)
    return t


def _title(fields):
    return _clean(_first(fields, "Title", ""))


def _gtag(fields):
    fmt = _first(fields, "Format", "")
    m = GTAG.search(fmt)
    return m.group(1) if m else "G04"


def _bullets(fields):
    """Pull bullet items from the Body field (lines like `  - "..."`)."""
    out = []
    for line in fields.get("Body", []):
        m = re.match(r"^\s*-\s+(.*)$", line)
        if m:
            item = _clean(m.group(1))
            if item:
                out.append(item)
    return out


def _is_none(text):
    return text.strip().lower().startswith("none")


def _paragraph(fields):
    """Body as a single prose blob (no bullets, no code, no 'none' placeholder)."""
    chunks = []
    for line in fields.get("Body", []):
        s = line.strip()
        if not s or s.startswith("```") or s.startswith("-") or _is_none(s):
            continue
        chunks.append(_clean(s))
    return " ".join(chunks)


def _code(fields):
    """Concatenate the first fenced code block found in Body."""
    out, in_code = [], False
    for line in fields.get("Body", []):
        if line.strip().startswith("```"):
            if in_code:
                break
            in_code = True
            continue
        if in_code:
            out.append(line)
    return "\n".join(out)


def _syntax_lhs(fields):
    """Build LHS syntax panel from 'Syntax:' field (comma-separated keys from syntax_table).
    Falls back to _code_lhs() if no Syntax field present."""
    raw = _first(fields, "Syntax", "")
    if not raw:
        return _code_lhs(fields)
    keys = [k.strip() for k in raw.split(",") if k.strip()]
    snippets = [syntax_table.SYNTAX[k] for k in keys if k in syntax_table.SYNTAX]
    return "\n\n".join(snippets)


def _code_lhs(fields):
    """Concatenate the first fenced code block found in BodyLHS."""
    out, in_code = [], False
    for line in fields.get("BodyLHS", []):
        if line.strip().startswith("```"):
            if in_code:
                break
            in_code = True
            continue
        if in_code:
            out.append(line)
    return "\n".join(out)


def _code_rhs(fields):
    """Concatenate the first fenced code block found in BodyRHS."""
    out, in_code = [], False
    for line in fields.get("BodyRHS", []):
        if line.strip().startswith("```"):
            if in_code:
                break
            in_code = True
            continue
        if in_code:
            out.append(line)
    return "\n".join(out)


def _image_path(fields, day):
    """Resolve a screenshot to an on-disk path (or a best-guess path that will
    render as a placeholder). Applies the guide-name ALIASES and searches the
    per-day folder then shared/."""
    blob = " ".join(fields.get("Image", []) + fields.get("Body", []))
    if "Image" in fields and _is_none(_first(fields, "Image")) and not PNG.search(blob):
        return None
    m = PNG.search(blob)
    if not m:
        return None
    name = Path(m.group(1)).name
    guide = ALIASES.get(name, name)
    dirs = [SHOTS / f"day{day}", SHOTS / "shared"]
    for cand in (name, guide):
        for d in dirs:
            p = d / cand
            if p.exists():
                return p
    # nothing on disk yet -> return the guide-named path so the placeholder
    # box shows the file the user should capture
    return dirs[0] / guide


def _caption(fields):
    cap = _first(fields, "Caption", "")
    if cap:
        return _clean(cap)
    return _paragraph(fields)


# ------------------------------------------------------------
#  G01-G12 -> L1-L8 dispatch
# ------------------------------------------------------------

_auto_fixes = []  # populated by render_slide; printed at end of main()


def render_slide(prs, slide, day, page, overlays=None):
    fields = slide["fields"]
    g = _gtag(fields)
    title = _title(fields) or slide["label"]
    bullets = _bullets(fields)
    code = _code(fields)
    img = _image_path(fields, day)
    label = slide["id"]

    if g == "G01":  # Day Title
        tpl.l1_title(prs, day=day, page=page, heading=title,
                     subtitle=_first(fields, "Subtitle") or (bullets[0] if bullets else None))
    elif g in ("G02", "G05", "G08"):  # Timeline/Closer, Build Narrative, Asset Card
        if bullets:
            tpl.l2_body(prs, day=day, page=page, heading=title, bullets=bullets)
        else:
            tpl.l2_body(prs, day=day, page=page, heading=title, paragraph=_paragraph(fields))
    elif g == "G03":  # GDScript vs Python — LHS=Python, RHS=GDScript
        tpl.l3_side_by_side(prs, day=day, page=page, heading=title,
                            left_label="Python", left_code=_code_lhs(fields),
                            right_label="GDScript", right_code=_code_rhs(fields))
    elif g == "G04":  # Headline / Divider — bullets => body, else title+subtitle
        if bullets:
            tpl.l2_body(prs, day=day, page=page, heading=title, bullets=bullets)
        else:
            tpl.l1_title(prs, day=day, page=page, heading=title,
                         subtitle=_first(fields, "Subtitle") or _paragraph(fields) or None)
    elif g in ("G06", "G10"):  # Scene Tree, Board Example -> code block
        if code:
            tpl.l6_code(prs, day=day, page=page, heading=title, code=code, caption=None)
        elif img:
            # No code but has image — auto-fix to screenshot slide, suppress instruction leak
            _auto_fixes.append(f"S{label}: G10 no code + image → G12 (screenshot). Check slide source.")
            tpl.l7_step(prs, day=day, page=page, screenshot=img, caption=title)
        else:
            # No code, no image — render body as text, no code box
            _auto_fixes.append(f"S{label}: G10 no code, no image → L2 body. Check slide source.")
            tpl.l2_body(prs, day=day, page=page, heading=title,
                        bullets=bullets or None,
                        paragraph=None if bullets else _paragraph(fields) or None)
    elif g == "G07":  # Table -> render rows as bullets (md prose tables vary)
        body = bullets or [_paragraph(fields)]
        tpl.l2_body(prs, day=day, page=page, heading=title, bullets=body)
    elif g == "G09":  # Concept + Task (Example + TODO side-by-side) -> L8 Action
        tpl.l8_action(prs, day=day, page=page,
                      prose=_caption(fields) or title,
                      lhs_code=code or "",
                      rhs_screenshot=img,
                      overlays=overlays)
    elif g == "G13":  # TODO slide — two-panel (SYNTAX | WRITE THIS)
        tpl.l9_todo(prs, day=day, page=page,
                    todo_label=title,
                    lhs_code=_syntax_lhs(fields),
                    rhs_code=_code_rhs(fields))
    elif g == "G14":  # Pre-TODO context slide
        tpl.l10_pretodo(prs, day=day, page=page,
                        heading=title,
                        code=code,
                        bullets=bullets,
                        paragraph=_paragraph(fields))
    elif g == "G11":  # Code Screenshot -> step shot w/ red overlay, no badge
        tpl.l7_step(prs, day=day, page=page, screenshot=img,
                    caption=_paragraph(fields) or title, red_overlay=True,
                    overlays=overlays)
    elif g == "G12":  # Screenshot + Caption
        tpl.l7_step(prs, day=day, page=page, screenshot=img,
                    caption=_paragraph(fields) or title)
    else:  # fallback
        tpl.l2_body(prs, day=day, page=page, heading=title,
                    bullets=bullets or None, paragraph=None if bullets else _paragraph(fields))


_GUIDE_ENTRY = re.compile(r"^\*\*`([\w.\-]+\.png)`\*\*")


def parse_not_done(guide_text):
    """Read SCREENSHOTS_CAPTURE_GUIDE.md and return the set of screenshot
    filenames marked `--not done--` (intentionally skipped — guide rule)."""
    not_done = set()
    last = None
    for line in guide_text.splitlines():
        m = _GUIDE_ENTRY.match(line.strip())
        if m:
            last = m.group(1)
        elif line.strip() == "--not done--" and last:
            not_done.add(last)
    return not_done


def _resolved_guide_name(slide, day):
    """Guide-canonical basename for this slide's screenshot, or None."""
    p = _image_path(slide["fields"], day)
    return p.name if p else None


# Formats whose whole point is the screenshot. If one of these declares a shot
# that was never captured (file absent OR marked `-- not done --` inline in the
# blueprint), the slide is dropped — the deck must match the real captures
# one-for-one (user rule 2026-06-11: captured files are the supreme authority).
IMG_FORMATS = {"G09", "G11", "G12"}


def _img_status(fields, day):
    """Classify a slide's screenshot by what is ACTUALLY ON DISK (captured files
    are the supreme authority — user 2026-06-11): 'none' (no png declared — text
    slide), 'ok' (declared + file present), or 'missing' (declared but absent).

    Stale inline `-- not done --` markers in the blueprint are deliberately
    ignored: a blueprint may mark a shot not-done that was captured afterward.
    Existence on disk wins both ways."""
    blob = " ".join(fields.get("Image", []) + fields.get("Body", []))
    if not PNG.search(blob):
        return "none"
    p = _image_path(fields, day)
    return "ok" if (p and p.exists()) else "missing"


def main():
    if len(sys.argv) != 2:
        print("Usage: python build_day.py <day_number 1-5>")
        sys.exit(1)
    day = int(sys.argv[1])
    folder = DAY_FOLDERS.get(day)
    if not folder:
        print(f"Unknown day: {day}")
        sys.exit(1)

    # SLIDE_SRC env overrides the source blueprint (used by the Creative-Heavy
    # build to point at CreativeCamp/DayN_*_Creative/SLIDE_SOURCE.md without
    # disturbing the code-heavy DAY_FOLDERS mapping).
    env_src = os.environ.get("SLIDE_SRC")
    src = Path(env_src) if env_src else REPO / folder / "SLIDE_SOURCE.md"
    if not src.exists():
        print(f"No SLIDE_SOURCE.md for day {day}: {src}")
        sys.exit(1)

    guide = REPO / "SCREENSHOTS_CAPTURE_GUIDE.md"
    not_done = parse_not_done(guide.read_text(encoding="utf-8")) if guide.exists() else set()

    # restored hand-positioned red overlays, keyed by slide-ID (from extract_overlays.py)
    ov_path = Path(__file__).parent / "out" / f"Day{day}.overlays.json"
    overlays_map = json.loads(ov_path.read_text(encoding="utf-8")) if ov_path.exists() else {}

    slides = parse_blueprint(src.read_text(encoding="utf-8"))
    if not slides:
        print(f"No §10 slide blueprint found in {src}")
        sys.exit(1)

    prs = Presentation()
    prs.slide_width = theme.SLIDE_WIDTH
    prs.slide_height = theme.SLIDE_HEIGHT

    errors = []
    skipped = []
    page = 0
    for slide in slides:
        # Guide is SoT: a slide whose screenshot is marked --not done-- is omitted
        # entirely (no placeholder), so slide count == real captures.
        gname = _resolved_guide_name(slide, day)
        if gname and gname in not_done:
            skipped.append((slide["id"], gname))
            continue
        # Image-format slide whose declared screenshot was never captured -> drop
        # entirely (no placeholder), so slide count == real captures.
        if _gtag(slide["fields"]) in IMG_FORMATS and _img_status(slide["fields"], day) == "missing":
            skipped.append((slide["id"], gname or "(missing shot)"))
            continue
        page += 1
        try:
            render_slide(prs, slide, day, page, overlays=overlays_map.get(slide["id"]))
        except Exception as e:  # never let one slide kill the whole build
            errors.append((slide["id"], repr(e)))
            tpl.l2_body(prs, day=day, page=page,
                        heading=f"[render error] S{slide['id']}",
                        paragraph=repr(e))

    out_dir = Path(__file__).parent / "out"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / (os.environ.get("SLIDES_OUT") or f"Day{day}.pptx")
    prs.save(str(out_path))
    print(f"Wrote {out_path} — {page} slides ({len(skipped)} skipped via --not done--).")
    if skipped:
        for sid, gn in skipped:
            print(f"  skipped S{sid} ({gn})")
    if _auto_fixes:
        print(f"{len(_auto_fixes)} auto-fix(es) applied (instruction leak prevented):")
        for msg in _auto_fixes:
            print(f"  {msg}")
    if errors:
        print(f"{len(errors)} slide(s) hit render errors:")
        for sid, err in errors:
            print(f"  S{sid}: {err}")


if __name__ == "__main__":
    main()
