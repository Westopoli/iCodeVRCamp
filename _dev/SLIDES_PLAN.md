# Slide Deck Build Plan

Canonical plan for the iCode camp slide-deck pipeline. Future chats start here.

## Stack

- **Authoring**: `python-pptx` (Python). One module per slide format, one driver per day.
- **Output**: one `.pptx` per day, 16:9 (default 13.333" × 7.5" / 1920×1080 effective). Embedded media. Static (no transitions).
- **Code rendering**: NOT rendered by python-pptx. All "code on a slide" is a Godot script-editor screenshot taken by the user. A red rectangle / ellipse shape is dropped onto the slide by the template — the user drags + resizes it in PowerPoint to surround the relevant lines.
- **Brand**: **red / black / grey, sleek minimalist** (LOCKED 2026-06-08 — see § Brand below). Overrides the earlier purple→magenta gradient sampled from `iCodeScreenshots/`.

## Directory layout

```
iCode/
├─ SLIDES_PLAN.md             ← this file
├─ SLIDES_FORMATS.md          ← catalog of slide formats + counts
├─ slides/
│  ├─ README.md
│  ├─ theme.py                ← fonts, colors, sizes, positions (single source of truth)
│  ├─ templates.py            ← one function per slide format (F01..FNN)
│  ├─ master.py               ← header/footer/logo helpers used by every template
│  ├─ build_day.py            ← driver: reads dayN.slides, emits dayN.pptx
│  ├─ assets/
│  │   ├─ logos/              ← iCode logos (user-provided)
│  │   ├─ fonts/              ← embedded brand fonts (optional)
│  │   └─ icons/              ← concept icons (variable/list/etc.)
│  ├─ screenshots/
│  │   ├─ day1/               ← user drops png files here per manifest
│  │   ├─ day2/
│  │   ├─ day3/
│  │   ├─ day4/
│  │   └─ day5/
│  └─ out/                    ← built .pptx files (gitignored)
├─ DayN_*/
│  ├─ SLIDES.py               ← per-day declarative slide list (rows of (format, content, screenshot))
│  └─ SCREENSHOTS.md          ← per-day capture manifest (ordered, file:caption list)
```

## Phase order

1. **Brand capture (USER)** — provide:
   - iCode logo (PNG + SVG, light + dark).
   - 2-3 representative iCode PPTX decks (for fonts/colors/title-bar/footer).
   - Confirm aspect 16:9 1920×1080.
2. **Format catalog (AI)** — `SLIDES_FORMATS.md`. List every slide TYPE found in `Day{1..4}_*/SLIDE_SOURCE.md` plus expected D5 additions. Frequency per day + total. Locked before any python written.
3. **Sample deck (AI)** — `slides/templates.py` + driver. Generate `SAMPLE_DECK.pptx`: one slide per format, placeholder text + placeholder screenshot box + red highlight shape on relevant formats. User reviews.
4. **Iterate templates (LOOP)** — user critiques sample deck. AI fixes `templates.py` only. Re-run, re-review. Lock when user accepts.
5. **Screenshot manifests (AI)** — per day: emit `DayN_*/SCREENSHOTS.md`. Each row = `filename | format | what to capture | what to highlight`. Filename convention: `dN_NN_short-desc.png` (e.g. `d2_07_open-project-dialog.png`).
6. **Capture (USER)** — user takes screenshots per manifest, drops them in `slides/screenshots/dayN/`. Missing = visible placeholder in build.
7. **Slide-list authoring (AI)** — per day: emit `DayN_*/SLIDES.py`. One declarative row per slide. Only file rewritten when content changes.
8. **Mass build (AI)** — `python build_day.py 1` → `slides/out/Day1.pptx`. Repeat for 2-5.

## Hard rules

