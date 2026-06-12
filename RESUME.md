You are resuming the iCode Unity-Replacement Camp — slide-deck pipeline.

## Session Pause — 2026-06-05

**Lane:** Design (single-lane project — no separate Implementer/Research lanes).
**Active workstream/task:** Slide-deck build pipeline scaffold + per-day SLIDES.py authoring prep.
**Status:** awaiting-pick on the `#@todo` / `#@end` Template-marker visibility decision, then per-day SLIDES.py authoring can start.

### Where we are

D1-D4 source `SLIDE_SOURCE.md` blueprints all done (§10 locked for each day). Slide-formats compressed 22→8 (L1-L8 locked). `slides/` Python scaffold built and committed — `theme.py`, `master.py`, `templates.py`, `build_sample.py`, `build_day.py` (stub). `slides/out/SAMPLE_DECK.pptx` builds clean (one slide per L1-L8). Pygments GDScript syntax highlighting added to code blocks (L3 / L6 / L8 LHS). iCode wordmark + tagline added to header. Brand colors eyeballed from `iCodeScreenshots/` PNG samples (raw brand pack not yet provided). User has been capturing per-day screenshots — D1 chunks + WalkA-D shots already pushed to `iCodeScreenshots/` as of latest pull. Capture-guide conventions locked: short filenames (`WalkA1`, `D1C1a`, `D1B1S1`, `D2FC1`), variable counts allowed (build adapts), `--not done--` reserved skip marker, `-- ... --` inline notes for build AI.

### Last decision locked

- **L1-L8 slide format catalog** (down from 22 v1 / 12 v2 proposed). Locked 2026-05-31 in `SLIDES_FORMATS.md`.
- **Kid-facing label = "task"**, not "chunk". Slides use "task" in body copy; internal docs keep "chunk". BIBLE Lingo lock updated 2026-05-31.
- **No specific line numbers in slides.** Reference TODO banners (`# TODO #1: VARIABLES`) and function names instead. BIBLE Lingo lock rule added 2026-05-31.
- **Pygments GDScript lexer drives code highlighting** (L3 / L6 / L8 LHS) — VSCode-dark palette in `theme.py`. Code stays editable in PowerPoint (no images).
- **Build script keeps `#@todo` / `#@end` markers stripped from Template** (current behavior) — but user wants them VISIBLE to the kid as "type here" prompts. **Pick A/B/C still pending** (see Next Pending Pick).

### Next pending pick (verbatim — user did not yet pick)

> Decision 1 — What text should the kid actually see as the marker in the Template ZIP?
>
> Currently `#@todo` / `#@end` are internal build-script tokens, never meant for kid eyes. Three options:
>
> **A) Keep literal `#@todo` / `#@end`** (user's original phrasing).
> - Pro: zero source-file changes — just change `convert_gd_lines()` to emit the markers instead of consuming them. Matches BIBLE §11 marker naming.
> - Con: cryptic to a 10-year-old. `#@todo` reads like a programmer convention, not a "type here" prompt. The `@` is unfamiliar.
>
> **B) Rename markers in source to kid-friendly phrasing** (e.g., `#@todo` → `# >>> YOUR CODE HERE` and `#@end` → `# <<< END`).
> - Pro: kid-readable. Clear instruction in plain English.
> - Con: requires editing every source `.gd` file to swap markers (~50+ markers across D1-D4) — bigger blast radius. Updates BIBLE §11 too.
>
> **C) Hybrid — source keeps `#@todo`/`#@end`, build translates them in Template output only.**
> - Build script reads `#@todo`, emits `# >>> YOUR CODE HERE` (or similar) into the Template file.
> - Build script reads `#@end`, emits `# <<< END`.
> - Source `.gd` files untouched — the cryptic markers stay an internal-only convention.
> - Pro: kid-friendly slide-side, no source mass-edit.
> - Con: build script gets a small translation layer.
>
> **Recommend C.** Decouples kid-facing text from internal markers.
>
> Decision 2 — Exact kid-facing phrasing (only relevant if B or C picked):
> - `# >>> YOUR CODE HERE` ... `# <<< END`
> - `# === YOUR CODE GOES BELOW ===` ... `# === END OF YOUR CODE ===`
> - `# 👉 type your code here` ... `# 👈 done` (with emoji)
> - `# TODO — your code goes here:` ... `# (end of your task)`
> - `# START` ... `# END` (minimal)

User said "undo screenshot capture guide changes and commit/push" — meaning the build-script fix is the right path (not patching the capture guide to describe stripped markers). User will rebuild Template ZIPs on Windows once the script change lands.

### Critical context to carry forward

