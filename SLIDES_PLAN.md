# Slide Deck Build Plan

Canonical plan for the iCode camp slide-deck pipeline. Future chats start here.

## Stack

- **Authoring**: `python-pptx` (Python). One module per slide format, one driver per day.
- **Output**: one `.pptx` per day, 16:9 (default 13.333" × 7.5" / 1920×1080 effective). Embedded media. Static (no transitions).
- **Code rendering**: NOT rendered by python-pptx. All "code on a slide" is a Godot script-editor screenshot taken by the user. A red rectangle / ellipse shape is dropped onto the slide by the template — the user drags + resizes it in PowerPoint to surround the relevant lines.
- **Brand**: pulled from existing iCode decks (user provides PPTX samples + logo files).

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