- **Templates lock first.** No content-pass until user approves sample deck. Cuts rework from 100s of slides to 1 per format.
- **Screenshot filenames are declared up-front** in `SCREENSHOTS.md`. User captures by manifest, AI never invents filenames at slide-build time.
- **Red highlight shape is template-injected, user-positioned.** Templates that mark a code region drop a red rectangle/ellipse at a default size + position. User drags + resizes once in PowerPoint per slide. Cannot pre-position from python-pptx without knowing the screenshot's pixel coords.
- **One source of truth per concept.** `theme.py` for design tokens. `templates.py` for layout functions. `DayN/SLIDES.py` for content. Never inline values in driver.
- **No drift inside templates.** A typo in a code-block style fix = edit `templates.py`, rebuild all days. Never hand-edit `.pptx`.
- **Build script is reproducible.** Running `build_day.py` on a clean machine + the repo + screenshots should produce identical `.pptx`. No manual PowerPoint steps in the build path. (Red highlight repositioning is the one explicit user manual step, done post-build, saved back into the .pptx by the user.)

## Brand (LOCKED 2026-06-08)

Red / black / grey. Sleek, modern, minimalist. Single warm-red accent on a neutral base. No gradients, no per-day hues, no decorative blobs/sun motifs. Tokens live in `slides/theme.py` (single source of truth).

| Token | Hex | Use |
|---|---|---|
| `ICODE_RED` | `#E53A2C` | Sole accent — "Day N" header label, timeline today-marker, key-term highlights, L8 code overlay. Drawn from the logo's red end. |
| `BAR_BLACK` / `HEADER_BG` | `#111111` | Top header bar; headings on white. |
| `GREY_DARK` | `#2B2B2B` | Table-header fills, dark panels. |
| `GREY_MID` | `#8A8A8A` | Captions, rules, page numbers, inactive timeline boxes. |
| `GREY_LIGHT` | `#F2F2F2` | Callout / L8 prose-box backgrounds. |
| `BG_WHITE` | `#FFFFFF` | Slide background. |
| `TEXT_BLACK` | `#1A1A1A` | Body text. |

- **Master frame**: thin black bar across the top. iCode logo + wordmark + tagline top-left (white on black). Red "DAY N" label top-right. Page number bottom-right (grey). Applied by `slides/master.py::apply_master`.
- **Per-day differentiation**: the "Day N" red label ONLY. No per-day color. Same frame every day.
- **Logo**: `icode_logo_red.png` (orange→red gradient mark) sits on the black bar. A white-on-transparent variant would read marginally cleaner — still pending from user, not blocking.
- Red hex is tunable when a raw brand pack lands; `#E53A2C` is sampled from the logo, not guessed from gradient art.

## Red-overlay round-trip (preserve hand-positioned boxes, 2026-06-08)

Code-screenshot slides ship a red overlay box (no fill, 4pt red outline) the user drags + resizes in PowerPoint to surround the kid `#@todo` lines. A full rebuild redraws everything, so that manual work must be preserved out-of-band:

- **`slides/extract_overlays.py <day> [deck.pptx]`** — reads a hand-edited deck, finds every red overlay box, matches each to its blueprint slide-ID (by embedded-screenshot hash, with title/caption as tiebreak), and writes **`slides/out/DayN.overlays.json`** (`{slide_id: [{left,top,width,height}, …]}`, EMU).
- **`build_day.py`** auto-loads `DayN.overlays.json` and re-places those boxes at their exact saved geometry (instead of the default centred box) on the matching slide-ID. Slides with no saved entry get the default box.
- **Workflow:** build → user positions boxes in PowerPoint, saves, closes → `extract_overlays.py` → next build restores them. Keyed by slide-ID, so it survives reordering / added / removed slides.
- Geometry is absolute EMU: if a screenshot is re-cropped to a very different size, its box may need a nudge. Boxes on removed/`--not done--` slides are dropped.

## Decisions locked (2026-05-26)

- python-pptx as authoring tool.
- 16:9.
- One PPTX per day (4 → 5 once D5 SLIDE_SOURCE exists).
- Embedded screenshots (not linked).
- Static (no transitions).
- Code = Godot screenshots + draggable red highlight overlay shape.