- **CLAUDE.md Hard Rule 1 — do not make design decisions unilaterally.** For any open design choice, present 2-4 options with pros/cons. Recommendation flag allowed but not required. User caught + flagged a violation in this session when I made Pygments + line-number-rule + capture-guide-fix decisions without asking. Always present options FIRST.
- **CAVEMAN MODE ACTIVE (full)** — drop articles/filler/pleasantries/hedging. Fragments OK. Code/commits/security: write normal English.
- **Kid-facing label = "task"** (BIBLE Lingo lock). Slides + Templates use "task" everywhere kid-facing.
- **No specific line numbers in slides** (BIBLE Lingo lock). Reference banners + function names. Capture-guide navigation hints can still say "Ctrl+G → 35 → Enter" (user-side, not slide text).
- **`--not done--`** = skip the slide entirely (reserved marker in `SCREENSHOTS_CAPTURE_GUIDE.md`).
- **`-- ... --`** inline notes = freeform user observations + occasional imperative instructions for the build AI. Read them when authoring per-day SLIDES.py.
- **L1-L8 layout templates are in `slides/templates.py`.** Don't add new format types without asking.
- **Manual user step on L8 Action slides**: ~37 red-rectangle drag-resizes across D1-D4 after each build.
- **Personalization + FC slide blueprints are intentionally compressed** (one line per beat/hole) in `SLIDE_SOURCE.md` §10. Build AI expands to ~3 slides per beat / 1 slide per FC hole at SLIDES.py authoring time.
- **D5 has no SLIDE_SOURCE.md yet** — D1-D4 ship first. D5 follow-up planning is separate.
- **Brand colors in `slides/theme.py` are eyeballed.** When user provides raw iCode PPTX brand sample, tighten the palette (header gradient stops, accent palette, day-tab colors).

### Files Touched This Session

- `Day3_BaseDef_Game/SLIDE_SOURCE.md` — §10 full slide blueprint added (~460 lines)
- `Day3_BaseDef_Game/main.gd` — R1-R6 remediation: stripped (STRETCH), R5 splits on #5a + #6, FC hook
- `Day3_BaseDef_Game/endless_mode.gd` — rewritten from 4 holes to 12 sub-holes (R3.1 mirror completeness)
- `Day3_BaseDef_Game/INSTRUCTOR_NOTES.md` — refreshed chunk map + FC mirror map + hook wiring
- `Day4_Fighter_Game/SLIDE_SOURCE.md` — §10 full slide blueprint authored (~500 lines), per-chunk action prose tightened
- `Day4_Fighter_Game/player.gd` — chunk #6 R5 partial split into #6a/b/c/d, chunk #7 named-bool decomposition, simplified #5 print
- `Day2_Maze_Game/SLIDE_SOURCE.md` — §10.1 SLIDE BUILDER REFERENCE added (D3 precedent retrofit)
- `BIBLE.md` — Lingo lock added "kid-facing = task" rule and "no line numbers in slides" rule
- `SLIDES_FORMATS.md` — rewritten to L1-L8 (down from 22 v1 / 12 v2)
- `SCREENSHOTS_CAPTURE_GUIDE.md` — full rewrite with short filename convention, step-by-step instructions, `--not done--` skip marker + `-- ... --` inline notes conventions
- `slides/README.md` — created. Quick-start + L1-L8 reference + Slide content rules
- `slides/theme.py` — created. Brand colors (eyeballed), fonts, geometry, syntax-highlight palette, per-day tab colors
- `slides/master.py` — created. Gradient header strip + iCode logo + wordmark + tagline + day tab + page number
- `slides/templates.py` — created. 8 layout functions L1-L8 + Pygments-based syntax highlighting in `_add_code_block()`
- `slides/build_sample.py` — created. Emits SAMPLE_DECK.pptx with one slide per L1-L8 for visual review
- `slides/build_day.py` — created (stub). Per-day driver awaiting per-day SLIDES.py
- `slides/requirements.txt` — python-pptx + Pillow + Pygments
- `slides/.gitignore` — out/ + __pycache__/ + .venv/
- `slides/assets/logos/icode_logo_red.png` — copied from iCodeScreenshots/
- `slides/screenshots/{shared,day1-5}/` — folder structure for screenshot drops
- `iCodeScreenshots/` — folder created, contains 3 brand sample slides + logo + user-captured D1 chunks + WalkA-D shots (latest pull)

### Remote state (post-pull, ahead of next session)

- Latest local + remote commit: `8f4f1cc` (after pull)
- D5 racing work landed on remote: `track_builder.gd`, prefabs scale fixes, ghost.gd + car.gd refactors
- User added `--not done--` markers in capture guide to WalkC2, WalkD2, WalkD3
- User added `-- incorect line number, changed to D1C1c line 78 -> tacking silly variables on to scoreboard --` inline note on `D1C1bSuffix` entry — meaning that screenshot ID is now `D1C1c` not `D1C1bSuffix`. Build AI must honor this rename.

### How to resume

1. Read this file top to bottom.
2. Read `BIBLE.md` — §3 Hard Rules + Lingo lock + R1-R6 + R3.1.
3. Read `SLIDES_FORMATS.md` — L1-L8 lock.
4. Read `SLIDES_PLAN.md` — phase order.
5. Read `SCREENSHOTS_CAPTURE_GUIDE.md` — `--not done--` + `-- ... --` conventions.
6. Read `slides/README.md` — pipeline overview + slide content rules.
7. Skim `slides/templates.py` to see what L1-L8 look like in code.
8. Acknowledge the active task ("D4 slide deck build, blocked on `#@todo` marker visibility pick").
9. Ask the user: pick A/B/C for the `#@todo` marker decision + (if B or C) pick exact kid-facing phrasing.
10. Patch `build/build_templates.py` per pick.
11. User rebuilds Template ZIPs on Windows + confirms kid view.
12. Then start per-day `SLIDES.py` authoring (D1 first since D1 screenshots already pushed).
