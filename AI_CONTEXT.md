# iCode GDScript Camp — AI Quick Context

This file gives an AI assistant enough context to help debug issues in the iCode GDScript camp. If you're an instructor: copy everything below this line and paste it into Claude or ChatGPT, then describe the bug.

---

## What this camp is

A 5-day Godot 4 / GDScript coding camp for ages 10–15 with no prior experience. Each day (D1–D4) students build one complete game from a scaffold. Day 5 is a creative showcase (Escape Simulator + rally racer customization, no new code).

GDScript is Python-flavored (similar syntax, different runtime). All code is GDScript — not C#, not Python.

---

## The 5 games

### Day 1 — Top-down racer (`Day1_Pong_Game/`)
- Single file: `main.gd`
- Concepts: variables, `if/elif/else`
- Kids declare car stats (speed, turn speed) and write the movement + boundary conditions

### Day 2 — Tile maze (`Day2_Maze_Game/`)
- Main file: `main.gd`; ghost AI in `ghost_personalities.gd`
- Concepts: `for` loops, intro functions
- Kids write the dot-collection loop, ghost movement step functions, and the game-over check
- Uses Godot's TileMapLayer for the maze grid; arrow keys only (no WASD)

### Day 3 — Base defense (`Day3_BaseDef_Game/`)
- Main file: `main.gd`; enemy scenes: `Enemy.tscn`; stretch: `endless_mode.gd`
- Concepts: functions (deep), lists (`Array`)
- Kids write: `spawn_enemy()`, `move_enemies()` (iterates a list), `check_collisions()`, `check_win()`
- Wave system: hardcoded `var waves = [(count, type), ...]`; SPACE triggers next wave

### Day 4 — 2-player fighter (`Day4_Fighter_Game/`)
- Two scripts: `main.gd` (game loop, CHARACTERS dict) + `player.gd` (per-player class)
- Concepts: objects (class-based), state machine
- `player.gd` extends `CharacterBody2D`; each player is an instance with its own `hp`, `state`, `attack_type`, etc.
- State machine in `_physics_process`: `idle → walk → jump → fall → attack → hit`
- Kids write chunks: declare vars, `take_damage()`, state-machine `if` blocks, `attack()` body
- 2-player on one keyboard: Player 1 = WASD + G; Player 2 = arrow keys + L
- Characters loaded from `CHARACTERS` dict in `main.gd` (knight, panda, wizard, robot)

### Day 5 — Rally racer + Escape Simulator (`Day5_Racing_Game/`)
- Files: `car.gd`, `track.gd`, `track_builder.gd`, `ghost.gd`, `hud.gd`, `main.gd`
- No student code chunks — customization only (tune `car_tune.json`, edit track)
- Escape Simulator: kids build escape rooms in the Steam game's built-in editor (separate from Godot)

---

## Scaffold pattern

D1–D4 game files mark student holes with comments:

```gdscript
# === KID CHUNK #3 — take_damage ===
#@todo
# student writes code here
#@end
```

Everything outside `#@todo` / `#@end` blocks is pre-given (instructor-written). Students only fill in the holes. Lines marked `# Pre-given:` inside a chunk are pre-written too — kids don't touch those either.

Two ZIP variants ship per day:
- **Template** — has the holes (what students work from)
- **Complete** — fully filled in (instructor answer key)

---

## GDScript cheat sheet

```gdscript
# Variables
var speed: float = 200.0
var name: String = "knight"
var hp: int = 100
var items: Array = []

# Functions
func take_damage(amount: int) -> void:
    hp -= amount

# Conditions
if hp <= 0:
    die()
elif hp < 20:
    flash_red()
else:
    pass

# For loop over array
for enemy in enemies:
    enemy.move()

# For loop with range
for i in range(5):
    print(i)   # 0 1 2 3 4

# Match (like switch)
match state:
    "idle":
        velocity.x = 0
    "walk":
        velocity.x = speed

# @onready — runs after the scene tree is ready
@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ColorRect = $HpBar/Fill

# extends — this script IS a node type
extends CharacterBody2D

# Signals
signal game_over
emit_signal("game_over")
```