## Open items

- Brand inputs (logo + sample deck PPTX + fonts) — user provides next.
- D5 `SLIDE_SOURCE.md` does not exist yet — D5 deck blocked until written.
- Whether to include a per-slide speaker-notes block for the instructor — defer until brand capture lands.

## Memory pointer

See `~/.claude/.../memory/slides-build-pipeline.md` for the cross-chat resume note.

---

## Session Pause — 2026-06-09

**Lane / context:** single context (slide-deck pipeline)
**Active workstream/task:** Phase 2.5 per-slide blueprints. D2 per-slide expansion DONE this session. **Next: D3 per-slide expansion (Phase 2.5 continues), OR D2 Phase 2.5b (personalization/FC/export/closer stubs).**
**Status:** D1 done (prior session); D2 done this session (86 slides, clean build). D3-D5 awaiting-start.

### Where we are

This session: expanded D2 `SLIDE_SOURCE.md` §10.2–§10.4 from summary-level bullets to full per-slide `#### Slide D2-S###` entries (86 slides total: opener S001-S007, pre-coding S008-S020 incl. Walk T, lesson chunks S021-S086 across chunks #1-#6 + Walk C/D). Build verified: `slides/.venv/bin/python build_day.py 2` → `out/Day2.pptx` 86 slides, 0 skipped. Guide-canonical image names used throughout (D2C1–D2C6, D2TS1–2, D2Pacman1–2); no ad-hoc `d2_*` names.

### Last decision locked

- **D2 per-slide blueprint complete** (§10.2–§10.4): 86 slides authoring-ready. §10.5 (personalization / FC / asset / export / closer) deferred — stub unchanged.
- **Guide-canonical names enforced from start for D2**: D2C3a/D2C3b (dual chunk-3 holes), D2TS1–2, D2Pacman1–2, D2C1–D2C6. Zero ad-hoc names.
- **Chunk #6 two-tone overlay documented** in blueprint: gray = pre-given off-grid+tunnel guards, red = kid hole. Notes field carries R5 context.

### Next pending picks

- **D3 expansion** (Phase 2.5 main path): read D3 `SLIDE_SOURCE.md` + capture guide §D3 before any work.
- **D2 Phase 2.5b** (deferred §10.5): personalization beats (D2Beat* shots), FC (D2FC1–3), export, closer. ~25-30 slides.
- **D1 reconciliation** (still PENDING): chunk shots alias-bridged (`d1_chunk*`→`D1C*`), personalization beats, export steps — backfill when convenient.

### Critical context to carry forward

- Build command: `cd slides && .venv/bin/python build_day.py <N>` (not bare `python` or `python3` — pptx lives in the `.venv`).
- D2 blueprint line-numbers from capture guide (SoT): C1=69-72, C2=123-126, C3a=77-79, C3b=213-225, C4=153-160, C5=171-178, C6=201-204.
- `out/Day1.pptx` still holds original hand-edits. Don't overwrite until confirmed captured. `Day1_v4.pptx` is current.

### Files Touched This Session

- `Day2_Maze_Game/SLIDE_SOURCE.md` — §10.2–§10.4 per-slide expansion complete (86 slides, S001–S086). Summary bullets replaced.
- `slides/out/Day2.pptx` — NEW, 86 slides.
- `SLIDES_PLAN.md` — this pause-block.

---

## Session Pause — 2026-06-08

**Lane / context:** single context (slide-deck pipeline)
**Active workstream/task:** Phase 2.5 per-slide blueprints. D1 deck build + harness (DONE this session). **Next: D2 per-slide expansion.**
**Status:** D1 done; D2 awaiting-start.

### Where we are

This session: finished D1 §10 blueprint (opener + 3 new slides + lesson block + back-half S106-S140), built the python-pptx harness (`build_day.py` parses §10 markdown → pptx), and hardened it through user review of `Day1.pptx`. Brand overridden to red/black/grey minimalist. Built + reviewed `slides/out/Day1_v4.pptx` (136 slides). Next chat **finishes D2** (per-slide expansion of `Day2_Maze_Game/SLIDE_SOURCE.md` §10 — decisions already locked in its §10.9).

### Last decision locked

- **Guide wins over blueprint 100%.** `SCREENSHOTS_CAPTURE_GUIDE.md` is SoT for screenshots: filenames, counts (= actual files), `--not done--` = skip slide. D1 walks reconciled to guide; D1 chunks/beats/export + all of D2-D5 still need reconciling.
- **Red-overlay round-trip** built so the user's hand-positioned red boxes survive rebuilds (`extract_overlays.py` → `out/DayN.overlays.json` → restored by `build_day.py`). D1: 19 boxes round-trip exactly.
- Slide quality fixes: markdown renders bold/italic/code; images aspect-fit; field-parse allows commas in field names (was blanking board-example code); `Body: none` no longer prints "none"; title slide = "VR Creator - Day 1".

### Next pending pick (D2)

D2 per-slide expansion scope (from D2 §10.9, user already leaned "mirror D1"): per-slide expand opener + pre-coding + chunks #1-#6 now (~85-90 slides), defer §10.5 personalization/FC/asset/export/closer stubs to a 2.5b pass. RHS prose picks + Pac-Man historical content already LOCKED in D2 §10.9. Apply the SAME guide-SoT discipline from the start (read `SCREENSHOTS_CAPTURE_GUIDE.md` §D2 first — use `D2C*`, `D2Beat*`, `D2FC*`, `D2TileSet*` filenames, NOT ad-hoc `d2_*` names; honor `--not done--`).

### Critical context to carry forward

- **Read `SCREENSHOTS_CAPTURE_GUIDE.md` before any deck work** — same reflex as BIBLE.md. Use its filenames + counts; do NOT invent `dN_*` names (that caused the D1 caption/image mismatch).
- **No authoring directives in slide `Body:`** — styling/render notes go in `Notes:`.
- D1 reconciliation still PENDING (not done): chunk task shots (`d1_chunk*`→`D1C*` still alias-bridged in `build_day.py ALIASES`), personalization beats (blueprint §10.17a content differs from guide beats), export steps.
- Canonical `out/Day1.pptx` still holds the user's ORIGINAL hand-edits (extract source) — don't overwrite until boxes confirmed captured. `Day1_v4.pptx` is current.
- Build with `SLIDES_OUT=alt.pptx` env if the target pptx is open/locked in PowerPoint.

### Files Touched This Session

- `Day1_Pong_Game/SLIDE_SOURCE.md` — full §10 authored (opener +S002a/S003a/S003b, back-half S106-S140); title→"VR Creator - Day 1"; S024 directive→Notes; Walk A/B/C/D reconciled to guide filenames+counts.
- `Day2_Maze_Game/SLIDE_SOURCE.md` — §10.9 locked (RHS prose picks, Pac-Man history, brand resolution).
- `slides/theme.py`, `master.py`, `templates.py` — brand red/black/grey; markdown inline render; aspect-fit; overlay-box helper.
- `slides/build_day.py` — NEW parser-driven build; G→L dispatch; guide `--not done--` skip; alias map; overlay restore; `SLIDES_OUT` env.
- `slides/extract_overlays.py` — NEW red-box extractor (hash+caption match → overlays.json).
- `SLIDES_PLAN.md` — brand section; overlay round-trip section; this pause-block.
- `SLIDES_FORMATS.md` — master-frame + brand notes updated to red/black/grey.
- `out/Day1.overlays.json` — NEW, 19 captured boxes.
- Memory: `deck-build-harness.md`, `screenshot-guide-sot.md`, `no-authoring-directives-in-slides.md` (new); `slides-build-pipeline.md`, `MEMORY.md` (updated).
