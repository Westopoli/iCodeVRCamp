# Slide Format Catalog (draft for user review)

Derived from end-to-end read of `Day{1..4}_*/SLIDE_SOURCE.md`. D5 expected to fit existing formats (same §-skeleton per `slide-source-rules`); D5 forecast in counts is an estimate.

Every format inherits the **master frame**: iCode logo top-left, day tab + section tag top-right, page number bottom-right, footer rule. Master defined once in `master.py`.

## Format list

| ID | Name | Use | Screenshot? | Red highlight? |
|---|---|---|---|---|
| F01 | Day Title | Open of each day. Year · iconic title · genre · concepts. | Optional (era art) | No |
| F02 | Narrative Arc | 5-day video-game-history timeline; today highlighted. | No | No |
| F03 | GDScript-vs-Python | Two-column code panel pulled verbatim from §1. | No (rendered text) | No |
| F04 | Section Divider | Large §-label (e.g. "Pre-coding setup", "Lesson chunks"). | No | No |
| F05 | Build Narrative | Text-heavy "how this game is built" body. | Optional small | No |
| F06 | Scene Tree | Monospace ASCII tree (from §2). | No | No |
| F07 | File Manifest | Table: File · Role · Kid edits? | No | No |
| F08 | Asset Pack Card | Pack name · license · filename convention · sprite picks. | Optional sprite previews | No |
| F09 | Constants Table | e.g. D2 timing consts, D3 stat block, D4 character stats. | No | No |
| F10 | Chunk Table | Full per-day chunk roster (from §3). | No | No |
| F11 | Concept Intro | Concept name + 1-sentence definition + small icon. | No | No |
| F12 | Board Example | Small code example, centered, big monospace. | No | No |
| F13 | Your Task | Goal field as bullets + optional thumbnail of expected end state. | Optional | No |
| F14 | In-File Location | Godot script-editor screenshot + caption "file:line". | YES | YES (where chunk goes) |
| F15 | As-Typed Code | Screenshot of completed code in Godot (or pre-rendered code image). | YES | Optional (highlight key new lines) |
| F16 | After-This-Works | Game-running screenshot + one-line caption. | YES | Optional |
| F17 | Walkthrough Step | One screenshot (~60% slide) + step number + caption (~40%). | YES | YES |
| F18 | Personalization Beat Intro | Beat number + one-line goal ("Make your cannon overpowered"). | No | No |
| F19 | FC Mirror Map | Table: FC hole · mirrors morning chunk · concept reviewed. | No | No |
| F20 | FC Hole | Placeholder code (`KEY_?` / `???`) + goal + "no copy-paste" reminder. | Optional (image of placeholder code) | Optional |
| F21 | Takeaway / Export | End-of-day export-to-exe walkthrough (D1 Beat 6 reused D2-D4). | YES (step shots) | YES |
| F22 | Day Closer | "Tomorrow: <next iconic title>" teaser. | Optional era art | No |

## Per-day count estimate

Counts cover authored content density. ±10% wiggle.

### D1 — Pong (8 chunks, copy-along)

