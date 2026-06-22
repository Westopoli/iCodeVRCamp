# Day 3 — Base Defense (Instructor Notes)

Companion to BIBLE §6 "Day 3 — Base Defense" lock. Quick-reference for setup, common kid stuck-points, tuning, and build commands.

## One-time setup

1. Open Godot 4.6.x.
2. Import `Day3_BaseDef_Game/project.godot`.
3. Press F5 to run. The first launch reimports all 299 Kenney tiles — takes 10-20s. Subsequent launches are instant.
4. If sprites look wrong (a tower looks like grass), the tile numbers in `main.gd`'s `TOWER_STATS` / `ENEMY_STATS` / scenery exports in `Main.tscn` need swapping. Pick any other PNG from `assets/kenney_td/` and replace the number.

## Game mechanics (instructor cheat sheet)

- **Field:** 1280×720 viewport. 20×11 grid of 64×64 cells = 1280×704 playfield. Bottom 16 px = dead green strip.
- **Base:** 2 cells wide at (9, 5) + (10, 5). 20 HP. Area2D — `body_entered` damages.
- **Spawns:** random edge cell, one of the 4 outer rows/columns. SPAWN_INTERVAL controls in-wave pacing.
- **Per-enemy attack waypoint:** on spawn each enemy picks one of 6 cells around the base perimeter as its destination → no clustering on one pixel (BIBLE D10).
- **Physics (BIBLE D2 refinement):** enemies CharacterBody2D on layer 2, mask = 6 (layers 2 + 3 → bump other enemies + towers). Towers StaticBody2D on layer 3. Enemies slide on each other AND on towers. On tower-collision the enemy enters "attacking" state (drains tower HP at `enemy.tower_dps`); resumes seeking when tower destroyed.
- **Towers:** 3 types — Cannon, Sniper, Splash. Click empty cell with selected type to place if affordable.
  - **Cannon ($25):** short range, fast fire, low damage. Anti-runner.
  - **Sniper ($40):** long range, slow fire, high damage. Anti-tank-grunt.
  - **Splash ($60):** medium range, medium fire, AoE damage. Anti-grouped-grunts.
- **Enemies:** Grunt (14 HP, slow, big base damage) + Runner (6 HP, fast, light base damage).
- **Currency:** start 100 coins. Kill grunt +4, kill runner +3. **No refund** on tower destruction (user-locked).
- **Win:** clear all 8 waves. Lose: base HP ≤ 0.
- **R** restarts. **SPACE** starts next wave between waves. Wave 1 auto-starts after 2s grace.

## Code layout

