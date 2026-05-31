# slides/ — python-pptx build pipeline

Generates the D1-D4 (and eventually D5) slide decks programmatically from the per-day `SLIDE_SOURCE.md` plus the screenshots dropped in `screenshots/dayN/`.

## Quick start

```bash
# install deps (once)
pip install -r requirements.txt

# build a sample deck (one slide per L1-L8 layout) for visual review
python build_sample.py

# build a real day deck (once SLIDES.py for that day is authored)
python build_day.py 1   # → out/Day1.pptx
python build_day.py 2   # → out/Day2.pptx
python build_day.py 3   # → out/Day3.pptx
python build_day.py 4   # → out/Day4.pptx
```

## Files

- **`theme.py`** — single source of truth for colors, fonts, sizes, padding. Edit this to retune brand. Everything else reads from here.
- **`master.py`** — header (iCode logo + gradient strip + day tab) + footer (page number) helpers. Called by every layout function.
- **`templates.py`** — 8 layout functions (L1-L8). One per slide format. Each takes a content dict + emits a slide.
- **`build_sample.py`** — emits `out/SAMPLE_DECK.pptx`, one slide per layout. For user visual review + template iteration.
- **`build_day.py`** — driver. Reads `../DayN_*/SLIDES.py` + `screenshots/dayN/` + emits `out/DayN.pptx`.
- **`assets/`** — logos, fonts, concept icons. Not regenerated.
- **`screenshots/dayN/`** — user-captured screenshots. See `../SCREENSHOTS_CAPTURE_GUIDE.md`.
- **`out/`** — built `.pptx` files. Gitignored.

## L1-L8 layouts

| ID | Use |
|---|---|
| L1 Title | Day title, section divider, word reveal, day closer, personalization beat header |
| L2 Body | Headline + bullets / paragraphs |
| L3 Side-by-Side | Two-column code or text panes (e.g. GDScript-vs-Python) |
| L4 Image | Full-bleed image + caption (metaphors, after-works, diagrams) |
| L5 Table | Header row + data rows |
| L6 Code | Centered monospace code block |
| L7 Step | Screenshot ~60% + step badge + caption (walks, where-in-game, personalization steps) |
| L8 Action | Top prose + LHS code + RHS screenshot with red overlay (per-chunk Action slide) |

## Manual user step

The **red overlay rectangle** on every L8 Action slide ships at a default size + position. After build, open the `.pptx` in PowerPoint and drag the rectangle on each Action slide so it surrounds the actual kid `#@todo` lines on the screenshot. ~60 drags across D1-D4.

## Skipped screenshots (`--not done--`)

User marks intentionally-skipped shots in `../SCREENSHOTS_CAPTURE_GUIDE.md` with a literal `--not done--` line directly under the screenshot entry. **The build-day author (whether human or AI) MUST honor this:**

- `--not done--` present → omit the corresponding slide entirely. No placeholder, no warning.
- `--not done--` absent + file missing → emit a visible placeholder ("[ MISSING: filename.png ]") so the user can spot pending captures.

Full rule set lives in `SCREENSHOTS_CAPTURE_GUIDE.md` under "Skip marker: `--not done--`".