| Section | Slides | Notes |
|---|---|---|
| F01 Day Title | 1 | |
| F02 Narrative Arc | 1 | |
| F03 GDScript-vs-Python | 1 | |
| F04 Section Dividers | 5 | §2/§4/§5/§6/§7 |
| F05 Build Narrative | 1 | |
| F06 Scene Tree | 1 | |
| F07 File Manifest | 1 | |
| F08 Asset Pack | 1 | "no assets — colored boxes" |
| F09 Constants | 0 | None for D1 |
| F10 Chunk Table | 1 | |
| Pre-coding (Walk A/B/C/D) | 21 | F17 steps |
| Per-chunk × 8 chunks × 5 slides | 40 | F11 concept · F12 board · F13 task · F14 in-file · F15 code |
| F16 After-this-works | 2-3 | Sprinkled at high-payoff chunks (#6b, #5) |
| Personalization (6 beats) | 30 | F18 intro ×6 + F17 step shots (~24 steps) |
| FC mirror map + 2 hole slides + enable | 5 | F19, F20 ×2, F17 ×2 |
| F08 Asset reference recap | 1 | |
| F21 Export-to-exe | 10 | Beat 6 step-shots |
| F22 Closer | 1 | "Tomorrow: Pac-Man" |
| **Total** | **~125** | |

### D2 — Pac-Man (6 chunks, TileSet-heavy)

| Section | Slides |
|---|---|
| Top matter (F01-F10) | ~10 |
| TileSet orientation walkthrough | 6 (F17) |
| Per-chunk × 6 × 5 slides | 30 |
| F16 After-works | 2 |
| Personalization (7 beats, ~28 steps) | ~32 |
| FC (4 holes + mirror map + enable) | 9 |
| Asset recap + Closer + Export | 12 |
| **Total** | **~100** |

### D3 — Base Defense (8 chunks, FC has 4 holes)

| Section | Slides |
|---|---|
| Top matter | ~10 |
| Difficulty-knob demo | 6 (F17) |
| Per-chunk × 8 × 5 slides | 40 |
| F16 After-works (chunk #6 placement walkthrough) | 8 |
| Personalization (6 beats) | ~24 |
| FC (4 holes + mirror map + enable) | 9 |
| Asset recap + Closer + Export | 12 |
| **Total** | **~110** |

### D4 — Fighter (7 chunks, chunks #6/#7 huge)

| Section | Slides |
|---|---|
| Top matter | ~12 |
| Menu-flow demo + CHARACTERS dict tour | 10 (F17 + F09) |
| Per-chunk × 7 × 5 slides | 35 |
| F16 After-works (esp. after #4, #6, #7) | 5 |
| Personalization (6 beats) | ~25 |
| FC (3 holes + mirror map + enable) | 8 |
| Asset recap + Closer + Export | 12 |
| **Total** | **~107** |

### D5 — Racing (forecast, no SLIDE_SOURCE yet)

Expect similar shape; ouroboros may change shape if FC absent (per [[d5-racing-build-decisions]] — no FC for D5). Reserve ~80-100 slot.

**Cross-day grand total: ~520-550 slides.** Authored once at template level; per-slide work is content + screenshot only.

## Format frequency (across all days)

| Format | Approx instances |
|---|---|
| F17 Walkthrough Step | ~180 (largest by count) |
| Per-chunk pack (F11-F15) × 29 chunks total | ~145 |
| F16 After-works | ~15 |
| F20 FC Hole | ~13 |
| F18 Personalization Beat Intro | ~25 |
| F01-F10 Top matter | ~60 (12 × 5 days) |
| F21 Export | ~50 (Beat-6 steps × 4 days that ship a takeaway) |
| F22 Closer | 5 |
| F19 FC Mirror Map | 4 |

Top 3 by instance count (F17, F14, F15) deserve the most layout-iteration attention in Phase 3 sample deck.

## Sample-deck spec for Phase 3

`SAMPLE_DECK.pptx` includes one slide per format (F01-F22 = 22 slides). Each uses:
- Real iCode header/footer (from brand-pull).
- Lorem-ipsum text where content varies.
- Real Godot placeholder screenshot for F14/F15/F17 (one shared dummy).
- Real red highlight shape pre-dropped on F14/F17 at a default size + position.
- Real concept-icon placeholder for F11.

User reviews sample deck, lists fixes, AI iterates `templates.py` only.

## Open spec items (decide before Phase 2 lock)

1. **Font** — pulled from iCode sample decks once user provides. Need title font + body font + monospace.
2. **Color palette** — pulled from iCode sample decks. Need primary, accent, code-block background.
3. **Concept icons** (F11) — use Kenney UI icons? Custom SVGs? Skip icons entirely?
4. **Red highlight default shape + size** — rectangle 400×120 px stroke 4px red? Or smaller circle? User pick.
5. **Speaker notes** — populate per slide for instructor? (Adds ~520 small writing tasks; can skip and have instructor use SLIDE_SOURCE.md as cue card.)
