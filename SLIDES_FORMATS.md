# Slide Format Catalog — L1-L8 (LOCKED 2026-05-31)

Locked format set for the python-pptx slide-build pipeline. Down from 22 (v1) → 12 (v2 proposed) → **8 (L1-L8, final)**. Format count drives `templates.py` complexity, not deck size. Across D1-D4 we still ship ~520 slides total.

Every format inherits the **master frame** (`slides/master.py`): thin full-width **black** (`#111111`) top bar — iCode logo top-left, **"Day N"** label in red top-right, page number bottom-right in mid-grey. Sleek / minimalist; no gradient, no sun motif, no blobs. Brand = **red / black / grey** (palette locked in `SLIDES_PLAN.md` § Brand). Day differentiation is the **"Day N" text only — no per-day color**. Red is the single accent across all days.

## Format list

| ID | Name | Use | Red overlay? | Step badge? | Layout function |
|---|---|---|---|---|---|
| **L1** | Title | Day Title, Section Divider, Word Reveal, Day Closer, Personalization Beat header. Big centered heading + optional subtitle / background image. | No | No | `tpl.l1_title()` |
| **L2** | Body | Headline + bullets / paragraphs. Historical context, "Today's concepts", how-used, pieces-you'll-use, concept definitions, quiz Q+A. | No | No | `tpl.l2_body()` |
| **L3** | Side-by-Side | Two-column layout. GDScript-vs-Python, before/after, "Shape in code" alongside metaphor caption. | No | No | `tpl.l3_side_by_side()` |
| **L4** | Image | Full-bleed image / diagram + caption strip. Metaphor hooks (panda, PS5, traffic light, vending machine), after-works payoff screenshots, class/state diagrams. | No | No | `tpl.l4_image()` |
| **L5** | Table | Header row + N data rows. Chunk table, FC mirror map, character stats, behaviors table, constants. | No | No | `tpl.l5_table()` |
| **L6** | Code | Centered monospace code block + optional caption. Standalone board examples, scene tree, constants block. | No | No | `tpl.l6_code()` |
| **L7** | Step | Screenshot ~60% + step badge + caption ~40%. All walks (A-D, MF, CD, DK), where-in-game screenshots, personalization step beats, export-to-exe steps. | Optional | Yes | `tpl.l7_step()` |
| **L8** | Action | Top prose + LHS code + RHS Godot screenshot with red overlay. Per-chunk Action slides, per-FC-hole Action slides. R5 partial-hole variant adds a gray overlay underneath the red. | **YES** | No | `tpl.l8_action()` |

## v1 → v3 merge mapping

Every v1 format (F01-F22) folds into one of L1-L8:

| L | Absorbs v1 |
|---|---|
| L1 | F01 Day Title · F04 Section Divider · F18 Personalization Beat Intro · F22 Closer + "Word reveal" slides |
| L2 | F05 Build Narrative · F11 Concept Intro · F13 Your Task · "How-used" / "Pieces you'll use" / quiz bodies |
| L3 | F03 GDScript-vs-Python · "Shape in code alongside metaphor" variants |
| L4 | F02 Narrative Arc (timeline as diagram) · F08 Asset Pack Card (image-heavy) · F16 After-Works · metaphor anchors |
| L5 | F07 File Manifest · F09 Constants · F10 Chunk Table · F19 FC Mirror Map · character stats |
| L6 | F06 Scene Tree · F12 Board Example (standalone, no LHS/RHS pairing) |
| L7 | F14 In-File Location (where-in-game) · F17 Walkthrough Step · F21 Export Walkthrough |
| L8 | F15 As-Typed Code (RHS pane only — kid doesn't see "as-typed") · F20 FC Hole · per-chunk Action slide spec |

## Per-day count estimate (with L1-L8)

Counts unchanged from v1 — format collapse doesn't reduce slide count, only `templates.py` complexity.

| Day | Total slides | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 |
|---|---|---|---|---|---|---|---|---|---|
| D1 Pong | ~125 | 14 | 25 | 1 | 8 | 4 | 8 | 50 | 9 |
| D2 Pac-Man | ~100 | 12 | 20 | 1 | 6 | 4 | 8 | 38 | 7 |
| D3 Base Defense | ~110 | 14 | 22 | 1 | 7 | 5 | 10 | 38 | 11 |
| D4 Fighter | ~107 | 13 | 22 | 1 | 7 | 5 | 8 | 38 | 10 |
| D5 Racing (forecast) | ~80-100 | 10 | 15 | 0 | 12 | 3 | 4 | 35 | 0-3 |
| **Total** | **~522-542** | ~63 | ~104 | 4 | ~40 | 21 | ~38 | ~199 | ~37 |

**L7 Step is by far the largest by instance** — ~200 across the camp. Worth the most layout-iteration attention in the sample-deck loop.

**L8 Action is the most layout-complex** — 4 zones (prose / LHS / RHS / overlay rect). Already the most-iterated layout in `templates.py`.

## Manual user step on L8 Action slides

Templates inject a **default red rectangle** at the center of the RHS screenshot pane. After the .pptx is built, the user opens it in PowerPoint and **drags + resizes that rectangle** so it surrounds the actual kid `#@todo` lines on each screenshot. ~37 manual drags across D1-D4 (one per L8 instance).

R5 partial-hole L8 slides (D2 chunk #6, D3 chunks #5a + #6, D4 chunk #6 sub-holes) get an additional **gray overlay** auto-dropped underneath the red — represents pre-given lines. User does NOT need to position the gray; it ships in a reasonable default position.

## Pipeline status

- ✓ Format catalog locked (this file).
- ✓ `slides/` scaffolded — `theme.py`, `master.py`, `templates.py`, `build_sample.py`, `build_day.py` stubs.
- ✓ `SAMPLE_DECK.pptx` builds (one slide per L1-L8, placeholder content).
- ✓ Logo asset present (`slides/assets/logos/icode_logo_red.png`).
- ⏳ User capturing screenshots per `SCREENSHOTS_CAPTURE_GUIDE.md`.
- ⏳ Sample-deck visual review → `templates.py` iteration loop.
- ⏳ Per-day `SLIDES.py` authoring (post-template lock).
- ⏳ Mass build `python build_day.py 1..4`.

## Open spec items (deferred — will lock as the sample-deck loop runs)

- **Brand fonts** — `theme.FONT_HEADING` / `FONT_BODY` currently set to `"Poppins"` with Calibri fallback. Confirm or override when raw iCode PPTX brand sample lands.
- **Brand color** — LOCKED 2026-06-08: red / black / grey minimalist (palette in `SLIDES_PLAN.md` § Brand). Red hex `#E53A2C` sampled from the logo; tunable when a raw brand pack lands.
- **White-on-transparent logo** — current `icode_logo_red.png` reads OK on the black bar but a true white version would read marginally cleaner. User to provide if available.
- **Concept icons** — locked: use **Kenney UI icons** from `slides/assets/icons/`. User to download the Kenney UI Pack + drop relevant icons into that folder before icon-using L2 slides build cleanly.
- **Speaker notes** — currently NOT populated per slide (instructor uses `SLIDE_SOURCE.md` per-chunk Speaker-notes fields as cue cards). Could add a `notes=` kwarg to every layout function later if desired.

---

## Rework log

- **2026-05-26** — v1 formats authored: F01-F22 (22 formats).
- **2026-05-26 PM** — v2 collapse proposed: 22 → 12 (G01-G12). Awaited per-day blueprint lock to finalize.
- **2026-05-31** — L1-L8 locked (8 formats) after D3 + D4 §10 slide blueprints completed. v1 + v2 superseded. `slides/` Python scaffold authored: `theme.py` + `master.py` + `templates.py` + `build_sample.py` + `build_day.py` (stub). First `SAMPLE_DECK.pptx` built successfully.
