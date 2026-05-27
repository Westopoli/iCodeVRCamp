# Day 3 — Base Defense (Instructor Notes)

Companion to BIBLE §6 "Day 3 — Base Defense" lock. Quick-reference for setup, common kid stuck-points, tuning, and build commands.

## One-time setup

1. Open Godot 4.6.x.
2. Import `Day3_BaseDef/project.godot`.
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

- `main.gd` — all 8 kid chunks live here. Pre-given helpers outside `#@todo` markers (so they survive Template/Complete strip).
- `Enemy.tscn` + `enemy.gd` — per-instance state container. Kids don't write here.
- `endless_mode.gd` — Final Challenge. 4 mirror holes (FC-1 through FC-4). Each holed task is a near-clone of a morning chunk.

## Chunk map (matches BIBLE §4 table)

| # | Where | What |
|---|---|---|
| 1 | `main.gd` top of script | 4 var declarations (enemies, towers, coins, base_hp) |
| 2a | `spawn_enemy()` | `enemies.append(e)` |
| 2b | `kill_enemy()` (×2 branches) | `enemies.erase(e)` + reward |
| 3 | `_process()` STRETCH | Two for-loops calling `step_enemy` + `tower_tick` |
| 4 | `move_all()` | List-loop refactor |
| 5a | `get_nearest_enemy_in_range()` STRETCH | Loop + closest-in-range |
| 5b | `get_enemies_in_radius()` STRETCH | Loop + collect-in-radius |
| 6 | `tower_tick()` STRETCH | Match on tower type, nested call to 5a/5b |
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
.\build\build_templates.ps1 -Day Day3_BaseDef
```

Generates `dist/Day3_BaseDef_Template.zip` (kid scaffold, won't compile until chunks filled) + `dist/Day3_BaseDef_Complete.zip` (instructor reference, source of truth).

`.exe` export is manual via Godot's export dialog (BIBLE §11).

## Final Challenge framing (D2 precedent)

Half-guided. Slides give the rule in prose + mirror-pointer to the morning chunk it clones. No verbatim code. Kid recognizes "oh I did this earlier" and writes it.

Mirror map (in `endless_mode.gd` comments too):
- FC-1 ← TODO #1 (declare vars)
- FC-2 ← TODO #2a (append-on-spawn)
- FC-3 ← TODO #5a (return ONE thing)
- FC-4 ← TODO #7 (size() check + escalation)

To activate after kid fills the file: open `main.gd`, set `const ENDLESS_MODE := false` → `true`. Save, play.
