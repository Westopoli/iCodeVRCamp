# Day 4 — Smash Bros Lite Fighter (Instructor Notes)

Companion to BIBLE §6 "Day 4 — Fighter" lock. Quick-reference for setup, common kid stuck-points, tuning, and build commands.

## One-time setup

1. Open Godot 4.6.x.
2. Import `Day4_Fighter_Game/project.godot`.
3. Press F5 to run. First launch reimports Kenney Pixel Platformer character + tile PNGs — takes a few seconds. Subsequent launches instant.
4. If a character sprite looks wrong, the `sprite` path inside `CHARACTERS` (main.gd) doesn't match — swap to any other PNG in `assets/kenney_pp/characters/`.

## Game mechanics (instructor cheat sheet)

- **Field:** 1280×720 viewport. Gravity points down (+Y).
- **State machine per player:** 6 states — `idle`, `walk`, `jump`, `fall`, `attack`, `hit`. **State-logic only, no animation frames.** Sprite stays the same image throughout; only velocity / input-routing changes per state.
- **HP:** 100 → 0 wins. No knockback, no hit-stun (HP just ticks down). Hit flash = brief red modulate.
- **Characters (4):** stats lifted verbatim from `CHARACTERS` dict in `main.gd`. Swap numbers freely during build phase.
  - **Knight** — melee, slow walk (220), high jump (520), 18 dmg, 0.55 cd, 70 range. Tanky bruiser.
  - **Ninja** — melee, fast walk (320), highest jump (560), 10 dmg, 0.30 cd, 55 range. Fast pecker.
  - **Mage** — projectile, walk 240, full-gravity arc, 16 dmg, 0.80 cd. Lobs fireballs.
  - **Archer** — projectile, walk 280, near-flat trajectory (grav 0.05), 8 dmg, 0.45 cd, 700 speed. Sniper.
- **Maps (3):** procgen from `MAPS` dict in `main.gd` — no per-map scene files.
  - **Battlefield** — ground + 3 floating platforms (L/R + top center).
  - **Final Destination** — ground only.
  - **Pokémon Stadium** — ground + 2 asymmetric side platforms (L low, R high).
- **Projectiles:** real physics entities. Own gravity scale (per character). Die on hit OR off-screen (±100 px margin). Pass through each other (no projectile-projectile collision). Ignore owner via `body == owner_player` check.
- **Collisions:** players DON'T collide with each other (fighter standard — overlap OK). Players collide with platforms only. Projectile Area2D detects players (mask=2).
- **Mid-air attack:** allowed from `jump` and `fall` states.
- **Drop-through one-way platforms:** Down+Jump combo. Implemented via pre-given `attempt_drop_through(player)` helper that temporarily disables collision with one-way platforms. **If this isn't wired in your build yet, it's a known stretch goal** — kids without it just jump up through platforms but can't drop down.

## Inputs

- **P1:** WASD (W=jump, A=left, S=down, D=right) + **F** (attack)
- **P2:** Arrow keys (Up=jump, Left, Down, Right) + **RShift** (attack)
- **Space** — confirm (char select, map select)
- **R** — restart match (during end screen or bail mid-fight)

## Code layout

- `main.gd` — holds `CHARACTERS` dict + `MAPS` dict + screen state machine (char_select_p1 → char_select_p2 → map_select → countdown → fight → end) + chunk #4.
- `player.gd` — bulk of the D4 lesson. Holds chunks #1, #2, #3, #5, #6, #7.
- `projectile.gd` — projectile entity. Pre-given, no chunks.
- `final_challenge.gd` — 5th character slot. Three FC mirror tasks.

## Chunk map (matches BIBLE §4 D4 table)

| # | Where | What |
|---|---|---|
| 1 | `player.gd` top | Declare core props (`hp`, `max_hp`, `facing`) |
| 2 | `player.gd` top | Declare character-data props (`walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`) |
| 3 | `player.gd` `take_damage` | Method body: `hp -= amount`, set hit flash, update bar, die if `hp <= 0` |
| 4 | `main.gd` `start_match` | Two instances of `Player.tscn`, `setup()` each with chosen character + spawn pos |
| 5 | `player.gd` | Declare `state` var + write `set_state` helper (print + assign) |
| 6 | `player.gd` `_physics_process` | `match` statement for 6 states (**STRETCH** — biggest chunk) |
| 7 | `player.gd` `attack` | Method body branches on `attack_type` — melee = distance check + `take_damage`, projectile = `spawn_projectile` (**STRETCH**) |

## Common kid stuck-points (anticipated — log refinements after first camp)

1. **"My player won't jump"** → check `is_on_floor()` is true BEFORE applying `jump_impulse`, AND check the jump impulse is **negative** (Y goes up = -y in Godot — `velocity.y = -jump_impulse`).
2. **"Match statement does nothing"** → check indentation. Each case (`"idle":`, `"walk":`, etc.) must be indented one level beneath `match`, body indented one more.
3. **"Projectile doesn't hit opponent"** → check `Projectile.tscn` `collision_mask = 2` (player layer). Also confirm player is on layer 2.
4. **"I'm hitting myself with my projectile"** → check the `body == owner_player` early-return in `projectile.gd`'s `_on_body_entered`.
5. **"Both players move with the same keys"** → check `player_num` is being set in `setup()` AND `get_input_pressed` uses `"p%d_action"` format with `player_num` substituted.

## Tuning notes

All consts in `CHARACTERS` are feel-driven. Kids can swap numbers freely during build phase. User accepted "some characters may be broken, patch in class as sidebar." If Ninja's 10 dmg / 0.30 cd feels OP, slow her down or shrink her range. If Archer's 700 speed flat-arrow feels degenerate, drop to 500 or bump `projectile_gravity_scale` to 0.15.

Per-map platform tuning lives in `MAPS` dict — `[x, y, width, height, one_way]` tuples. Add/remove platforms by editing the list.

## Build commands

```powershell
.\build\build_templates.ps1 -Day Day4_Fighter_Game
```

Generates `dist/Day4_Fighter_Game_Template.zip` (kid scaffold, won't compile until chunks filled) + `dist/Day4_Fighter_Game_Complete.zip` (instructor reference, source of truth).

`.exe` export is manual via Godot's export dialog (BIBLE §11).

## Final Challenge framing

5th character slot — kid invents the whole thing. File ships with `CUSTOM_CHARACTER` dict + comment-pointers to the two other files they need to touch. Three holes:

- **FC-1** — fill `CUSTOM_CHARACTER` dict (mirror: `CHARACTERS` entries from morning, kid copies the shape).
- **FC-2** — register in `main.gd`'s `CHARACTERS` dict (one-liner in `_ready()`).
- **FC-3** — add `"custom":` case to `player.gd`'s `attack()` match. Free-form — examples in the file: swing twice, charge attack, self-heal, spread shot.

Uses everything from D4: dicts (FC-1), main.gd flow (FC-2), match statements + `take_damage`/`spawn_projectile` (FC-3).
