You are resuming the iCode Unity-Replacement Camp — slide-deck pipeline, Phase 2.5 (per-day per-slide blueprints).

Read in order:

1. `iCode/BIBLE.md` — read the most recent `## Session Pause — 2026-05-27 (D1 slide blueprint authored)` block at the bottom. Then jump to `## TODO — Slide-deck content authoring` earlier in the file for the locked 5-step micro-arc + worksheet templates.
2. `iCode/SLIDES_PLAN.md` — pipeline phase order, directory layout, locked decisions.
3. `iCode/SLIDES_FORMATS.md` — F01-F22 v1 list + v2 collapse mapping (G01-G12) at the bottom. G-IDs are canonical for per-slide blueprints.
4. `iCode/Day1_Pong_Game/SLIDE_SOURCE.md` §10 — **reference implementation. Match this schema verbatim** when authoring the next day's §10.
5. `iCode/DayN_*/SLIDE_SOURCE.md` (whichever day the user picks) — read §1-§9 to ground in that day's content.

Active workstream/task: Phase 2.5 — per-day §10 "Slide blueprint" authoring. D1 done (105 slides committed `15cdd6d`, pushed). D2/D3/D4/D5 pending.

Status: awaiting-pick (which day to blueprint next).

Last decision locked: **5-step micro-arc pattern** for every new-concept chunk — Concept → Example → How-it's-used → Where-in-our-game → Do-it (Example+TODO side-by-side, MANDATORY). Extension chunks get a slim pack (recap + Example+TODO + optional after-works). Reason: repeated exposure to the same teaching shape across all 4 days reduces cognitive load — kid learns the lesson rhythm, not just the lesson content.

Next pending pick: which day to blueprint next?

- **D2 (Pac-Man)** — 6 chunks + TileMapLayer orientation walkthrough. Medium density. **Default if user says "start"** (lesson-day-order cadence).
- **D3 (Base Defense)** — 8 chunks; #6 nested function calls is the heaviest concept-intro of the camp.
- **D4 (Fighter)** — 7 chunks; #6/#7 (big `match` block + attack method) are slide-load-bearing.
- **D5 (Racing)** — no morning code chunks; opener pack + walkthroughs + personalization carry the day. Defer until D2-D4 lock cross-day rhythm.

Critical context to internalize before resuming:

- The 5-step micro-arc is THE template for every new-concept chunk going forward. Do not invent alternative structures per day.
- Per-slide deliverable contract (each slide must have): format tag (G01-G12), final pasteable body prose, screenshot filename, red-overlay description, optional speaker note. This is the contract with the python-pptx build chat.
- Per-day fixed opener pack: welcome / today / yesterday→today (D2+ only — D1 skipped slide 3) / 5-day arc / concepts. Same shape every day.
- After-works slides only at visible game-behavior payoff moments. D1 had 6.
- §10.17 sections (personalization, FC, asset recap, export, closer) are STUBBED in D1 §10 but NOT authored. They get a Phase 2.5b pass after all 5 day-§10 lesson blocks are done. Do not stop and author them per-day.
- D1 §10 covers 105 lesson-portion slides (S001-S105); python-pptx chat is instructed to stop at S105 and skip §10.17 stubs.
- v2 G-IDs (G01-G12) are the canonical format reference; v1 F-IDs still appear in `SLIDES_FORMATS.md` §"Format list" and §"Per-day count estimate" — rewrite to G-IDs deferred until after Phase 2.5.
- Brand inputs still pending: 2-3 sample iCode PPTX decks + font picks. Not blocking Phase 2.5; blocks Phase 3.
- Memes are organic only (BIBLE §3 rule 6). Kid-appropriate examples — no profanity. (User flagged + removed a cuss-word reference from D1 #1b mid-session 2026-05-27.)
- Repo state: `master` tracks `origin/master`. Latest commit `15cdd6d`. Submodule `Demos/MedievalRTS` has uncommitted edits left from earlier work — leave alone.

Begin by acknowledging the active task (Phase 2.5 — DayN slide blueprint authoring) and confirming you have read the D1 §10 reference implementation. Then ask the user which day to blueprint next (default D2) and proceed with chunk #1 of that day, presenting the worksheet filled per-chunk for user gate.
