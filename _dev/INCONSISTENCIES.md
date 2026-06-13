# Known Inconsistencies — D2–D5 (excludes D1)

> Running log of open inconsistencies between the camp **code**, **slides** (`DayN_*/SLIDE_SOURCE.md`), **capture guide** (`SCREENSHOTS_CAPTURE_GUIDE.md`), and **captured screenshots**. For future chats. Last updated **2026-06-11**.
>
> **Authority rule (locked):** captured screenshot files > capture guide > §10 blueprint. Deck must match the real captures exactly. See memory `screenshot-guide-sot`.
> **Status tags:** `[OPEN]` outstanding · `[VERIFY]` suspected, not yet confirmed · `[FIXED 06-11]` resolved this session, kept for context.

---

## Cross-cutting (all days D2–D5)

- `[OPEN]` **dist ZIPs stale.** `dist/DayN_*_{Complete,Template}.zip` built 2026-05-29. Code changed since for D1/D3/D4/D5. **D2 regenerated 2026-06-11.** Regen the rest via `python build/build_templates.py` (or `--day DayN_*`). See memory `dist-zips-stale`.
- `[VERIFY]` **`:=` type-inference parse bug on Godot 4.6.3.** `var x := <expr off a loosely-typed back-ref like `main: Node`>` fails with "Cannot infer the type." **Confirmed + fixed in D2** `ghost_personalities.gd` (6 sites → explicit `Vector2i`/`Vector2`). Grep found no `:= main.X` pattern in D3/D4/D5, but **none are parse-verified on 4.6.3** — open each project in Godot 4.6.3 and check the error count, especially FC/helper files (`Day3 endless_mode.gd`, `Day4 final_challenge.gd`, `Day5 *.gd`).
- `[OPEN]` **Screenshot dirs missing.** `slides/screenshots/day{3,4,5}/` do **not exist** (day2 was created 06-11). `build_day.py` reads `dayN/` then `shared/`; must `mkdir` + copy captures there before building D3/D4/D5.
- `[OPEN]` **Holes shot from the INSTRUCTOR (filled) copy show the solution.** The red overlay is a 4px **outline, no fill** — it does NOT hide the answer. So any hole screenshot taken from the solved project reveals the code. Decide per day: reshoot holes from the **template** project (empty `#@todo` bodies) or accept that kids see the answer. Observed in D2 FC; likely same for D2 chunk shots + other days.
- `[OPEN]` **Guide ↔ removed/renamed shots drift.** When a slide/shot is removed or renamed, the capture guide's plan entry can go stale. Captures are authority — treat guide as the *plan*, files as the *result*.

---

## D2 — Pac-Man / Maze

- `[OPEN]` **`D2FC4` is the WRONG shot.** It is the old `main.gd` `check_ghost_collisions()` reset-routing capture (a pre-given *call site*), NOT the FC-4 hole. Reshoot at **`ghost_personalities.gd:251-261`** (`reset_personality_ghosts`, banner `# TODO FC-4`). Same filename. S096 shows a placeholder until reshot; intentionally NOT copied to `day2/`.
- `[OPEN]` **FC hole shots show the filled solution.** `D2FC1/2/3/5/6` were captured from the instructor copy (e.g. `spawn_personality_ghosts` body visible). See cross-cutting "filled copy" item. Reshoot from template if you don't want kids seeing answers.
- `[OPEN]` **`D2FC1` has a stale red error banner** at the bottom (captured before the `:=` fix). Recapture for a clean frame; code is fixed now.
- `[OPEN]` **`D2Pacman1` / `D2Pacman2` (historical opener images) not captured** → placeholders on the opener slides.
- `[OPEN]` **TileSet shots never captured; 2 slides removed.** `D2TS1`/`D2TS2` don't exist anywhere; slides **S015/S016 were deleted 06-11**. Walk T now relies on the instructor's **live demo** for the "click Walls node → Tile Set → Edit" steps. Guide §2 still documents the D2TS capture (stale plan).
- `[OPEN]` **`Day2.pptx` not yet rebuilt** — every `build_day.py 2` this session hit a `PermissionError` because the `.pptx` was open in PowerPoint. It parses clean; close the file and rebuild.
- `[FIXED 06-11]` Personalization/FC/export/closer §10 sections authored (were stub-deferred). FC code-refs corrected (`final_challenge.gd`/`FC_ENABLED` → `main.gd` `PERSONALITY_MODE_ENABLED`). `:=` parse bug fixed. `D2TileSet*` → `D2TS*` rename.

---

## D3 — Base Defense

- `[OPEN]` **No screenshots captured;** `slides/screenshots/day3/` missing.
- `[OPEN]` **Stray duplicate FC ref.** `Day3_BaseDef_Game/SLIDE_SOURCE.md` ~line 2496 has a second `D3FC1.png -- not done --` (one good ref + one not-done dup). Cosmetic; clean up.
- `[VERIFY]` **§10 completeness** — confirm personalization / export / closer are actually authored as slides (D2 had these stub-deferred; D3 may too). FC is expanded (S108–S124).
- `[OPEN]` dist D3 zip stale (see cross-cutting).
- `[NOTE — consistent]` FC mechanism is **correct**: `const ENDLESS_MODE := false` at `main.gd:76` + `endless_mode.gd`, matching across code, SLIDE_SOURCE (S108–S124), and guide. Not the D2-style bug.

---

## D4 — 2-Player Fighter

- `[OPEN]` **No screenshots captured;** `slides/screenshots/day4/` missing.
- `[OPEN]` **`player.gd` changed 2026-06-11** (git pull) → dist D4 zip stale.
- `[VERIFY]` **FC ref-consistency not checked.** `final_challenge.gd` exists; confirm the slides + guide match the real code (the `CUSTOM_CHARACTER` dict + `CHARACTERS["custom"] = CUSTOM_CHARACTER` wiring in `main.gd`) — same class of bug D2 had.
- `[VERIFY]` **§10 completeness** — confirm personalization / export / closer authored.
- `[VERIFY]` `:=` parse bug on 4.6.3 (see cross-cutting).

---

## D5 — Racing

- `[OPEN]` **`SLIDE_SOURCE.md` largely UNAUTHORED** — ~175 lines (opener stub only). Bulk of the deck not written.
- `[OPEN]` **No screenshots captured;** `slides/screenshots/day5/` missing.
- `[OPEN]` **Asset pin pending** — Kenney 3D racing kit supersedes the Sloyd lock; capture the exact pack name. See memory `d5-racing-asset-pin`.
- `[OPEN]` dist D5 zip stale (see cross-cutting).
- `[VERIFY]` `:=` parse bug on 4.6.3 across `car.gd / ghost.gd / hud.gd / main.gd / track.gd / track_builder.gd`.
- `[NOTE]` D5 has **no Final Challenge** by design (memory `d5-racing-build-decisions`).