- `main.gd` — all 9 kid chunks live here (11 `#@todo` blocks after R5 splits on #5a + #6). Pre-given helpers outside `#@todo` markers (so they survive Template/Complete strip). FC hook wiring (`fc_node` field + `_ready` instantiation + `_process` routing) also lives here, all outside `#@todo` blocks.
- `Enemy.tscn` + `enemy.gd` — per-instance state container. Kids don't write here.
- `endless_mode.gd` — Final Challenge. 9 mirror holes (FC-1 through FC-7, with FC-6 split into 4 sub-branches). Each FC hole is a near-clone of a morning chunk per BIBLE §4 R3.1.

## Chunk map (matches BIBLE §4 table — refreshed 2026-05-29 under R1-R6 + R3.1)

| # | Where | What |
|---|---|---|
| 1 | `main.gd` top of script | 4 var declarations (enemies, towers, coins, base_hp) |
| 2a | `spawn_enemy()` | `enemies.append(e)` |
| 2b | `kill_enemy()` (×2 branches) | `enemies.erase(e)` + reward (and erase-only on no-reward branch) |
| 3 | `_process()` | Two for-loops calling `step_enemy` + `tower_tick` |
| 4 | `move_all()` | List-loop refactor |
| 5a | `get_nearest_enemy_in_range()` (R5 partial) | Loop body only — closest-in-range; init + return pre-given |
| 5b | `get_enemies_in_radius()` | Loop + collect-in-radius |
| 6 | `tower_tick()` (R5 partial split: 6a + 6b) | Pre-given `match` dispatcher; kid fills single-target body (6a) + list-target body (6b) |
| 7 | `_process()` | Size check + wave advance |

## Common kid stuck-points (anticipated — log refinements after first camp)

1. **"Nothing moves" / "Towers don't shoot"** → kid hasn't filled TODO #3 (the two for-loops in `_process`). The whole simulation is frozen without those two lines.
2. **"My towers fire at the wrong target"** → check TODO #5a's `if d <= range AND d < best_dist` — easy to flip the inequality.
3. **"My splash tower doesn't damage anyone"** → TODO #5b returning an empty list. Check the `result.append(enemy)` line is inside the `if` not before.
4. **"Wave never advances"** → TODO #7 missing the `enemies_to_spawn.size() == 0` half of the compound condition. Wave ends when both lists are empty.
5. **"Sprites are wrong"** → tile numbers in TOWER_STATS / ENEMY_STATS don't match what Kenney chose. Swap one number, save.

## Tuning notes (initial seed values — iterate per BIBLE playtest pattern)

Located at top of `main.gd`:

- `TOWER_STATS` — per-type cost/range/fire_rate/damage/hp.
- `ENEMY_STATS` — per-type hp/speed/damage_to_base/tower_dps/reward.
- `WAVES` — `[count, type]` tuples × 8.
- `START_COINS` (100), `START_BASE_HP` (20), `SPAWN_INTERVAL` (0.7s).

All flagged `# TUNED — feel free to nudge` in the script. Iteration log lives in BIBLE §6 D3 lock subsection.

## Build commands

```powershell
.\build\build_templates.ps1 -Day Day3_BaseDef_Game
```

Generates `dist/Day3_BaseDef_Game_Template.zip` (kid scaffold, won't compile until chunks filled) + `dist/Day3_BaseDef_Game_Complete.zip` (instructor reference, source of truth).

`.exe` export is manual via Godot's export dialog (BIBLE §11).

## Final Challenge framing (R3 + R3.1 — refreshed 2026-05-29)

Pointer-guided review. Slides give the rule in prose + mirror-pointer to the morning chunk it clones. No verbatim code on the pointer slide. Kid recognizes "oh I did this earlier" and writes it. Per BIBLE §4 R3.1, the FC mirrors every morning chunk (no skipped chunks).

Mirror map (also in `endless_mode.gd` comments):

- **FC-1**  ← TODO #1   (declare state vars — 5 vars this time)
- **FC-2a** ← TODO #2a  (`.append` to a list)
- **FC-2b** ← TODO #2b  (`.erase` from a list + reward)
- **FC-3**  ← TODO #3   (iterate two lists each frame, inline in `endless_tick`)
- **FC-4**  ← TODO #4   (function takes a list as a parameter — `buff_all`)
- **FC-5a** ← TODO #5a  (function returns ONE from a list — `get_fastest_enemy`, R5 partial)
- **FC-5b** ← TODO #5b  (function returns a LIST from a list — `get_wounded_enemies`)
- **FC-6**  ← TODO #6   (`match` + nested calls — kid fills four `escalate()` branches)
- **FC-7**  ← TODO #7   (`list.size()` check + state transition — screen-clear escalation)

Total FC kid LoC ≈ 36 (morning ≈ 39 → −8%, within R3.1 ±20% envelope).

To activate after kid fills the file: open `main.gd`, set `const ENDLESS_MODE := false` → `true`. Save, play. The hook wiring (instantiate `endless_mode.gd` as a child of Main, route `_process` to `fc_node.endless_tick`, swap HUD wave label for "Endless Mode") is pre-given in `main.gd` — kid never touches `preload / new / add_child`.