### Key Godot built-ins kids use

| Symbol | What it does |
|--------|-------------|
| `_ready()` | Called once when the node enters the scene — initialization goes here |
| `_process(delta)` | Called every frame — use for visuals, timers, non-physics logic |
| `_physics_process(delta)` | Called every physics frame — use for movement, collisions |
| `move_and_slide()` | Moves a CharacterBody2D and handles collision response automatically |
| `is_on_floor()` | Returns true if the body is touching a floor surface |
| `get_tree().current_scene` | Returns the root node of the currently loaded scene |
| `queue_free()` | Deletes a node at the end of the current frame |
| `instantiate()` | Creates a new instance of a packed scene (like `new` in other languages) |
| `add_child(node)` | Adds a node to the scene tree as a child |

---

## Common errors and what they mean

| Error | Cause | Fix |
|-------|-------|-----|
| `IndentationError: unexpected indent` | Tab/space mismatch — Godot uses tabs | Delete the indent and retype it; don't copy-paste from a browser |
| `Invalid get index '...' on base 'Nil'` | An `@onready` node path is wrong — the node doesn't exist at that path | In the Godot editor, right-click the node in the Scene panel → "Copy Node Path"; paste into the script |
| `Nonexistent function 'foo' called on base '...'` | Typo in a function name — GDScript is case-sensitive | Check spelling and capitalization exactly |
| `parse error: expected ','` | Missing comma in an array `[]` or dict `{}` literal | Find the line, count the commas between items |
| `Input action not found: 'p1_jump'` | Action string not registered | Project → Project Settings → Input Map → add the action with exact spelling |
| `Cannot call function 'X' on null instance` | Accessing a node before `_ready()` runs, or `@onready` path is wrong | Move the call into `_ready()`, or verify the node path |
| `Attempt to call function 'X' in base 'null instance'` | Same as above — null node reference | Check that the node exists in the scene tree and the path matches |

### How to read Godot's error panel
Errors appear in the **Output** panel at the bottom of the editor. Each line shows:
```
ERROR: file.gd:42 — Invalid get index 'x' on base 'Nil'.
```
- The filename and line number tell you exactly where to look
- Click the error line in the Output panel to jump to that line in the script

---

## Where to look for a given bug

```
Student reports something is wrong
│
├─ Error message in Output panel?
│   └─ Yes → read file:line → check that line and the @onready/variable above it
│
├─ Game runs but behavior is wrong?
│   ├─ Physics / movement → check _physics_process() in the relevant .gd file
│   ├─ Enemy doesn't spawn → check spawn function + the waves list
│   ├─ HP bar doesn't update → check take_damage() → check hp_bar_fill.size.x line
│   └─ Input doesn't work → Project → Project Settings → Input Map → verify action name
│
├─ Two-player input crossed (P1 controls P2)?
│   └─ Check player_num passed to player.setup() in main.gd
│
└─ Godot editor confusion (node missing, scene won't run)?
    └─ Check Scene panel — every node the script references must exist there with the exact name
```

---

## File locations (D4 fighter — most complex day)

```
Day4_Fighter_Game/
  main.gd            ← CHARACTERS dict, fight_active flag, on_player_died()
  player.gd          ← per-player class: HP, state machine, take_damage(), attack()
  Player.tscn        ← CharacterBody2D scene (Sprite2D, HpBar/Fill children)
  Projectile.tscn    ← ranged attack projectile
  final_challenge.gd ← stretch goal: custom character
  INSTRUCTOR_NOTES.md ← per-chunk bug guide
```

The `CHARACTERS` dict in `main.gd` drives all per-character stats. If a character behaves wrong (wrong speed, wrong damage), check that dict first.

---

## Asking the AI for help

After pasting this file, describe the bug like this:

> "Student is on Day 3, Chunk #2. They wrote [code]. The error is [exact error text]. The expected behavior is [what should happen]."

Or:

> "The game runs but [specific visual/gameplay thing] is wrong. We're in [day folder]. Here is the relevant function: [paste the function]."

The more specific, the better. Include the actual code if you can.
