You are resuming the iCode Unity-Replacement Camp — slide-deck pipeline planning.

  Read in order:
    
iCode/BIBLE.md — read the most recent ## Session Pause — 2026-05-26 block at the bottom. Then jump to ## TODO
— Slide-deck content authoring (next chat's job) earlier in the file (it's the workstream brief).
iCode/SLIDES_PLAN.md — pipeline phase order, directory layout, locked decisions.
iCode/SLIDES_FORMATS.md — format catalog. F01-F22 v1 list + counts up top; v2 collapse mapping (G01-G12) at
the bottom under "## v2 collapse target".
iCode/Day1_Pong/SLIDE_SOURCE.md (if user picks D1) — that day's existing kid-facing content. Read §1-§9; the
new §10 "Slide blueprint" does not exist yet — this chat will create it.

  Active workstream/task: slide-deck pipeline — Phase 2.5 (per-slide content authoring blueprint), one chat per day
  extending each DayN_*/SLIDE_SOURCE.md with a §10 "Slide blueprint" filled chunk-by-chunk via the worksheet in BIBLE
   §TODO.
  Status: awaiting-pick (which day to author first).
  Last decision locked: Per-day fixed-5-slide opener pack (welcome / today / yesterday→today / 5-day-arc / concepts)
  + variable-length per-chunk pack (concept N · why-it-matters N · MANDATORY example+TODO side-by-side · walkthroughs
   one-step-per-slide · optional after-works). Authoring worksheet template lives in BIBLE §TODO. Format catalog v2
  collapse mapping (F→G, 22→12 formats) persisted in SLIDES_FORMATS.md.
  Next pending pick: which day to blueprint first?
    
D1 (Pong) — recommended start. 8 chunks, smallest concept density (variables + conditions). Best place to
calibrate the worksheet itself before denser days. Risk: copy-along day — least amount of why-it-matters substance.
D2 (Pac-Man) — 6 chunks + TileMapLayer orientation walkthrough. Medium density.
D3 (Base Defense) — 8 chunks, highest list-and-function depth (chunk #6 nested function calls).
D4 (Fighter) — 7 chunks; #6 + #7 are the biggest slide-load-bearing chunks of the camp (large match block,
attack method).
D5 (Racing) — no morning code chunks per d5-racing-build-decisions; defer.

  Critical context to internalize before resuming:
  
Per-slide count is density-driven, not formulaic. Earlier "5 slides per chunk" guess was explicitly rejected by
user.
Example + TODO side-by-side slide is MANDATORY per chunk: LHS = BIBLE board example, RHS = Godot screenshot of
#@todo block with red highlight overlay marking the hole. This is the load-bearing slide.
Walkthroughs between chunks: one step = one screenshot (already locked in slide-source-rules memory).
§10 "Slide blueprint" is ADDITIVE to existing §1-§9 in each SLIDE_SOURCE.md. Do not refactor §1-§9.
User gates each chunk's blueprint before moving on. Do not batch.
v2 collapse mapping (G01-G12) lives in SLIDES_FORMATS.md but the §"Format list" + §"Per-day count estimate"
sections still use F-IDs. Rewrite to G-IDs is deferred until after Phase 2.5.
Brand inputs still pending (2-3 sample iCode PPTX decks + font picks). Logo arrived (iCodeLogoRed.png). Not
blocking Phase 2.5; blocks Phase 3.
Wrap-session file edits (BIBLE §TODO, BIBLE pause-block, SLIDES_PLAN.md, SLIDES_FORMATS.md, memory) are
uncommitted on disk. Optional: commit + push before authoring starts.

  Begin by acknowledging the active task (Phase 2.5 — Day N slide blueprint authoring) and confirming you have read
  the BIBLE §TODO worksheet template. Then ask the user which day to blueprint first (default D1) and proceed with
  chunk #1 of that day, presenting the worksheet filled per-chunk for user gate.