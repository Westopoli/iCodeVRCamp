# Day 4 — 2-Player Fighter (Smash Bros lite) — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 4 slide deck.
> Verified against `Day4_Fighter_Game/main.gd` + `player.gd` + `projectile.gd` +
> `final_challenge.gd` + `Main.tscn` + `Player.tscn` + `Projectile.tscn` on 2026-05-26.
> Reads top-to-bottom as the day's lesson flow.

## Table of contents

- **§1 Day narrative card** — year, iconic title, concepts introduced, GDScript-vs-Python card.
- **§2 Build narrative** — how the fighter is built: scene tree, file manifest, asset pack, state machine model, no-animations framing.
- **§3 Chunk table** — chunk ID → concept → file location → hole size, in BIBLE/lesson order.
- **§4 Pre-coding setup** — open project, open script, run, read errors (Day 1 walkthroughs reused) + char-select / map-select menu demo (instructor walks the game flow before chunks).
- **§5 Lesson chunks** — per-chunk slide source in BIBLE order. Concept → Goal → Board example → In-file location → As-typed code. Chunk #6 + chunk #7 include "After this chunk works" walkthroughs showing the fight loop come alive.
- **§6 Personalization layer** — "make it yours" end-of-day beat: tune stats, re-tint, swap sprite, edit map platforms, add a fifth ground-only map.
- **§7 Stretch goals — Final Challenge (`final_challenge.gd`)** — kid invents a 5th character. 3 mirror holes (FC-1..FC-3) that mirror chunks #1/#2/#4/#6/#7. Ends with the "play your custom character" enable step.
- **§8 Asset / atlas reference** — Kenney Pixel Platformer pack, default sprite picks, modulate tints, character stats, map platform layouts.
- **§9 Verification checklist** — internal sanity; re-run if `main.gd` or `player.gd` or `final_challenge.gd` changes.

---

## 1. Day narrative card

- **Year**: 1999 / early 2000s
- **Iconic title**: **Super Smash Bros.** (Nintendo, N64, 1999) — 2D platformer fighter, HP-bar / percent damage, multiple characters on a single screen, multi-map.
- **Genre today**: 2D platformer fighter — two humans, one keyboard, last fighter standing wins.
- **Concepts introduced**: **Objects** + **State**. A class describes what something *is* (its data) and what it *does* (its methods). A state variable lets one object behave differently in different situations.
- **Why this game today**: the Player is the perfect classroom object. Each player is a fresh **instance** of the same `player.gd` class, with the same properties and methods — but P1 and P2 read different inputs, pick different characters, hold different HP. State (`idle / walk / jump / fall / attack / hit`) is visible: kids see the print logs change as their character moves, and they wrote the `match state:` block themselves.

### GDScript vs Python (Day 4 slide — pull verbatim into deck)

```
Python:                             GDScript:
class Player:                       extends CharacterBody2D
    def __init__(self):
        self.hp = 100                   var hp = 100
        self.facing = 1                 var facing = 1
    def take_damage(self, n):       func take_damage(n):
        self.hp -= n                    hp -= n
```

**Takeaway line**: "GDScript classes are *almost* identical to Python. The big differences: no `self.` everywhere, no `__init__` (vars at the top of the file are the constructor), and we say `extends <ParentClass>` instead of `class Foo(Parent):`."

### Note on how Godot "instances" a class

In Python: `dog = Dog()` makes one instance. In Godot, we make a **PackedScene** in the editor (e.g., `Player.tscn` — a scene that has the `player.gd` script attached), then in code: `var p = PLAYER_SCENE.instantiate()` makes a fresh copy with its own state. Chunk #4 is exactly this — two `instantiate()` calls, two players.

---

## 2. Build narrative — how the fighter was built

The game is a side-view 2D platformer with **gravity**. Each player is a `CharacterBody2D` that walks left/right, jumps, falls, and attacks. The whole class file (`player.gd`) is one **object** — `hp`, `facing`, `walk_speed`, `attack_type` are properties; `take_damage()`, `attack()`, `set_state()` are methods. When P1 + P2 are spawned by `start_match()`, both run the *same* script — but P1 reads `p1_left/right/jump/attack` inputs and P2 reads `p2_*` inputs (set per-instance via `player_num`).

The fight runs on a **state machine** — `state` is one of six strings (`idle / walk / jump / fall / attack / hit`). A pre-given `set_state(new)` helper just stores the new value and prints a debug line; the actual per-state behaviour lives in chunk #6, a `match state:` block in `_physics_process`. Per state, the player accepts different inputs and applies different physics.

**Animations are explicitly out of scope** (BIBLE §6 D4 D7 lock). The Kenney Pixel Platformer sprite stays static; `state` is purely a logic concept, not a visual one. Hit detection flashes red via `Modulate`; melee attacks draw a brief white rectangle for the swing.

**4 characters** (Knight melee-slow / Ninja melee-fast / Mage projectile-arc / Archer projectile-fast) are defined as data in `CHARACTERS` dict at the top of `main.gd`. **3 maps** (Battlefield / Final Destination / Pokémon Stadium) — same — in `MAPS` dict. Procedurally built at match start (no per-map `.tscn` files). One-way platforms (jump-up-through, land-on-top) are a Godot built-in via `CollisionShape2D.one_way_collision`.

**Controls**: P1 = WASD + **F** (attack). P2 = Arrow keys + **RShift** (attack). **Space** confirms in menus. **R** restarts back to character select.

### Camp narrative arc — where Day 4 sits

D1 Pong (1972) → D2 Pac-Man (1980) → D3 Tower Defense (90s-2000s) → **D4 Smash Bros (1999)** → D5 VR / Racing (modern). Day 4 is the 1999 N64 era — 2D fighters, multi-character rosters, HP bars, multi-map.

### Scene tree (Main.tscn)

```
Main (Node2D) — script: main.gd
├── Background      (ColorRect)   1280×720, sky-blue (0.4, 0.7, 0.95)
├── MapRoot         (Node2D)      platforms spawned at runtime by build_map()
├── Projectiles     (Node2D)      Projectile.tscn instances spawn here
└── UI              (CanvasLayer)
    ├── CharSelectPanel  + TitleLabel  (visible during char_select_p1 / _p2)
    ├── MapSelectPanel   + MapTitle    (visible during map_select)
    ├── CountdownLabel                  ("3" / "2" / "1" / "GO!")
    ├── WinLabel                        ("P1 WINS!" / "P2 WINS!" at end)
    └── HudLabel                        ("Knight vs Ninja on Battlefield")
```

`Player.tscn` (instantiated twice at match start):

```
Player (CharacterBody2D) — script: player.gd
├── Sprite2D                    Kenney character tile (e.g., tile_0000.png)
├── CollisionShape2D            RectangleShape2D 24×28
└── HpBar (Node2D)
    └── Fill (ColorRect)        80×6, width scales by hp/max_hp
```

`Projectile.tscn` (spawned by Mage/Archer attacks):

```
Projectile (Area2D) — script: projectile.gd
├── Sprite2D                    projectile tile
└── CollisionShape2D            RectangleShape2D 16×16
```

### File manifest

| File | Role | Kid edits? |
|---|---|---|
| `project.godot` | Window 1280×720; input map for `p1_left/right/jump/down/attack` + `p2_*`, `confirm` (Space), `restart` (R) | No |
| `Main.tscn` | Scene tree above | No (until §6 personalization, where they edit MAPS) |
| `main.gd` | Game-flow controller. `CHARACTERS` dict + `MAPS` dict + screen state machine + chunk #4 (`start_match` instantiate ×2) | **Yes — chunk #4 only** |
| `Player.tscn` | Player scene (CharacterBody2D + Sprite + CollisionShape + HpBar) | No |
| `player.gd` | Per-player script — chunks #1, #2, #3, #5, #6, #7 live here | **Yes — most of the day** |
| `Projectile.tscn` + `projectile.gd` | Pre-given projectile entity. Used by Mage + Archer attacks. | No (read-only) |
| `final_challenge.gd` | Final Challenge — kid invents a 5th character (FC-1, FC-2, FC-3) | **Yes — FC opt-in** |
| `INSTRUCTOR_NOTES.md` | Instructor reference | No |
| `assets/kenney_pp/characters/`, `tiles/`, `backgrounds/` | Kenney Pixel Platformer pack | No (kid swaps sprites in §6) |

### Asset pack

- **Pack**: Kenney **Pixel Platformer** — kenney.nl, CC0 (no attribution required).
- **Filename convention**: `characters/tile_NNNN.png` (27 sprites), `tiles/tile_NNNN.png` (180 sprites).
- **Default character picks**: Knight `tile_0000.png`, Ninja `tile_0001.png`, Mage `tile_0002.png`, Archer `tile_0003.png` (semi-arbitrary — see §8).
- **Sprite-vs-archetype mismatch noted**: the Kenney pack ships cute monsters, not knight/ninja/mage archetypes. Names kept because the **archetype identity** (melee-fast vs melee-slow vs projectile-arc vs projectile-fast) is what kids care about; visual differentiation comes from per-character `Modulate` tint.

### Sim / tuning story

**No Python sim for D4** (asymmetric multi-stat balance not optimizer-friendly; 2P symmetric fighter is feel-driven). Stats are best-guess from BIBLE D4 D4 lock; balance gets dialled in via real playtest with kids, not pre-camp. Slides should call this out plainly: "we did not balance-test this morning; if your favourite character is too strong or too weak, **that's the personalization beat** — tweak the numbers and try again."

---

## 3. Chunk table — verified against code (refreshed 2026-05-30 under R1 + R2 + R5)

In lesson order (BIBLE §4 D4 order: 1 → 2 → 3 → 4 → 5 → 6 → 7). Chunk #6 is now an R5 partial-section hole — the `match` dispatcher + per-branch velocity + `attack`/`hit` exits are pre-given; the kid fills four sub-holes (#6a/#6b/#6c/#6d) holding only the state-transition `if` blocks.

| # | Concept | File location | Kid LoC | Hole size |
|---|---|---|---|---|
| #1 | Object properties — core (hp, facing) | `player.gd:48-52` | 3 | small |
| #2 | Object properties — character data (speed, attack stats) | `player.gd:55-61` | 5 | small |
| #3 | Method — `take_damage(amount)` | `player.gd:169-176` | 6 | medium |
| #4 | Two instances of the same class | `main.gd:205-212` | 6 | medium |
| #5 | State variable + `set_state()` helper | `player.gd:64-72` | 6 | medium |
| #6a | State exits — `idle` → walk / jump | `player.gd:116-122` | 5 | small |
| #6b | State exits — `walk` → idle / jump | `player.gd:126-132` | 5 | small |
| #6c | State exits — `jump` → fall | `player.gd:136-139` | 2 | tiny |
| #6d | State exits — `fall` → idle | `player.gd:143-146` | 2 | tiny |
| #7 | `attack()` body with `match attack_type:` | `player.gd:180-199` | 15 | medium |

**Total**: 10 `#@todo` sub-holes across **7 conceptual chunks** (BIBLE §4 D4 table). Morning kid LoC ≈ **55**.

**Notes (R1 + R2 + R5 compliance):**
- No mid-day stretch tags (R1). `(STRETCH)` banner on #6 removed.
- Every kid line is single-purpose, C-style (R2 D3+ ceiling: nested calls allowed, but the ternary `velocity.x = walk_speed * (-1 if ... else 1 if ... else 0)` lines + the compound `if` in `attack()` were exploded into named-variable / named-bool form).
- A pre-given helper `get_move_direction()` (`player.gd:82-87`) replaces the four-way ternary used inside the original match branches.
- #6 is an R5 partial-section hole (per D3 #6 precedent) — `match` dispatcher + branch velocity calcs + attack/hit exits + the universal "attack input" check are pre-given; kid fills four small sub-holes per state.
- `set_state()` is part of chunk #5 — between chunks #3 and #5 the file won't run (take_damage calls a not-yet-defined function). Slide deck flags this in the Chunk #3 pre-cursor "pieces you'll wire through #5" beat.

---

## 4. Pre-coding setup

> Day 1 walkthroughs A/B/C/D (open project, open script, run, read errors) reused — re-targeted to `Day4_Fighter_Game/`. Two D4-specific moves before chunks start.

### Instructor demo — Walk the menu flow

> Run this **before** chunks start. Even though the fight loop is empty until #6 + #7 are filled, the menu screens (char select → map select → countdown → fight → end) already work. Shows kids the *shape* of the game they're about to make playable.

1. Open the project (Day 1 Walkthrough A reapplied to `Day4_Fighter_Game`).
2. Press **F5** to run.
3. Char-select panel appears: "P1 — pick your fighter: 1 = Knight  2 = Ninja  3 = Mage  4 = Archer".
4. Press **1** — P1 is Knight. Panel updates: "P2 — pick your fighter".
5. Press **2** — P2 is Ninja. Panel switches to map select.
6. Press **1** — Battlefield. Countdown: "3... 2... 1... GO!"
7. Fight screen appears. **Knight and Ninja DO NOT spawn yet** — chunk #4 is empty. (Once the kid fills #4, two characters appear here.)
8. Press **R** at any time to restart back to char select.

### Instructor demo — Read the `CHARACTERS` dict

> Show this in the script editor before chunk #1. Tells kids "the four characters are *data* sitting at the top of `main.gd` — every property your Player object needs to know about itself is in there."

1. Open `main.gd` (Day 1 Walkthrough B).
2. Scroll to lines 6-59 — the `CHARACTERS` dict.
3. Point out: each character has 11 properties. `display_name`, `sprite`, `tint`, `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`, `attack_range`, `projectile_speed`, `projectile_gravity_scale`.
4. Connect to chunk #1 + #2: "Today you're going to declare these same properties **on the Player class** so each player object remembers them."

---

## 5. Lesson chunks (BIBLE order)

### Chunk #1 — Object properties (core)

- **Concept**: An object's **properties** are the variables that live on the object. Each instance gets its own copy. In GDScript, properties are just `var` declarations at the top of the script file.
- **What is `facing`?** A single integer that records which way the panda is looking. `facing = 1` → looks right; `facing = -1` → looks left. The pre-given `_physics_process` flips `facing` automatically when the kid presses left or right (`player.gd:89-93`), and uses it for sprite-flip + projectile-aim. **The kid only declares it; the file already updates it every frame.**
- **Goal**: Declare the three core properties every Player needs to track its own state: `hp` (start at 100), `max_hp` (also 100 — used to scale the HP bar), and `facing` (start at 1 = looking right).
- **Board example**:
  ```gdscript
  # Inside a class:
  var name = "Alex"
  var age = 12
  ```
- **In-file location**: `player.gd:48-52`, under `# === KID CHUNK #1 — declare core props ===`. Right at the top of the script, alongside the pre-given `attack_cooldown_timer` etc.
- **As-typed code**:
  ```gdscript
  var hp: int = 100
  var max_hp: int = 100
  var facing: int = 1
  ```
- **Action-slide prose (top)**: *"Declare the three things every Player needs to remember about itself: `hp` (start at 100), `max_hp` (also 100, for the HP bar), and `facing` (start at 1 = looking right)."*

---

### Chunk #2 — Object properties (character-data driven)

- **Concept**: An object's properties can come from a configuration dictionary — not every property has to be hard-coded. The `setup()` method in `player.gd` reads from `MAIN.CHARACTERS[char_name]` and copies those values into per-player vars.
- **Where do the Knight stats come from?** Open `main.gd` and scroll to `CHARACTERS["knight"]` (`main.gd:6-59`). The five property names below are the same five keys you'll see in that dict. Defaults in chunk #2 are the Knight's values — `setup()` overwrites them with whatever character the player picked.
- **Goal**: Declare the five properties that mirror the character config: `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`.
- **Board example**:
  ```gdscript
  var hunger = 100
  var bark_volume = 5
  ```
- **In-file location**: `player.gd:55-61`, under `# === KID CHUNK #2 — declare character-data props ===`. Right below chunk #1.
- **As-typed code**:
  ```gdscript
  var walk_speed: float = 220.0
  var jump_impulse: float = 520.0
  var attack_type: String = "melee"
  var attack_damage: int = 18
  var attack_cooldown: float = 0.55
  ```
- **Action-slide prose (top)**: *"Declare five more properties — `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown` — with Knight's stats as defaults (see `main.gd:6-59 CHARACTERS[\"knight\"]`). `setup()` overwrites them with the picked character's stats."*

---

### Chunk #3 — Method: `take_damage(amount)`

- **Concept**: A **method** is a function defined inside a class. It can read and update the object's own properties. Calling `player1.take_damage(10)` runs this method on `player1` — `hp` inside refers to `player1`'s hp.
- **Pieces you'll use (you already have or will write)**:
  - `hp` — chunk #1 property.
  - `hit_flash_timer` — pre-given (`player.gd:11`). Setting it to a positive number makes the sprite flash red for that many seconds.
  - `set_state("hit")` — chunk #5 helper. **You haven't written it yet** — that means the file won't actually run between chunks #3 and #5. Type the line; save; move on to #4.
  - `hp_bar_fill` — pre-given `@onready` (`player.gd:15`). It's a `ColorRect`; the kid changes its `.size.x` to shrink the bar.
  - `die()` — pre-given (`player.gd:206-209`). Hides the sprite and tells `MAIN` that this player lost.
- **Goal**: Fill the empty `take_damage(amount)` body so opponents can actually hurt each other. Subtract `amount` from `hp`, start the hit flash, switch state to `"hit"`, shrink the HP bar to match `hp/max_hp`, and call `die()` if HP dropped to zero.
- **Board example**:
  ```gdscript
  func feed():
      hunger -= 10
  ```
- **In-file location**: `player.gd:169-176`, inside the empty `func take_damage(amount: int) -> void:` body.
- **As-typed code**:
  ```gdscript
  hp -= amount
  hit_flash_timer = 0.2
  set_state("hit")
  hp_bar_fill.size.x = (float(hp) / max_hp) * 80.0   # bar is 80px wide
  if hp <= 0:
      die()
  ```
- **Action-slide prose (top)**: *"Subtract `amount` from `hp`, set `hit_flash_timer` to 0.2, switch state to `\"hit\"`, shrink the HP bar to match the new `hp/max_hp` ratio, and call `die()` if `hp` dropped to zero."*

---

### Chunk #4 — Two instances of the same class

- **Concept**: A class is a *blueprint*; an **instance** is one actual object built from that blueprint. We can build many instances from the same class, each with its own state. `Player.tscn` is the Godot way of packaging a class — `PLAYER_SCENE.instantiate()` builds one fresh instance.
- **Goal**: When the match starts, build **two Player instances** — one for P1, one for P2 — and place them at opposite ends of the map. Each is the same class, but `setup()` configures them with different `player_num` (1 vs 2), different characters (P1's pick vs P2's pick), and different spawn positions. Without this chunk, the fight screen is just an empty map: no fighters appear.
- **Board example**:
  ```gdscript
  var dog1 = Dog.new()
  var dog2 = Dog.new()
  dog1.feed()
  dog2.bark()
  ```
- **In-file location**: `main.gd:205-212`, inside `start_match(p1_char, p2_char, map_id)`, under `# === KID CHUNK #4 — TWO INSTANCES ===`.
- **As-typed code**:
  ```gdscript
  player1 = PLAYER_SCENE.instantiate()
  add_child(player1)
  player1.setup(1, p1_char, Vector2(200, 500))
  player2 = PLAYER_SCENE.instantiate()
  add_child(player2)
  player2.setup(2, p2_char, Vector2(1080, 500))
  ```
- **Action-slide prose (top)**: *"Instantiate the Player scene twice. Add each to the tree, then call `setup()` on each — P1 at `Vector2(200, 500)`, P2 at `Vector2(1080, 500)`."*

> **After this chunk works**: run F5, pick characters + map → the countdown plays and both characters appear at opposite ends of the map. They don't move yet (chunk #6 is still empty) — but you can see them standing there.

---

### Chunk #5 — State variable + `set_state()` helper

- **Concept**: A **state machine** is a pattern where an object remembers what mode it's in (a string or number), and behaves differently based on that mode. The state itself is just a regular property — but it's the *anchor* for chunk #6's branching logic.
- **Goal**: Declare a `state` property (starts at `"idle"`) and write a `set_state(new_state)` helper. The helper does three things: skip if the new state matches the current one, print the new state so kids can watch transitions in the Output panel, then update `state`.
- **Board example**:
  ```gdscript
  var state = "asleep"

  func set_state(new):
      if new == state:
          return
      print(new)
      state = new
  ```
- **In-file location**: `player.gd:64-72`, under `# === KID CHUNK #5 — state var + set_state helper ===`.
- **As-typed code**:
  ```gdscript
  var state: String = "idle"

  func set_state(new_state: String) -> void:
      if new_state == state:
          return
      print(new_state)
      state = new_state
  ```
- **Action-slide prose (top)**: *"Declare `state` (start at `\"idle\"`). In `set_state(new_state)`: bail if it matches the current state, otherwise print `new_state` and update `state`."*

---

### Chunk #6 — State machine in `_physics_process` (R5 partial — 4 sub-holes)

- **Concept**: A `match` statement reads a variable and runs the branch whose pattern matches. We use it on `state` to give each mode (`idle / walk / jump / fall / attack / hit`) its own per-frame behaviour. **This is the chunk that decides when one state becomes another.**
- **Hole type**: **R5 partial-section hole — 4 sub-holes.** The `match state:` dispatcher, each branch's velocity calculation, the `attack` and `hit` exit logic, and the universal "attack input" check are pre-given. The kid fills only the small `if`-blocks that decide WHICH state comes next (#6a–#6d). Per BIBLE R2, the kid never writes a ternary `velocity.x = walk_speed * (-1 if ... else ...)` one-liner — the pre-given `get_move_direction()` helper (`player.gd:82-87`) returns -1/0/1 for left/none/right, and the branch velocity becomes a single `velocity.x = walk_speed * get_move_direction()` line (pre-given).
- **Pieces you'll use (all pre-given)**:
  - `get_move_direction()` — returns -1/0/1 for left/none/right (defined by us in `player.gd:82-87`).
  - `get_input_just_pressed("jump")` — true on the frame the jump key was first pressed.
  - `is_on_floor()` — Godot built-in; true if the player is standing on a platform.
  - `set_state("name")` — your chunk #5 helper.
  - `velocity.y = -jump_impulse` — launches the player upward (negative Y = up in Godot 2D).
- **Board example** (kid sees this shape for their `if` blocks):
  ```gdscript
  match state:
      "asleep":
          if loud_noise():
              set_state("awake")
      "awake":
          if tired:
              set_state("asleep")
  ```
- **In-file location**: pre-given block at `player.gd:109-159`, inside `_physics_process(delta)`. Four kid sub-holes:
  - **#6a** `idle` exits: `player.gd:116-122` (5 kid LoC).
  - **#6b** `walk` exits: `player.gd:126-132` (5 kid LoC).
  - **#6c** `jump` exit: `player.gd:136-139` (2 kid LoC).
  - **#6d** `fall` exit: `player.gd:143-146` (2 kid LoC).
- **Full block (pre-given + kid sub-holes), as it lives in the Complete ZIP**:
  ```gdscript
  # Pre-given: the match dispatcher + per-branch velocity + attack / hit exits.
  # Kid fills (4 sub-holes): the `if` blocks that decide WHICH state comes next.
  match state:
      "idle":
          velocity.x = 0
          # TODO #6a — idle exits: switch to walk on movement, jump on jump-key.
          if get_move_direction() != 0:
              set_state("walk")
          if get_input_just_pressed("jump") and is_on_floor():
              velocity.y = -jump_impulse
              set_state("jump")
      "walk":
          velocity.x = walk_speed * get_move_direction()
          # TODO #6b — walk exits: back to idle when no movement, up to jump on jump-key.
          if get_move_direction() == 0:
              set_state("idle")
          if get_input_just_pressed("jump") and is_on_floor():
              velocity.y = -jump_impulse
              set_state("jump")
      "jump":
          velocity.x = walk_speed * get_move_direction() * 0.85
          # TODO #6c — jump exit: when upward velocity runs out, switch to fall.
          if velocity.y > 0:
              set_state("fall")
      "fall":
          velocity.x = walk_speed * get_move_direction() * 0.85
          # TODO #6d — fall exit: when the player lands, switch to idle.
          if is_on_floor():
              set_state("idle")
      "attack":
          # Pre-given: keep moving while attacking, exit when cooldown done.
          var ground_factor: float = 1.0 if is_on_floor() else 0.85
          velocity.x = walk_speed * get_move_direction() * ground_factor
          if attack_cooldown_timer <= 0.0:
              set_state("idle" if is_on_floor() else "fall")
      "hit":
          # Pre-given: frozen while flashing, then exit.
          velocity.x = 0
          if hit_flash_timer <= 0.0:
              set_state("idle" if is_on_floor() else "fall")

  # Pre-given: attack input is universal across idle / walk / jump / fall.
  if state != "attack" and state != "hit":
      if get_input_just_pressed("attack") and attack_cooldown_timer <= 0.0:
          attack()
          set_state("attack")
  ```
- **Kid types in #6a (between `#@todo`/`#@end` only — 5 lines)**:
  ```gdscript
  if get_move_direction() != 0:
      set_state("walk")
  if get_input_just_pressed("jump") and is_on_floor():
      velocity.y = -jump_impulse
      set_state("jump")
  ```
- **Kid types in #6b (5 lines)**:
  ```gdscript
  if get_move_direction() == 0:
      set_state("idle")
  if get_input_just_pressed("jump") and is_on_floor():
      velocity.y = -jump_impulse
      set_state("jump")
  ```
- **Kid types in #6c (2 lines)**:
  ```gdscript
  if velocity.y > 0:
      set_state("fall")
  ```
- **Kid types in #6d (2 lines)**:
  ```gdscript
  if is_on_floor():
      set_state("idle")
  ```
- **Action-slide prose (top, one slide per sub-hole — short imperatives)**:
  - **#6a**: *"Inside the `idle` branch: switch to `\"walk\"` when `get_move_direction()` is non-zero, and switch to `\"jump\"` (with upward `velocity.y`) when jump is pressed on the floor."*
  - **#6b**: *"Inside the `walk` branch: switch back to `\"idle\"` when `get_move_direction()` is zero, and switch to `\"jump\"` (with upward `velocity.y`) when jump is pressed on the floor."*
  - **#6c**: *"Inside the `jump` branch: when `velocity.y > 0` (upward velocity has run out), switch to `\"fall\"`."*
  - **#6d**: *"Inside the `fall` branch: when `is_on_floor()` is true (player has landed), switch back to `\"idle\"`."*

> **After this chunk works**: characters walk + jump + fall correctly. Attack key triggers the `attack` state (via the pre-given universal attack-input check) but doesn't damage anything yet (that's #7). Hit state freezes the player briefly after taking damage. Open the Output panel during gameplay to see state names print as transitions happen.

---

### Chunk #7 — `attack()` body

- **Concept**: A method can branch on one of its own object's properties. `match attack_type` lets a single `attack()` method handle both melee (Knight, Ninja) and projectile (Mage, Archer) attacks — each character picks which branch via `attack_type`.
- **Pieces you'll use (all pre-given)**:
  - `attack_cooldown_timer` — pre-given var (`player.gd:10`). Counts down in `_physics_process`; while it's > 0 the attack key can't re-fire.
  - `melee_swing_timer` — pre-given var (`player.gd:12`). Setting it to a positive number triggers the white swing-rectangle draw for that many seconds.
  - `queue_redraw()` — Godot built-in; asks the engine to call `_draw()` next frame.
  - `get_opponent()` — pre-given (`player.gd:193-194`). Returns the OTHER player.
  - `spawn_projectile()` — pre-given (`player.gd:182-191`). Fires one Projectile in the `facing` direction.
- **Goal**: Fill the empty `attack()` body. Start the cooldown timer. Then `match attack_type:` — melee branch does the swing rectangle and damages the opponent (only if they exist, aren't dead, and are in range + facing direction + same height). Projectile branch just spawns a projectile.
- **No wicked one-liners (BIBLE R2)**: the old in-range / facing / height check was a three-condition `if` on one line. The kid splits it into three named booleans, then a clean `if a and b and c:`. Two early-`return`s replace the compound `opponent != null and not opponent.is_dead()` check.
- **Board example**:
  ```gdscript
  func bark():
      match volume:
          "loud":
              wake_neighbours()
          "soft":
              annoy_cat()
  ```
- **In-file location**: `player.gd:180-199`, inside `func attack() -> void:`, under `# === KID CHUNK #7 — attack ===`.
- **As-typed code**:
  ```gdscript
  attack_cooldown_timer = attack_cooldown
  match attack_type:
      "melee":
          melee_swing_timer = 0.15
          queue_redraw()
          var opponent = get_opponent()
          if opponent == null:
              return
          if opponent.is_dead():
              return
          var to_opp = opponent.position - position
          var in_range = abs(to_opp.x) <= character_data["attack_range"]
          var facing_opponent = sign(to_opp.x) == facing
          var same_height = abs(to_opp.y) <= 60
          if in_range and facing_opponent and same_height:
              opponent.take_damage(attack_damage)
      "projectile":
          spawn_projectile()
  ```
- **Action-slide prose (top)**: *"Start the cooldown timer, then `match attack_type:` — `\"melee\"` does the swing-rectangle and damages an opponent who's in range + facing + same height; `\"projectile\"` calls `spawn_projectile()`."*

> **After this chunk works**: Knight and Ninja's melee swings damage the opponent on contact. Mage's fireball arcs in a slow gravity-affected curve; Archer's arrow flies fast and straight. HP bars shrink, hit flashes fire, eventually somebody hits 0 HP → WinLabel appears → R or 4-second auto-restart back to char select. **The fight loop is now complete — the game is a game.**

---

## 6. Personalization layer ("make it yours")

End-of-day beat after all morning chunks. Each beat = one walkthrough.

### Beat 1 — Tune a character's stats

> "Make Knight overpowered" or "make Archer ridiculous."

1. Open `main.gd`.
2. Scroll to lines 6-59 — find the `CHARACTERS` dict.
3. Pick a character. Change any value:
   - `"walk_speed"` — higher = faster
   - `"jump_impulse"` — higher = jumps higher
   - `"attack_damage"` — higher = bigger hits
   - `"attack_cooldown"` — lower = faster attacks
   - `"attack_range"` (melee) — higher = longer reach
   - `"projectile_speed"` (projectile) — higher = faster shots
4. Save (Ctrl+S), F5, play.

### Beat 2 — Re-tint a character with Modulate

1. Open `main.gd` lines 6-59.
2. Find the character's `"tint": Color(R, G, B)` row.
3. Pick new RGB values (0.0 to 1.0). Example: `Color(1.0, 0.4, 0.4)` (red Knight) or `Color(0.4, 1.0, 0.4)` (green Ninja).
4. Save, F5 — your fighter is recoloured.

### Beat 3 — Swap a character's sprite

> Try a different Kenney character.

1. In the FileSystem panel, open `assets/kenney_pp/characters/`.
2. Browse `tile_0004.png`, `tile_0005.png`, etc. Pick one you like.
3. Open `main.gd` lines 6-59.
4. Change the character's `"sprite": "res://assets/kenney_pp/characters/tile_NNNN.png"` to your new tile.
5. Save, F5.

### Beat 4 — Edit a map's platform layout

1. Open `main.gd` lines 61-85 — find the `MAPS` dict.
2. Pick a map (e.g., `pokemon_stadium`). The `platforms` array holds `[x, y, width, height, one_way]` entries.
3. Add a new platform: `[600, 320, 100, 16, true]` (a small one-way platform at centre).
4. Save, F5. Pick that map. Your platform appears.

### Beat 5 — Add a fifth map

1. In the `MAPS` dict (lines 61-85), add a new key:
   ```gdscript
   "my_map": {
       "display_name": "My Map",
       "platforms": [
           [0,    600, 1280, 120, false],
           [400,  450, 150,  16,  true],
           [800,  450, 150,  16,  true],
       ],
   },
   ```
2. Open `_unhandled_input` (around line 177-179) — find the `maps = [...]` array.
3. Add `"my_map"` to the list. Update the map-select panel text to include `4 = My Map`.
4. Save, F5.

### Beat 6 (stretch) — Take on the Final Challenge

Open `final_challenge.gd` and invent your own 5th character. See §7.

---

## 7. Stretch goals — Final Challenge (`final_challenge.gd`)

> **What "stretch goals" means in this camp**: every day ends with a Final Challenge file. The FC tasks are **reworded versions of the morning chunks** — same concepts, new context. Repetition is the point: every FC hole drives a morning concept deeper, no new ideas required.

**File**: `final_challenge.gd`.
**Payoff**: invent and play your own 5th character. Pick any sprite, any stats, any attack behaviour. Optionally: a weird gimmick (double-attack, charge-attack, self-heal, 3-projectile spread — whatever you can imagine).
**Hint level**: half-guided. The file's comments tell you *what* to do; the kid figures out *how* using the morning's patterns. Slides show the mirror map but should NOT show verbatim code (show-vs-copy rule).

### Mirror map

| FC hole | Mirrors morning chunks | Concept practiced |
|---|---|---|
| FC-1 | #1 + #2 (property declarations) | Build a dict full of property values for a new character |
| FC-2 | #4 (register an instance / hook into existing system) | Add your character into `main.gd`'s `CHARACTERS` dict so the game knows about it |
| FC-3 | #6 + #7 (`match` branches + `attack()` body) | Add a new `"custom"` case to the `attack()` match statement |

### Hole FC-1 — Fill the `CUSTOM_CHARACTER` stats dict

- **Mirrors**: TODO #1 + TODO #2.
- **Goal**: Fill the empty `CUSTOM_CHARACTER` dict at the top of `final_challenge.gd` with stats for *your* character. Pick a sprite from `assets/kenney_pp/characters/` (try `tile_0004.png` and up — the morning's defaults go 0000-0003), a tint colour, walk speed, jump impulse, and attack stats. Pick `"attack_type": "custom"` so chunk FC-3's new match case takes over instead of melee/projectile.
- **Expected solution** (one possible shape):
  ```gdscript
  const CUSTOM_CHARACTER := {
      "display_name": "MyCharacter",
      "sprite": "res://assets/kenney_pp/characters/tile_0004.png",
      "tint": Color(1, 1, 1),
      "walk_speed": 250.0,
      "jump_impulse": 540.0,
      "attack_type": "custom",
      "attack_damage": 12,
      "attack_cooldown": 0.6,
      "attack_range": 0.0,
      "projectile_speed": 0.0,
      "projectile_gravity_scale": 0.0,
  }
  ```

### Hole FC-2 — Register your character in `CHARACTERS`

- **Mirrors**: TODO #4 (hooking a new instance into the existing system).
- **Goal**: Edit `main.gd` so the game knows about your custom character. Best place: in `main.gd`'s `_ready()` *after* the `CHARACTERS` const is defined, add a line `CHARACTERS["custom"] = CUSTOM_CHARACTER` (where `CUSTOM_CHARACTER` comes from `final_challenge.gd`). You'll also want to update the char-select panel text to show key **5** = your character's name.
- **Expected shape** (one possible solution):
  ```gdscript
  # In main.gd _ready(), after CHARACTERS is defined:
  CHARACTERS["custom"] = CUSTOM_CHARACTER
  # Then update the keys array in _unhandled_input to include "custom":
  var keys = ["knight", "ninja", "mage", "archer", "custom"]
  # And add "5 = MyCharacter" to the title_label text.
  ```

### Hole FC-3 — Add the `"custom":` branch in `attack()`

- **Mirrors**: TODO #6 (`match` branches) + TODO #7 (`attack()` body).
- **Goal**: In `player.gd`'s `attack()` function, find the `match attack_type:` statement. Add a new branch for `"custom":`. Inside, write *whatever you want* — the kid invents the behaviour. Examples in the FC file: swing twice, charge attack, self-heal instead of damage, shoot 3 projectiles in a spread.
- **Patterns the kid already knows** (from the morning):
  - `opponent.take_damage(N)` — deal damage to the other player.
  - `spawn_projectile()` — fire one projectile.
  - `hp += N` — heal yourself.
  - `melee_swing_timer = 0.15; queue_redraw()` — draw the white melee arc.
  - Multiple actions per attack (e.g., damage opponent twice, or spawn 3 projectiles with different facing offsets).
- **Expected solution**: anything that runs. No fixed shape — this is the creativity beat.

### Enable your custom character

1. Save `final_challenge.gd` (FC-1 done).
2. Save `main.gd` (FC-2 done).
3. Save `player.gd` (FC-3 done).
4. Press **F5**. Char select shows your new key (likely 5). Pick it for P1, pick anything for P2, pick a map, fight.

---

## 8. Asset / atlas reference

- **Pack**: Kenney **Pixel Platformer** — kenney.nl, CC0.
- **Character sprites**: `assets/kenney_pp/characters/tile_NNNN.png` (27 sprites, NNNN = 0000-0026).
- **Tile sprites** (used for platforms/scenery if needed): `assets/kenney_pp/tiles/tile_NNNN.png` (180 sprites).
- **Projectile sprite**: `assets/kenney_pp/tiles/tile_0151.png` (pre-given in `Projectile.tscn`).

### Default character stats (in `main.gd` `CHARACTERS` dict)

| Character | Sprite | Tint | Type | Walk | Jump | Damage | Cooldown | Range / Proj-Speed |
|---|---|---|---|---|---|---|---|---|
| Knight | `tile_0000.png` | `(0.7, 0.85, 1.0)` blue | Melee | 220 | 520 | 18 | 0.55 s | 70 px |
| Ninja | `tile_0001.png` | `(1.0, 0.85, 0.85)` pink | Melee | 320 | 560 | 10 | 0.30 s | 55 px |
| Mage | `tile_0002.png` | `(0.9, 0.7, 1.0)` purple | Projectile | 240 | 500 | 16 | 0.80 s | 380 px/s, grav 1.0 |
| Archer | `tile_0003.png` | `(0.85, 1.0, 0.85)` green | Projectile | 280 | 520 | 8 | 0.45 s | 700 px/s, grav 0.05 |

### Default map platform layouts (in `main.gd` `MAPS` dict)

| Map | Platforms (x, y, w, h, one_way) |
|---|---|
| Battlefield | `[0,600,1280,120,false]` (ground) + `[300,420,200,16,true]` + `[780,420,200,16,true]` + `[540,280,200,16,true]` (3 one-way) |
| Final Destination | `[0,600,1280,120,false]` (ground only) |
| Pokémon Stadium | `[0,600,1280,120,false]` (ground) + `[240,440,200,16,true]` + `[840,380,200,16,true]` (2 asymmetric) |

### `@export` / Inspector-visible variables

None currently. All tuning lives in code (the `CHARACTERS` and `MAPS` dicts). Personalization beats (§6) are all code edits.

### Input map (from `project.godot`)

- **P1**: `p1_left` (A), `p1_right` (D), `p1_jump` (W), `p1_down` (S), `p1_attack` (F)
- **P2**: `p2_left` (←), `p2_right` (→), `p2_jump` (↑), `p2_down` (↓), `p2_attack` (RShift)
- **Menus**: `confirm` (Space), `restart` (R)

---

## 9. Verification checklist (re-run if code changes — refreshed 2026-05-30)

- [x] All 9 `#@todo` blocks in `player.gd` mapped to chunk rows in §3 (#1, #2, #3, #5, #6a, #6b, #6c, #6d, #7).
- [x] 1 `#@todo` block in `main.gd` mapped to chunk #4.
- [x] 1 `#@todo` block in `final_challenge.gd` mapped to FC-1.
- [x] As-typed code blocks byte-identical to source between `#@todo` and `#@end` markers.
- [x] Scene tree in §2 matches `Main.tscn` + `Player.tscn` + `Projectile.tscn` node names + types.
- [x] CHARACTERS table (§8) matches `main.gd:6-59`.
- [x] MAPS table (§8) matches `main.gd:61-85`.
- [x] Input map (§8) matches `project.godot`.
- [x] Narrative-arc card (§1) matches BIBLE §15 universal narrative arc memory (Smash Bros = 1999 N64).
- [x] Chunk order in §3 + §5 matches BIBLE §4 D4 order (1, 2, 3, 4, 5, 6, 7).
- [x] No "(STRETCH)" tag on any morning chunk; banner on chunk #6 stripped 2026-05-30. "Stretch goals" applies only to §7 FC.
- [x] `(STRETCH)` removed from `# === KID CHUNK #6 — STATE MACHINE ===` banner per R1.
- [x] R5 partial-section split applied to chunk #6 — 4 sub-holes (#6a/#6b/#6c/#6d), each holding only the state-transition `if` blocks. Per BIBLE R5 + D3 #6 precedent.
- [x] Pre-given helper `get_move_direction()` (`player.gd:82-87`) replaces ternary one-liners in chunk #6 branches per R2.
- [x] Named-bool decomposition applied to chunk #7 melee branch (`in_range` / `facing_opponent` / `same_height` + two early-return guards) per R2 "no wicked one-liners."
- [x] Chunk #5 print simplified to `print(new_state)` (was `print("[P%d %s] state %s -> %s" % [...])`).
- [x] Chunk #3 pre-cursor "pieces you'll use" note flags that `set_state` lives in chunk #5 — kid file won't run between #3 and #5; type, save, move on.
- [x] Chunk #1 prose explicitly defines `facing` (1 = right, -1 = left) and notes `_physics_process:89-93` updates it automatically.
- [x] Chunk #2 prose points kids at `main.gd:6-59 CHARACTERS["knight"]` so they see where Knight defaults come from.
- [x] Each walkthrough (Pre-coding demo + per-chunk "After this chunk works" + Personalization + FC enable) appears exactly once at its lesson position.
- [x] Sprite picks confirmed correct on visual playtest — **verified 2026-06-10**.
- [x] Real-fight playtest with two humans — **verified 2026-06-10**.
- [ ] `final_challenge.gd` audited for R3.1 FC mirror completeness (currently 3 FC holes for 7 morning chunks — under the per-chunk mirror rule) — **DEFERRED to next remediation pass**.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 4." Output should require no follow-up clarification on chunk content. Visual playtest screenshots are a separate user-driven pass.

---

## 10. Slide blueprint — Full draft (DRAFT — locked 2026-05-30)

> Status: structural draft for the python-pptx slide build. Per-section slide bullets + per-chunk Action-slide specs live below. Slide counts are estimates; final counts settle in build-time pass. Hand this whole `SLIDE_SOURCE.md` to the build chat. Mirrors D3 §10 structure (locked 2026-05-29).

### 10.0 Decisions locked

#### Locked metaphors — two per day, one per umbrella concept

Following D2/D3 convention: each day's two umbrella concepts get one locked metaphor each. Sub-chunks under each umbrella reuse that metaphor; no fresh metaphor invention per chunk.

- **Objects** → **Minecraft mob (Panda)**. A panda is one *instance* of the panda class. Each panda you spawn has its own HP, its own personality, its own position — but they all share the same blueprint (same script, same methods, same property names). One concept root introduces this before chunk #1, then chunks #2 / #3 / #4 callback the Panda framing without re-teaching. Specific hook: **personalities** — Minecraft pandas come in 7 personality variants (lazy/worried/playful/aggressive/weak/brown/normal), each personality changes how the panda behaves. That bridges naturally into the State concept on chunk #5.

- **State** → **Traffic light**. Same intersection, three modes (red / yellow / green). The cars behave differently based on the current mode. State transitions happen on events (timer ticks, sensor triggers). One concept root introduces this before chunk #5, then chunk #6 (the state machine) + chunk #7 (`match attack_type`) callback the Traffic-light framing without re-teaching.

Other chunks lean on cross-day callbacks rather than fresh metaphors:

- **Function / method** = pizza order (D2 lock — call by name, kitchen handles it). Chunk #3 `take_damage` is "the panda has a `feed()` method — call `panda.take_damage(10)` and the panda's own HP goes down."
- **Instantiate** = spawning a Minecraft mob (Panda metaphor extension — `/summon panda` is `PLAYER_SCENE.instantiate()`).
- **`match`** = no fresh metaphor; D3 already introduced `match` as pre-given in chunk #6 (dispatcher). D4 chunks #6 + #7 use `match` directly, leaning on the Traffic-light framing ("the panda checks its state, runs the matching branch").

#### Other locks

- **Side-by-side action-slide composition** (every chunk's payoff slide): top = R6 prose instruction. LHS = board example (literal code shown on slide). RHS = Godot screenshot of the `#@todo` region with red overlay. See §10.1 for builder-AI rules.
- **Walkthroughs reused from D1/D2/D3**: Walk A (open project), Walk B (open script), Walk C (run F5), Walk D (read errors). Each ships as a 2-slide jog-memory pack per D2/D3 §10 convention.
- **Walk MF (NEW for D4)**: Menu Flow demo — instructor walks char-select → map-select → countdown → empty fight screen *before* chunks start. Shows the *shape* of the game even with chunk #4 empty. ~4 slides.
- **Walk CD (NEW for D4)**: CHARACTERS dict tour — instructor reads `main.gd:6-59`, points to the 11 properties per character, primes kids for chunks #1 + #2 ("these property names will appear on the Player class in a moment"). ~3 slides.
- **Historical context slide added to opener pack**: fighter-genre lineage (Street Fighter II 1991 → Mortal Kombat 1992 → Smash Bros 1999 = roster + multi-character + percent-damage breakout → Smash Bros Melee 2001 → modern Smash Ultimate). One opener slide, matches D3 historical-context pattern.
- **After-works payoff slides** — only at chunks where the game becomes visibly more alive:
  - **#4** (two characters appear on the map — first visible payoff).
  - **#6** (characters move + jump + fall — the big "the game responds to me" moment).
  - **#7** (fight loop complete — somebody can actually WIN).
  - Chunks #1, #2, #3, #5 have no after-works slide — their effect is invisible in isolation.

---

### 10.1 SLIDE BUILDER REFERENCE — read this before generating slides

> **AI consuming this doc to generate slides: this section is the spec for how to render each Action slide. Read carefully — the LHS/RHS layout has a precise meaning.**

For every **Action slide** in §10.4 onward (one per kid sub-hole):

| Slide region | What it contains | Source |
|---|---|---|
| **Top (title + body)** | R6 prose instruction — what the kid should produce, in input → output / observable-effect terms. Reads as a goal statement, not pseudo-code. | This doc's per-chunk "Action-slide prose (top)" field in §5. |
| **LHS pane** | Literal code shown as a code block (or rendered code image). The board example pattern the kid will adapt. | This doc's per-chunk "Board example" field. Verbatim from §5. |
| **RHS pane** | **A SCREENSHOT of the Godot script editor** zoomed in on the chunk's location in `player.gd` or `main.gd`. The kid `#@todo` region has a **red 4px-stroke rectangular overlay** marking the area the kid will edit. **THIS IS NOT A CODE LISTING OF WHAT THE KID TYPES.** It's a visual locator — "here is the section you'll be editing." | Per-chunk "In-file location" field below + line refs from §3. |
| **Speaker notes** | The R6 prose + metaphor framing + any quiz answers. Populated into the PPTX speaker-notes pane, not visible to the kid on screen. | Per-chunk "Speaker notes" field below. |

**Why this matters**: the kid is meant to look at the RHS, switch to Godot, find that region, and type their solution into the real script. The slide is a wayfinder, not a transcription target. If the RHS shows finished code, kids will copy character-by-character and miss the lesson. The "As-typed code" listed in §5 of this doc is **REFERENCE for the Complete build verification**, not slide content.

Other render rules:

- **R5 partial-hole action slides** (chunk #6 — see §10.10): the RHS Godot screenshot uses a **two-tone overlay**. Pre-given lines (inside `_physics_process` but OUTSIDE the `#@todo`/`#@end` markers — the `match` dispatcher + per-branch velocity + attack/hit exits + universal attack-input check) get a **gray semi-transparent overlay**. The kid sub-hole gets the standard red overlay. The slide caption explicitly says "gray = already written for you; red = your hole."
- **Multi-sub-hole chunks** (chunk #6 has 4 sub-holes #6a/#6b/#6c/#6d): one Action slide per sub-hole. Same `match state:` concept, separate Action slide per state's `#@todo` block.
- **Walkthrough hint slides** (Walk A/B/C/D, Walk MF, Walk CD): text + arrows only. No screenshots in the Hint slide of jog-memory packs.
- **Concept-root metaphor slides** (Minecraft panda, Traffic light): full-bleed metaphor imagery centered, body text under image. Not LHS/RHS layout — these are explanatory, not actionable.

---

### 10.2 Opener pack (~7 slides)

1. **Day title** — "Day 4 — 2-Player Fighter · 1999 · Smash Bros Era". Subtitle: "Super Smash Bros. (N64, 1999) — multi-character platformer fighter."
2. **Today we'll build** — finished Fighter screenshot + 1-line pitch: "Two humans, one keyboard, four characters, three maps. Last fighter standing wins."
3. **Why fighters matter** — historical context. Bullets: Street Fighter II 1991 = solo-vs-solo arcade boom. Mortal Kombat 1992 = breakout home console. Smash Bros 1999 = *roster + multi-character + percent-damage* invention. Modern Smash Ultimate = direct descendant of N64 Smash with 87 characters. Takeaway: every roster fighter today owes a debt to the N64 disc.
4. **Yesterday → Today** — D3 Tower Defense recap (Lists + Deeper Functions) → D4 adds **Objects + State**. Same `for`-loop / `func` shapes, new way to *package* code into reusable classes.
5. **5-day arc timeline** — D4 highlighted in red, D1/D2/D3 ticked in green, D5 dim.
6. **Today's two concepts** — full slide: **Objects** + **State**. One-line each: "Objects are blueprints that hold data + methods together. State is a label that lets one object behave differently depending on what mode it's in."
7. **GDScript vs Python — class card** — verbatim from §1: `class Player:` → `extends CharacterBody2D`, `def __init__(self):` → vars at top of file, `def take_damage(self, n):` → `func take_damage(n):`. Takeaway: "Classes are almost identical to Python. No `self.` everywhere; no `__init__`; `extends Parent` instead of `class Foo(Parent):`."

---

### 10.3 Pre-coding setup (~13 slides)

- **Section divider** — "Pre-coding setup."
- **Walk A — Open the Day 4 project** (jog-memory, 2 slides):
  1. Challenge: "Open the Day 4 Fighter project the same way you did yesterday."
  2. Hint (text + arrows, no screenshots): `Godot launcher → Import → Day4_Fighter_Game/project.godot → Import & Edit`.
- **Walk B — Open `player.gd`** (jog-memory, 2 slides):
  1. Challenge: "Open `player.gd` in the script editor — this is where most of today's chunks live."
  2. Hint: `FileSystem panel → player.gd → double-click → Script editor`.
- **Walk MF — Menu Flow Demo** (NEW for D4, instructor-driven, 4 slides):
  1. **Concept setup**: "The menu screens already work. Even with empty chunks, the kid can walk the flow." Screenshot title screen.
  2. **Click step 1**: F5 → char-select panel for P1 → press `1` (Knight). Screenshot panel updating.
  3. **Click step 2**: char-select P2 → press `2` (Ninja) → map-select → press `1` (Battlefield) → countdown. Screenshot countdown "3... 2... 1... GO!".
  4. **Takeaway**: "Fight screen appears — but the two fighters DON'T spawn yet (chunk #4 empty). Once you fill #4, both characters appear here. R = restart." Screenshot empty fight screen.
- **Walk CD — CHARACTERS Dict Tour** (NEW for D4, instructor-driven, 3 slides):
  1. **Open dict**: open `main.gd`, scroll to lines 6-59. Screenshot of `CHARACTERS = {...}` block.
  2. **11 properties per character**: bullet list — `display_name`, `sprite`, `tint`, `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`, `attack_range`, `projectile_speed`, `projectile_gravity_scale`. Highlight five that map directly to chunks #1+#2.
  3. **Takeaway**: "Each character is just a dictionary of property values. Today, the Player CLASS gets the same property names — so each Player object can remember its own copy." Bridges into chunk #1 + Panda metaphor.

---

### 10.4 Chunk #1 — Object properties (core) (FULL ARC, ~12 slides)

> First chunk of the day. Carries the **OBJECTS** concept root as a full-arc prefix (per D2/D3 pattern). **Concept and metaphor are interwoven** — the Minecraft panda image opens the section and every concept slide reuses it. Kids meet the metaphor first, then the technical vocabulary lands on top of something they can already see.

#### Concept root — OBJECTS (metaphor + concept interwoven, 7 slides)

1. **Hook — full-bleed Minecraft panda image** (3 pandas in different poses: lazy / playful / aggressive). No technical text yet. Caption: "Three pandas. Same Minecraft. Same script under the hood. What's different about them?" Prompt: invite kids to call out the differences (color, pose, mood, HP bar).
2. **Word reveal — "Object"** — overlay the word "OBJECT" on the same panda image. Caption: "Each panda is one *object*. The Minecraft code only has ONE panda script — but it can make as many pandas as it wants. Each one is its own object."
3. **Class vs instance — with pandas** — split layout: LEFT = single "Panda blueprint" card (sprite + property labels: `hp`, `personality`, `facing`); RIGHT = five different pandas spawned in a row (each with their own filled-in values: `hp=20 personality="lazy"`, `hp=18 personality="playful"`, ...). Caption: "The *class* is the blueprint (left). Each *instance* is one panda built from it (right). Same blueprint, different values per instance."
4. **Properties + methods — with pandas** — same panda image, two callout boxes:
   - **Properties (what each panda remembers about itself)** — `hp = 20`, `personality = "lazy"`, `facing = -1`.
   - **Methods (what each panda can DO)** — `eat()`, `sit_up()`, `roll_over()`.
   Caption: "An object is properties + methods bundled together. Pandas have both — and so does today's Player class."
5. **Quiz — two pandas** — image: Panda A (HP 18) + Panda B (HP 20). Question: "You damage Panda A for 5. What's Panda B's HP?" Answer reveal: 20. Caption: "Each instance has its OWN copy of every property. Hitting A doesn't touch B. That's the whole point of objects."
6. **Shape in code — Panda class** — board example, with the metaphor *visible alongside the code*:
   ```gdscript
   # Class blueprint (one panda class):
   extends CharacterBody2D

   var hp = 100              # property — each panda's own HP
   var personality = "lazy"  # property — each panda's own mood

   func eat():               # method — what pandas can do
       hp += 5
   ```
   Caption: "Vars at the top = properties. Funcs below = methods. That's a class. Today's Player class looks just like this."
7. **Personalities preview** — show all 7 Minecraft panda personalities (lazy/worried/playful/aggressive/weak/brown/normal). Caption: "Each panda has a `personality` property. The same code runs every frame — but each panda *behaves differently* depending on its personality. That bridges into the second big idea today: STATE. You'll meet it after lunch."

#### How-it's-used (2 slides)

8. **Games general** — every game uses objects: Mario coin = object. Zelda enemy = object. Fortnite weapon = object. Caption: "If a thing has its own stats and its own behavior, it's an object. Pandas, coins, enemies, weapons — same idea."
9. **D4 Fighter** — Diagram: one `Player.tscn` blueprint (same shape as the panda blueprint from slide 3), two instances on screen (P1 Knight + P2 Ninja, each with own HP bar). Caption: "Today: ONE Player class, TWO instances. Both run the same code. Different `player_num`, different character, different HP. Same shape as the panda class."

#### Where-in-game (1 slide)

10. **`player.gd:48-52` screenshot** with red overlay on the `#@todo` block (3-line region). Caption: "Time to declare your panda's three core properties."

#### ACTION SLIDE — #1 (1 slide, MANDATORY)

11. **Action slide**:
    - **Prose instruction (top)**: *"Declare the three things every Player needs to remember about itself: `hp` (start at 100), `max_hp` (also 100, for the HP bar), and `facing` (start at 1 = looking right)."*
    - **LHS board example**:
      ```gdscript
      # Inside a class:
      var hp = 100
      var personality = "lazy"
      ```
    - **RHS screenshot**: `player.gd:47-52` (banner + `#@todo` block), red overlay on lines 49-51.
    - **Speaker notes**: Panda callback — "every panda gets its own HP and own facing." Mention `_physics_process` already updates `facing` from input (lines 89-93) so the kid only declares it.

#### After-works (skipped)

12. *No after-works payoff slide.* Game runs F5 without "identifier not declared" errors, but nothing visible changes yet. Payoff deferred to #4 (two characters appear).

---

### 10.5 Walks C/D — Run + Read errors (jog-memory, 4 slides)

> D2/D3 precedent: kids run early after first chunk to catch typos before piling on more logic. Even though Chunk #1 has no visible payoff, hitting F5 here confirms the property declarations compile cleanly.

- **Walk C — Run the project** (jog-memory, 2 slides):
  1. Challenge: "Run the game and confirm it opens without errors."
  2. Hint (text + arrows, no screenshots): `F5 → Set Main Scene? → Select Current → game window opens → F8 to stop`.
- **Walk D — Reading an error** (jog-memory, 2 slides):
  1. Challenge: "Game didn't open? Find the error."
  2. Hint: `Output panel → click blue line number → fix → Ctrl+S → F5 again`.

---

### 10.6 Chunk #2 — Character-data properties (SMALL-ARC, ~5 slides)

> No new metaphor — Panda callback. Reuses the OBJECTS concept root from #1.

- **Recap-bridge** (1 slide) — "Your panda remembers `hp` + `facing`. Time to remember what KIND of panda it is."
- **Concept slide — data-driven properties** (1 slide) — diagram: `CHARACTERS["knight"]` dict on the left → arrow into `setup()` → arrow into per-player vars. Caption: "Each character's stats live in the `CHARACTERS` dict. `setup()` copies them onto the Player object. Pick Knight, get Knight's numbers."
- **Quiz** (1 slide) — "P1 picks Knight (`walk_speed = 220`). P2 picks Ninja (`walk_speed = 320`). Same property name, different values. Who walks faster?" Answer: P2 (Ninja). Caption: "Same property name. Each instance has its own copy."
- **Where-in-game** (1 slide) — `player.gd:54-61` screenshot, red overlay on lines 56-60. Side-pointer thumbnail to `main.gd:6-26` (Knight's entry in CHARACTERS) so kids see where the defaults came from.

#### ACTION SLIDE — #2 (1 slide, MANDATORY)

- **Action slide**:
  - **Prose instruction (top)**: *"Declare five more properties — `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown` — with Knight's stats as defaults (see `main.gd:6-59 CHARACTERS[\"knight\"]`). `setup()` overwrites them with the picked character's stats."*
  - **LHS board example**:
    ```gdscript
    var hunger = 100
    var bark_volume = 5
    ```
  - **RHS screenshot**: `player.gd:54-61`, red overlay on lines 56-60.
  - **Speaker notes**: Same five property names appear in `CHARACTERS["knight"]`. `setup()` does the copy. Defaults exist so the file compiles even before `setup()` runs.

---

### 10.7 Chunk #3 — Method: `take_damage(amount)` (~6 slides)

- **Recap-bridge** (1 slide) — "You declared your panda's HP. Now teach the panda how to *lose* HP."
- **Method concept slide** (1 slide) — board example: `func feed(): hunger -= 10`. Caption: "A method is a function INSIDE a class. It can read + change the object's own properties."
- **Pieces you'll use** (1 slide) — bullets listing all five pre-given names:
  - `hp` (your chunk #1 property)
  - `hit_flash_timer` (pre-given var)
  - `set_state("hit")` — **chunk #5 helper; not yet written.** *"That means: after #3, your file won't actually RUN until #5 is done. Type the line, save, move on."*
  - `hp_bar_fill` (pre-given `@onready`; change `.size.x` to shrink)
  - `die()` (pre-given function)
- **Where-in-game** (1 slide) — `player.gd:167-176` screenshot, red overlay on lines 169-176.

#### ACTION SLIDE — #3 (1 slide, MANDATORY)

- **Action slide**:
  - **Prose instruction (top)**: *"Subtract `amount` from `hp`, set `hit_flash_timer` to 0.2, switch state to `\"hit\"`, shrink the HP bar to match the new `hp/max_hp` ratio, and call `die()` if `hp` dropped to zero."*
  - **LHS board example**:
    ```gdscript
    func feed():
        hunger -= 10
    ```
  - **RHS screenshot**: `player.gd:167-176`, red overlay on lines 169-176.
  - **Speaker notes**: Method = function inside a class. `hp` here refers to *this panda's* HP, not the class's. Flag the `set_state` dependency — file is not runnable yet; will be after #5.

#### After-works (skipped)

- *No after-works payoff slide.* File doesn't compile-and-run between #3 and #5. Payoff deferred to #4 (characters spawn) + #7 (damage actually does anything visible).

---

### 10.8 Chunk #4 — Two instances (~6 slides)

- **Recap-bridge** (1 slide) — "Your Player class has properties and a method. Time to *spawn* two of them."
- **Class vs instance refresher** (1 slide) — Panda callback. Board example:
  ```gdscript
  var panda1 = Panda.new()
  var panda2 = Panda.new()
  panda1.feed()
  panda2.bark()
  ```
  Caption: "Two pandas. Same class. Each one has its own state."
- **Godot instantiate framing** (1 slide) — "In Godot, the equivalent of `Panda.new()` is `PLAYER_SCENE.instantiate()` — because `Player.tscn` packages the class + scene tree together."
- **Where-in-game** (1 slide) — `main.gd:205-212` screenshot, red overlay on lines 205-212.

#### ACTION SLIDE — #4 (1 slide, MANDATORY)

- **Action slide**:
  - **Prose instruction (top)**: *"Instantiate the Player scene twice. Add each to the tree, then call `setup()` on each — P1 at `Vector2(200, 500)`, P2 at `Vector2(1080, 500)`."*
  - **LHS board example**:
    ```gdscript
    var panda1 = Panda.new()
    var panda2 = Panda.new()
    panda1.feed()
    panda2.bark()
    ```
  - **RHS screenshot**: `main.gd:205-212`, red overlay on lines 205-212.
  - **Speaker notes**: `instantiate()` builds a fresh Player from `Player.tscn`. `add_child` puts it in the scene tree (so it actually appears + ticks). `setup()` configures it — chunk #2's `setup()` method runs and overwrites the defaults with the picked character's stats.

#### After-works (PAYOFF — first visible payoff of the day)

- F5 → char select → map select → countdown → **two characters appear at opposite ends of the map**. They stand still (chunk #6 still empty). Caption: "FIGHTERS ARE ON SCREEN. They can't move yet — but they exist."

---

### 10.9 Chunk #5 — State variable + `set_state()` helper (FULL ARC, ~11 slides)

> Second concept root of the day — **STATE**. Carries the Traffic-light metaphor. **Concept and metaphor are interwoven** — traffic light image opens the section and every concept slide reuses it. The technical word "state" lands on top of something kids see at every intersection.

#### Concept root — STATE (metaphor + concept interwoven, 7 slides)

1. **Section divider** — "Objects can change mode."
2. **Hook — full-bleed traffic light image** at a real intersection. No technical text yet. Caption: "One light. Same intersection. But what the CARS do is totally different right now versus 30 seconds from now. Why?" Prompt: invite kids to call out what changes (the color of the light, what the drivers do).
3. **Word reveal — "State"** — overlay the word "STATE" on the same traffic light image, with the red lens highlighted. Caption: "The light's CURRENT MODE is its *state*. The state right now is `\"red\"`. Tomorrow's first car at this intersection will see a different state. Same hardware, different behavior."
4. **Three states + behaviors — traffic light table** — image: 3 traffic-light icons (red/yellow/green) with cars under each. Table:
   | State | Cars do |
   |---|---|
   | `"red"` | Stop |
   | `"yellow"` | Slow down |
   | `"green"` | Go |
   Caption: "Same intersection. Three modes. The cars run a totally different branch of behavior depending on which mode is active."
5. **Transitions on events — traffic light** — diagram: red → (30 s timer) → green → (25 s timer) → yellow → (3 s timer) → red. Caption: "States change on events. For the traffic light, it's a timer. For your panda in a minute, it'll be a key press."
6. **Shape in code — traffic light class** — board example, with the metaphor visible alongside the code:
   ```gdscript
   var state = "red"        # the current mode

   match state:             # check the mode, run the matching branch
       "red":
           cars_must_stop()
       "yellow":
           cars_slow_down()
       "green":
           cars_go()

   func set_state(new):     # helper that changes the mode
       state = new
   ```
   Caption: "One variable. One `match`. One helper to change it. That's a state machine. Your Player class is going to look exactly like this."
7. **Quiz — state transition** — "Light is green. Pedestrian hits the crosswalk button. What state does the light go to next?" Multiple choice: red / yellow / stays green. Answer: yellow (then red). Caption: "States change in order — green never jumps straight to red. Same rule applies to your panda: idle never jumps straight to fall."

#### How-it's-used (1 slide)

8. **D4 Fighter** — Diagram: panda figure with 6 state labels arranged in a circle (idle / walk / jump / fall / attack / hit) and arrows showing legal transitions. Caption: "Your panda has 6 states. Each one accepts different input and applies different physics. Chunk #6 (right after this one) is where you write the transitions."

#### Where-in-game (1 slide)

9. **`player.gd:63-72` screenshot**, red overlay on lines 64-72. Caption: "Time to declare your panda's `state` variable and write the helper that changes it."

#### ACTION SLIDE — #5 (1 slide, MANDATORY)

10. **Action slide**:
    - **Prose instruction (top)**: *"Declare `state` (start at `\"idle\"`). In `set_state(new_state)`: bail if it matches the current state, otherwise print `new_state` and update `state`."*
    - **LHS board example** (traffic-light flavored):
      ```gdscript
      var state = "red"

      func set_state(new):
          if new == state:
              return
          print(new)
          state = new
      ```
    - **RHS screenshot**: `player.gd:63-72`, red overlay on lines 64-72.
    - **Speaker notes**: Why the guard? Without `if new_state == state: return`, the Output panel would spam every frame. Why `print(new_state)`? Lets kids *see* state transitions live as they play in chunk #6 — the traffic light "telling you" which mode it just switched to.

#### After-works (skipped)

11. *No after-works payoff slide.* Game still doesn't visibly do more than after #4 — `state` exists but nothing reads it yet. Payoff deferred to #6 (characters actually MOVE).

---

### 10.10 Chunk #6 — State machine in `_physics_process` (R5 partial, ~10 slides)

> R5 partial-section hole — 4 sub-holes (#6a `idle` exits, #6b `walk` exits, #6c `jump` exit, #6d `fall` exit). Pre-given block holds the `match` dispatcher + per-branch velocity (using pre-given `get_move_direction()`) + `attack`/`hit` exits + universal attack-input check.

- **Recap-bridge** (1 slide) — "Your panda has a `state` variable + a `set_state` helper. Time to actually USE them — make the panda behave differently per state."
- **`match` framing** (1 slide) — "The `match` keyword routes by state value. It's mostly pre-given here — `match` is the same shape D3 used in chunk #6 (Towers' `match t_type:`)." Diagram: state variable → match → six branches.
- **Pre-given vs kid breakdown** (1 slide) — bullets:
  - Pre-given: `match state:` dispatcher, per-branch velocity (`velocity.x = walk_speed * get_move_direction()`), `attack` + `hit` branches, universal "attack input" check.
  - Kid fills (4 sub-holes): the `if` blocks inside `idle` / `walk` / `jump` / `fall` that decide WHICH state comes next.
  Caption: "We give you 4 mostly-empty branches. You write the 'when do I switch?' lines."
- **`get_move_direction()` helper** (1 slide) — board example:
  ```gdscript
  func get_move_direction() -> int:
      if get_input_pressed("left"):
          return -1
      if get_input_pressed("right"):
          return 1
      return 0
  ```
  Caption: "Pre-given helper. Returns -1 / 0 / 1 for left / nothing / right. Use it instead of writing the long ternary."
- **Where-in-game** (1 slide) — `player.gd:109-159` screenshot with **two-tone overlay**: gray on pre-given lines (109-114, 124-125, 133-134, 140-141, 147-159), red on kid sub-holes (116-122, 126-132, 136-139, 143-146). Caption: "Gray = already written for you. Red = your four holes — one per state."

#### ACTION SLIDE — #6a (idle exits, 1 slide)

- **Action slide**:
  - **Prose**: *"Inside the `idle` branch: switch to `\"walk\"` when `get_move_direction()` is non-zero, and switch to `\"jump\"` (with upward `velocity.y`) when jump is pressed on the floor."*
  - **LHS board example**:
    ```gdscript
    if get_move_direction() != 0:
        set_state("walk")
    ```
  - **RHS screenshot**: `player.gd:114-122` zoom, red overlay on lines 116-122.
  - **Speaker notes**: Two `if`s. First detects movement and switches to walk. Second detects jump-key + on-floor and launches. Same pattern repeats in #6b.

#### ACTION SLIDE — #6b (walk exits, 1 slide)

- **Action slide**:
  - **Prose**: *"Inside the `walk` branch: switch back to `\"idle\"` when `get_move_direction()` is zero, and switch to `\"jump\"` (with upward `velocity.y`) when jump is pressed on the floor."*
  - **LHS board example**:
    ```gdscript
    if get_move_direction() == 0:
        set_state("idle")
    ```
  - **RHS screenshot**: `player.gd:124-132` zoom, red overlay on lines 126-132.
  - **Speaker notes**: Mirror of #6a — exits walk back to idle when input drops, or up into jump on key press.

#### ACTION SLIDE — #6c (jump exit, 1 slide)

- **Action slide**:
  - **Prose**: *"Inside the `jump` branch: when `velocity.y > 0` (upward velocity has run out), switch to `\"fall\"`."*
  - **LHS board example**:
    ```gdscript
    if velocity.y > 0:
        set_state("fall")
    ```
  - **RHS screenshot**: `player.gd:134-139` zoom, red overlay on lines 136-139.
  - **Speaker notes**: Gravity (pre-given, `player.gd:86-87`) is constantly pulling `velocity.y` more positive. When it crosses 0, the panda is now falling. Switch state to fall.

#### ACTION SLIDE — #6d (fall exit, 1 slide)

- **Action slide**:
  - **Prose**: *"Inside the `fall` branch: when `is_on_floor()` is true (player has landed), switch back to `\"idle\"`."*
  - **LHS board example**:
    ```gdscript
    if is_on_floor():
        set_state("idle")
    ```
  - **RHS screenshot**: `player.gd:141-146` zoom, red overlay on lines 143-146.
  - **Speaker notes**: `is_on_floor()` is a Godot built-in on `CharacterBody2D`. Returns true when the body's collision shape rests on a static body.

#### After-works (BIG PAYOFF — second visible payoff of the day)

- Full-game screenshot mid-jump. Caption: "PANDA MOVES." Body: "Press A/D to walk. W to jump. Watch the Output panel — `walk` `jump` `fall` `idle` print as the state transitions. The game now responds to you." Note: attack key triggers state but no damage yet (that's #7).

---

### 10.11 Chunk #7 — `attack()` body (~6 slides)

- **Recap-bridge** (1 slide) — "Your panda walks, jumps, falls. Pressing attack switches state — but nothing happens. Let's make the attack DO something."
- **`match attack_type` framing** (1 slide) — "Same shape as chunk #6's `match state:`. One method, two branches: `\"melee\"` (Knight/Ninja) or `\"projectile\"` (Mage/Archer). Each character picks its branch via the `attack_type` property you declared in chunk #2."
- **Pieces you'll use** (1 slide) — bullets listing pre-given names:
  - `attack_cooldown_timer` (pre-given var; setting > 0 blocks re-fire)
  - `melee_swing_timer` + `queue_redraw()` (cosmetic — white swing rectangle)
  - `get_opponent()` (pre-given — returns the OTHER player)
  - `spawn_projectile()` (pre-given — fires one projectile in `facing` direction)
  - `take_damage(n)` on the opponent (chunk #3 method — works on EITHER player)
- **No wicked one-liners** (1 slide) — board contrast: BAD (one compound `if`) vs GOOD (three named bools + clean `and`-chain).
  ```gdscript
  # GOOD:
  var in_range = abs(to_opp.x) <= attack_range
  var facing_opponent = sign(to_opp.x) == facing
  var same_height = abs(to_opp.y) <= 60
  if in_range and facing_opponent and same_height:
      opponent.take_damage(attack_damage)
  ```
  Caption: "One purpose per line. C-style. Each `var` is readable on its own."
- **Where-in-game** (1 slide) — `player.gd:178-199` screenshot, red overlay on lines 180-199.

#### ACTION SLIDE — #7 (1 slide, MANDATORY)

- **Action slide**:
  - **Prose instruction (top)**: *"Start the cooldown timer, then `match attack_type:` — `\"melee\"` does the swing-rectangle and damages an opponent who's in range + facing + same height; `\"projectile\"` calls `spawn_projectile()`."*
  - **LHS board example**:
    ```gdscript
    func bark():
        match volume:
            "loud":
                wake_neighbours()
            "soft":
                annoy_cat()
    ```
  - **RHS screenshot**: `player.gd:178-199`, red overlay on lines 180-199.
  - **Speaker notes**: Two early-`return`s replace the old compound `if opponent != null and not opponent.is_dead()`. Each named bool is one check. Final `if in_range and facing_opponent and same_height:` reads like English.

#### After-works (HUGE PAYOFF — third visible payoff, end of morning)

- Full-fight screenshot: Knight + Ninja, both with HP bars half-empty, swing-rectangle mid-fire. Caption: "FIGHT LOOP COMPLETE." Body: "Hits actually damage. HP bars shrink. Hit flashes fire. Someone hits 0 HP → WinLabel appears. R restarts back to char select. **The game is a game.**"

---

### 10.12 Personalization layer (~18 slides)

> Section divider — "Make it yours."

- **Beat 1 — Tune a character's stats** (3 slides): open `CHARACTERS` dict → change one number → run. Example: Knight `walk_speed` 220 → 600 (Speed Knight).
- **Beat 2 — Re-tint with Modulate** (3 slides): same dict, `Color(R, G, B)` field. Example: pink Ninja → bright green Ninja.
- **Beat 3 — Swap a character's sprite** (3 slides): browse `assets/kenney_pp/characters/` → pick `tile_0004.png` or higher → edit `"sprite"` path → run.
- **Beat 4 — Edit a map's platform layout** (3 slides): open `MAPS` dict → add `[600, 320, 100, 16, true]` to Pokémon Stadium → run → new platform appears.
- **Beat 5 — Add a fifth map** (3 slides): copy a map block, change key name, edit `_unhandled_input` keys array to include the new map, update map-select panel text.
- **Beat 6 (stretch) — Take on the Final Challenge** (1 slide) — pointer to §10.13.

---

### 10.13 Final Challenge — `final_challenge.gd` (~14 slides)

> User-locked envelope: D2 FC pack was ~6 slides for 6 holes; D3 FC pack was ~16 slides for 9 holes. D4 has 3 FC holes (FC-1, FC-2, FC-3) — but each one is creativity-heavy (invent a 5th character). Aim for ~14 slides total. **R3.1 audit pending** — current 3 holes don't mirror every morning chunk; remediation deferred.

- **Section divider** — "Final Challenge — Invent Your Own Fighter."
- **FC payoff card** (1 slide) — what the FC unlocks: "Build a 5th character with whatever stats, sprite, and attack you want. Then play it against your friend."
- **R3 POINTER SLIDE** (1 slide, REQUIRED per BIBLE §4 R3) — global mirror map. Three rows:
  - FC-1 ← chunks #1 + #2 (property declarations → a fresh stats dict)
  - FC-2 ← chunk #4 (hook a new instance into the existing system)
  - FC-3 ← chunks #6 + #7 (add a new `match` branch + invent attack behavior)
  Caption: "Every FC hole is a *reword* of something you wrote this morning."
- **FC enable walkthrough** (2 slides):
  1. Open `final_challenge.gd`. Fill the `CUSTOM_CHARACTER` dict (FC-1).
  2. Open `main.gd` `_ready()` — add `CHARACTERS["custom"] = CUSTOM_CHARACTER` (FC-2). Open `player.gd` `attack()` — add a `"custom":` branch (FC-3). Save all three, F5.
- **Per-hole Action slides** — one slide each:
  - **FC-1** — *"Fill the `CUSTOM_CHARACTER` dict with stats for your fighter. Pick a sprite from `assets/kenney_pp/characters/` (try `tile_0004.png` and up). Set `attack_type` to `\"custom\"` so FC-3's new branch takes over."* Banner: "FC-1 ← chunks #1 + #2".
  - **FC-2** — *"In `main.gd` `_ready()` (after `CHARACTERS` is defined), add `CHARACTERS[\"custom\"] = CUSTOM_CHARACTER`. Update the char-select keys array + panel text so key `5` picks your character."* Banner: "FC-2 ← chunk #4".
  - **FC-3** — *"In `player.gd`'s `attack()` `match attack_type:`, add a `\"custom\":` branch. Invent whatever behavior you want — swing twice, shoot 3 projectiles, heal yourself, charge attack. The morning's pieces (`take_damage`, `spawn_projectile`, `melee_swing_timer`, `queue_redraw`) are still available."* Banner: "FC-3 ← chunks #6 + #7".
- **Creativity menu** (2 slides) — bullets of "things you could try":
  - Slide 1: damage twice in one swing; shoot 3 projectiles in a spread; charge attack (longer cooldown, bigger damage); self-heal instead of damage; teleport behind opponent; mirror opponent's HP back at them.
  - Slide 2: "Or invent something the camp has never seen. There's no wrong answer."
- **FC payoff** (1 slide) — screenshot of an instructor's custom-fighter test. Caption: "Your fighter, in the ring."

---

### 10.14 Day closer (~3 slides)

1. **Recap** — "Today: Objects + State. Two big ideas. Your code now has *blueprints* and *modes*."
2. **Tomorrow teaser** — "Day 5: VR / Racing showcase + Steam Escape Simulator. No new code — just play what you built, show it off, and play together."
3. **Build-time / export walkthrough** — handed to instructor in a separate pack. Slide here just points: "Ask your instructor for the export pack to ship your Windows .exe."

---

### 10.15 Build-time notes for python-pptx chat

- **Master frame**: iCode logo top-left, D4 day tab top-right (no per-day color — `theme.py` uses red/black/grey master frame for all days), page number bottom-right per `SLIDES_FORMATS.md` master frame spec.
- **Walkthrough step badges**: jog-memory Challenge/Hint slides use small step badges (A.1, A.2, B.1, B.2, MF.1-4, CD.1-3, C.1, C.2, D.1, D.2) top-right.
- **Red overlay** on RHS Godot screenshots: 4px stroke, fully transparent fill, drawn over the kid `#@todo` region.
- **Gray overlay** for R5 partial hole (chunk #6): semi-transparent fill (alpha ~0.3), no stroke, over pre-given lines (match dispatcher, per-branch velocity, attack/hit exits, universal attack-input check).
- **Speaker notes**: every Action slide populates its "Speaker notes" field per §10.4+ above.
- **Estimated total slide count**: 105-115 slides. Final count locks in build-time pass.
- **Verification before build**: re-run §9 checklist. If `player.gd` / `main.gd` line numbers shift, all RHS screenshots + line refs must update.

---

### 10.16 Pending decisions (blocking final build)

- [x] **Day tab color for D4** — resolved 2026-06-09: no per-day color exists. `theme.py` uses red/black/grey master frame for all days.
- [ ] **Historical context slide content** — Fighter-genre lineage sourcing pending (SF2 1991, MK 1992, Smash N64 1999, Melee 2001, Smash Ultimate modern).
- [ ] **Sprite picks confirmed on visual playtest** — pending Kenney character pack review; flag any swaps that affect §8.
- [ ] **`final_challenge.gd` R3.1 audit** — currently 3 FC holes for 7 morning chunks. R3.1 says one mirror hole per chunk. Either expand FC to 7+ holes OR document explicit exemption. Deferred to next remediation pass.
- [ ] **Real-fight playtest** — D4 stats not Python-simulated; rebalance via real two-human playtest, then update CHARACTERS dict + §8 stats table.

---

## Rework log

- **2026-05-30 — R1 + R2 + R5 remediation pass.**
  - Stripped `(STRETCH)` from chunk #6 banner (R1).
  - Simplified chunk #5 `print` from format-string to `print(new_state)` (R6 "kid-readable level").
  - Added pre-given helper `get_move_direction()` in `player.gd:82-87` (returns -1/0/1) to replace four-way ternary `velocity.x = walk_speed * (-1 if ... else 1 if ... else 0)` lines in chunk #6 branches per R2 ("no wicked one-liners, C-style simple").
  - Restructured chunk #6 as **R5 partial-section hole** — 4 sub-holes (#6a `idle` exits, #6b `walk` exits, #6c `jump` exit, #6d `fall` exit). The `match` dispatcher, per-branch velocity, `attack`/`hit` exits, and the universal attack-input check are pre-given. Kid fills 14 LoC total across the four sub-holes (was 45 LoC in one block).
  - Exploded the chunk #7 melee compound `if` into three named bools (`in_range` / `facing_opponent` / `same_height`) + two early-return null/dead guards per R2.
  - Added per-chunk "Pieces you'll use" pre-cursor bullets (chunks #3, #6, #7) listing pre-given helpers + which chunk they live in.
  - Added single-sentence "Action-slide prose (top)" lines per chunk matching D3 convention (20-45 words, imperative, names vars directly).
  - Chunk #3 prose explicitly flags the file-won't-run-between-#3-and-#5 dependency (set_state defined in #5); kid types, saves, moves on.
  - §3 chunk table refreshed: now lists 10 `#@todo` sub-holes across 7 chunks; total kid LoC ≈ 55.
  - §9 verification checklist refreshed with R1 + R2 + R5 line items.

- **2026-05-30 PM (§10 slide blueprint pass)** — Locked Minecraft Panda (Objects concept) + Traffic light (State concept) as the two D4 metaphors per D2/D3 convention (one metaphor per umbrella concept, all chunks under that umbrella reuse without re-teaching). Built §10 in full presentation order mirroring D3 §10 structure (15 sub-sections: 10.0 decisions locked → 10.1 SLIDE BUILDER REFERENCE → 10.2 opener pack → 10.3 pre-coding setup with NEW Walk MF + Walk CD demos → 10.4 Chunk #1 FULL ARC (OBJECTS concept root + Panda metaphor + Action slide) → 10.5 Walks C/D → 10.6 Chunk #2 SMALL-ARC → 10.7 Chunk #3 → 10.8 Chunk #4 (first visible payoff) → 10.9 Chunk #5 FULL ARC (STATE concept root + Traffic light metaphor + Action slide) → 10.10 Chunk #6 R5 partial with two-tone overlay + 4 per-sub-hole Action slides → 10.11 Chunk #7 (third visible payoff) → 10.12 Personalization → 10.13 FC pack → 10.14 day closer → 10.15 build-time notes → 10.16 pending decisions). Three after-works payoff slides only — at chunks #4 (fighters appear), #6 (panda moves), #7 (fight loop complete). Estimated total deck: 105-115 slides.

- **2026-05-30 PM (concept + metaphor interweave pass)** — User feedback: concept and metaphor should be *interwoven*, not stacked sequentially (metaphor first then concept is less effective than them landing together). Restructured §10.4 (OBJECTS) and §10.9 (STATE) concept roots so the metaphor image opens each section and every concept slide reuses it. OBJECTS root: panda hook → word reveal *on the panda image* → class-vs-instance shown via panda blueprint vs spawned pandas → properties/methods labeled on a panda diagram → quiz with two pandas → code block uses Panda class (not abstract names) → personalities bridge to State. STATE root: traffic-light hook → word reveal *on the traffic light* → behaviors table uses red/yellow/green directly → transitions diagram traces a real traffic-light cycle → code block uses `state = "red"` with cars_must_stop() / cars_slow_down() / cars_go() → quiz on legal state transitions. Both concept roots remained ~7 slides each — same slide count, reshuffled order so the metaphor never appears AFTER the technical vocabulary.

---

## 10. Slide-by-slide expansion (FULL)

### 10.2 Opener pack (S001–S007)

#### Slide D4-S001 — Day title
- Format: G01 Title
- Title: "Day 4 — 2-Player Fighter · 1999 · Smash Bros Era"
- Body: none
- Image: `D4Smash1.png -- not done --` — full-bleed Smash Bros era aesthetic, two characters mid-fight
- Caption: none
- Notes: Day opener. Hold until the room settles. Full-bleed image behind the title. No bullet points.

#### Slide D4-S002 — Today we'll build
- Format: G12 Screenshot + Caption
- Title: "Today we'll build"
- Body: none
- Image: `D4Smash1.png -- not done --` — stub placeholder for finished game screenshot
- Caption: "Two humans, one keyboard, four characters, three maps."
- Notes: One-sentence build promise. Let the image carry it. If no screenshot yet, instructor narrates the game while kids look at the title card.

#### Slide D4-S003 — Why fighters matter
- Format: G05 Concept Explanation
- Title: "Why fighters matter"
- Body:
  - 1984: Karate Champ — two-player on one screen, invented the genre.
  - 1992: Street Fighter II goes to arcades — quarter-eating, combos, characters with personalities.
  - 1999: Super Smash Bros — stock lives, platform stages, no health bars, four players. Chaos perfected.
  - 2D fighters are the petri dish where character stats, state machines, and hitboxes were invented.
- Image: `D4Smash2.png -- not done --` — optional historical montage; mark not done
- Caption: none
- Notes: Historical framing — 2 minutes max. The point: fighters aren't simple. They are the genre that forced programmers to invent "objects" (every character knows its own HP) and "states" (every character is either idle / walk / jump / attack). That's today's two concepts in disguise.

#### Slide D4-S004 — Yesterday → Today
- Format: G05 Concept Explanation
- Title: "Yesterday → Today"
- Body:
  - D3: Functions + Lists — every enemy is a dict in a list; functions scan it every frame.
  - D4: Objects + State — every fighter is an *object* that remembers its own HP and knows what it's doing right now.
  - Shift: from "a list of dicts" → "a class that gives each fighter its own memory."
- Image: none
- Caption: none
- Notes: Bridge from D3. Keep it to two columns mentally: D3 left, D4 right. Kids who remember `for e in enemies:` will feel the upgrade — instead of reaching into a dict, you call `fighter.take_damage(10)` and the fighter handles itself.

#### Slide D4-S005 — 5-day arc timeline
- Format: G02 Timeline / Closer
- Title: "5-day arc"
- Body:
  - D1: Variables + Conditions — Racer
  - D2: Loops + Functions (intro) — Maze
  - D3: Functions (deep) + Lists — Base Defense
  - **D4: Objects + State — Fighter** ← you are here
  - D5: No new code — Showcase
- Image: none
- Caption: none
- Notes: D4 highlighted. Remind kids: every day's concepts *stack* — today's objects use every variable, condition, loop, and function from the previous days.

#### Slide D4-S006 — Today's two concepts
- Format: G04 Headline / Divider
- Title: "Two new ideas today"
- Body:
  - OBJECTS — a fighter that remembers its own stats and handles its own damage.
  - STATE — a fighter that knows what it's doing right now (idle / walk / jump / attack / hit / dead).
- Image: none
- Caption: none
- Notes: Section divider doubling as concept preview. Instructor reads both bullets aloud. No elaboration yet — that comes in chunks #1 and #5.

#### Slide D4-S007 — GDScript vs Python class card
- Format: G09 Concept + Task
- Title: "GDScript classes vs Python"
- Body LHS:
  ```python
  # Python
  class Panda:
      def __init__(self):
          self.hp = 100

      def take_damage(self, n):
          self.hp -= n

  p = Panda()
  p.take_damage(10)
  ```
- Image: none
- Caption: "GDScript uses `extends` instead of inheriting from `object`, and `func` instead of `def` — everything else transfers directly to Python."
- Notes: Verbatim from §1 of blueprint. Right column (RHS) shows the GDScript equivalent: `extends Node2D`, `var hp := 100`, `func take_damage(n):`, `hp -= n`. Instructor: "If you ever use Python, classes look almost identical — you just swap `func` for `def`."

### 10.3 Pre-coding setup (S008–S020)

#### Slide D4-S008 — Pre-coding setup divider
- Format: G04 Headline / Divider
- Title: "Pre-coding setup"
- Body: none
- Image: none
- Caption: none
- Notes: Section divider. Transition cue for instructor: "Before we type anything, let's open the project and take a tour."

#### Slide D4-S009 — Walk A Challenge: Open Day 4 project
- Format: G07 Step / Challenge
- Title: "Open the Day 4 project"
- Body: "Open the Day 4 Fighter project the same way you did yesterday."
- Image: none
- Caption: none
- Notes: Jog-memory challenge. Kids should remember the Godot launcher flow from D3. Give ~30 seconds before advancing to hint.

#### Slide D4-S010 — Walk A Hint
- Format: G08 Step / Hint
- Title: "Open Day 4 — hint"
- Body:
  - Godot launcher → **Import** → navigate to `Day4_Fighter_Game/project.godot` → **Import & Edit**
- Image: none
- Caption: none
- Notes: Text only — no screenshot. Instructor reads aloud while kids follow. Same flow as D3.

#### Slide D4-S011 — Walk B Challenge: Open player.gd
- Format: G07 Step / Challenge
- Title: "Open `player.gd`"
- Body: "Open `player.gd` in the script editor — this is where most of today's chunks live."
- Image: none
- Caption: none
- Notes: Jog-memory. FileSystem panel is in the lower-left by default. If any kids can't find it, let peers help first.

#### Slide D4-S012 — Walk B Hint
- Format: G08 Step / Hint
- Title: "Open player.gd — hint"
- Body:
  - FileSystem panel (lower-left) → `player.gd` → double-click → Script editor opens.
- Image: none
- Caption: none
- Notes: Text only — no screenshot. Quick 10-second hint; move on.

#### Slide D4-S013 — Walk MF.1: Menu flow concept
- Format: G12 Screenshot + Caption
- Title: "The menus already work"
- Body: none
- Image: `D4WMF1.png` — title screen with char-select prompt visible
- Caption: "Even with all your chunks empty, you can walk the full menu flow right now. The game logic is pre-built — you're adding the fighters."
- Notes: Instructor drives. Press F5 and show the class live while the slide is up. If projector isn't available, narrate the flow from the screenshot.

#### Slide D4-S014 — Walk MF.2: P1 char-select
- Format: G12 Screenshot + Caption
- Title: "P1 picks a character"
- Body: none
- Image: `D4WalkMF2.png -- not done --` — char-select panel showing P1 prompt, keys 1-4 visible
- Caption: "Press 1 → Knight. Press 2 → Ninja. Press 3 → Mage. Press 4 → Archer. P1 picks first, then P2."
- Notes: Instructor demo live. Emphasise that the `CHARACTERS` dict in `main.gd` drives the four options — kids will see this dict in Walk CD.

#### Slide D4-S015 — Walk MF.3: Map select + countdown
- Format: G12 Screenshot + Caption
- Title: "Pick a map → countdown"
- Body: none
- Image: `D4WalkMF3.png -- not done --` — map-select panel or countdown screen
- Caption: "After both players pick, choose a map (1-3). Then 3… 2… 1… GO!"
- Notes: Keep moving. Point out the countdown so kids know to expect it when they test their own code.

#### Slide D4-S016 — Walk MF.4: Countdown
- Format: G12 Screenshot + Caption
- Title: "3… 2… 1… GO!"
- Body: none
- Image: `D4WalkMF4.png -- not done --` — countdown label mid-screen
- Caption: "The countdown runs automatically. After GO!, the fight screen loads — but the fighters don't appear yet."
- Notes: Brief. The punchline is the *next* slide.

#### Slide D4-S017 — Walk MF.5: Empty fight screen takeaway
- Format: G12 Screenshot + Caption
- Title: "Empty fight screen"
- Body: none
- Image: `D4WalkMF5.png -- not done --` — fight screen with platforms visible but no fighters
- Caption: "No fighters yet — chunk #4 is empty. Once you fill it, both characters appear here. Press R to restart back to char-select."
- Notes: This is the motivating gap. Kids can see the platforms and HUD exist; they're just missing the two fighters. Chunk #4 payoff will feel earned when it fills this screen.

#### Slide D4-S018 — Walk CD.1: Open CHARACTERS dict
- Format: G12 Screenshot + Caption
- Title: "The CHARACTERS dict"
- Body: none
- Image: `D4WCD1.png` — main.gd open at lines 6-59, CHARACTERS block visible
- Caption: "Every character is one dictionary of 11 property values. This dict drives the whole game."
- Notes: Instructor: open main.gd, Ctrl+G → 6. Show the block. Point out the four keys: "knight", "ninja", "mage", "archer". The next slide zooms in on one entry.

#### Slide D4-S019 — Walk CD.2: 11 properties bullet list
- Format: G05 Concept Explanation
- Title: "11 properties per character"
- Body:
  - `display_name` — shown in char-select panel
  - `sprite` — path to the Kenney sprite PNG
  - `tint` — `Color(R, G, B)` tint applied via Modulate
  - `walk_speed` — pixels/second horizontal movement
  - `jump_impulse` — upward velocity on jump
  - `attack_type` — `"melee"` or `"projectile"`
  - `attack_damage` — HP removed per hit
  - `attack_cooldown` — seconds between attacks
  - `attack_range` — melee reach in pixels
  - `projectile_speed` — speed of fired projectile
  - `projectile_gravity_scale` — how fast projectile falls
- Image: `D4WalkCD2.png -- not done --` — Knight's entry with all 11 properties visible
- Caption: none
- Notes: The five bold ones (walk_speed, jump_impulse, attack_type, attack_damage, attack_cooldown) map directly to chunk #2's property declarations. Instructor can highlight them in the editor live.

#### Slide D4-S020 — Walk CD.3: Bridge to chunk #1
- Format: G05 Concept Explanation
- Title: "Each character is a dict. Each fighter will be an object."
- Body:
  - Right now: characters are *dicts* — plain data, no behaviour.
  - Today: the Player *class* gets the same property names — so each Player object owns its own copy of those values.
  - When `setup()` runs, it copies from the dict into the object. Knight's walk_speed → `self.walk_speed`.
- Image: `D4WalkCD3.png -- not done --` — Knight's entry with walk_speed / jump_impulse / attack_type / attack_damage / attack_cooldown highlighted
- Caption: none
- Notes: Bridge into chunk #1. The panda metaphor starts next — this slide plants the vocabulary so "object" and "property" aren't cold words when they appear.

### 10.4 Chunk #1 — Object properties core (S021–S032)

#### Slide D4-S021 — Hook: three pandas
- Format: G05 Concept Explanation
- Title: "Meet the pandas"
- Body: none
- Image: `D4Panda1.png -- not done --` — full-bleed image of three distinct Minecraft-style pandas
- Caption: none
- Notes: Full-bleed metaphor hook. No text on screen — instructor says: "Three pandas. Are they the same?" Pause. "They look similar — but each one has its OWN hunger level, its OWN HP, its OWN personality." Land the hook before advancing.

#### Slide D4-S022 — Word reveal: OBJECT
- Format: G05 Concept Explanation
- Title: "OBJECT"
- Body: "An object is a thing in code that remembers its own data."
- Image: `D4Panda1.png -- not done --` — same three pandas image, "OBJECT" overlaid
- Caption: none
- Notes: Word reveal ON the panda image. One sentence definition. Let it sit for 3 seconds before continuing.

#### Slide D4-S023 — Class vs instance
- Format: G05 Concept Explanation
- Title: "Blueprint vs panda"
- Body:
  - **Class** = the blueprint. Describes *what kind of data* a panda has. Written once.
  - **Instance** = one actual panda, created from that blueprint. Has its own copy of every property.
  - Three pandas on screen → three *instances*. One blueprint → the `Panda` class.
- Image: `D4Panda2.png -- not done --` — panda blueprint on left, three spawned pandas on right
- Caption: none
- Notes: Keep the metaphor grounded. "The blueprint is like a cookie cutter — you use it to stamp out as many pandas as you want. Each cookie is its own thing."

#### Slide D4-S024 — Properties and methods labeled
- Format: G05 Concept Explanation
- Title: "Properties + Methods"
- Body:
  - **Property** = a piece of data the object remembers. `hp`, `hunger`, `personality`.
  - **Method** = something the object can *do*. `eat()`, `take_damage()`, `die()`.
  - Every instance has its own property values — but shares the same methods.
- Image: `D4Panda3.png -- not done --` — labeled panda diagram: arrows pointing to hp, hunger, personality labels; eat() and take_damage() callouts
- Caption: none
- Notes: Properties = nouns. Methods = verbs. This framing will recur all day. The diagram helps visual learners; instructor can sketch it on a whiteboard too.

#### Slide D4-S025 — Quiz: two pandas
- Format: G05 Concept Explanation
- Title: "Quick check"
- Body:
  - Panda A: hp = 80, hunger = 30.
  - P1 attacks Panda A → `take_damage(15)` → Panda A hp = **65**.
  - Does Panda B's hp change?
  - Answer: **No.** Each instance has its own `hp`. Damage to A doesn't touch B.
- Image: none
- Caption: none
- Notes: Rhetorical quiz — ask the room, wait for answers, then reveal. The correct answer should feel obvious once stated. Reinforce: "Independent copies. That's the whole point of objects."

#### Slide D4-S026 — Shape in code: Panda class
- Format: G10 Code
- Title: "Panda class in GDScript"
- Body:
  ```gdscript
  class Panda:
      var hp    := 100
      var hunger := 0
      var personality := "lazy"

      func take_damage(amount):
          hp -= amount
          if hp <= 0:
              die()

      func die():
          print(personality, " panda fainted")
  ```
- Image: none
- Caption: none
- Notes: Board example. Walk through it line by line: `class Panda:` is the blueprint. `var hp := 100` is a property with a default. `func take_damage(amount):` is a method. Godot's `Player` script (which is `player.gd`) is exactly this pattern — it's a class with properties and methods.

#### Slide D4-S027 — Personalities preview
- Format: G05 Concept Explanation
- Title: "7 panda personalities"
- Body:
  - lazy — sits around, minimal movement
  - playful — chases other pandas
  - aggressive — attacks on sight
  - nervous — runs away
  - hungry — seeks bamboo
  - sleepy — falls asleep mid-fight
  - sneezy — random sneeze knocks back nearby pandas
- Image: `D4Panda4.png -- not done --` — grid of 7 pandas with personality labels
- Caption: none
- Notes: Bridge from Object concept to STATE concept (coming in chunk #5). Each personality maps to a different *state* the panda can be in. Instructor: "Sound familiar? Your fighter has personalities too — they're called idle, walk, jump, attack, hit, dead." Don't over-explain yet; plant the seed.

#### Slide D4-S028 — How objects are used in games
- Format: G05 Concept Explanation
- Title: "Objects everywhere in games"
- Body:
  - Every enemy is an object — its own HP, position, and AI state.
  - Every bullet is an object — its own speed, direction, and damage.
  - Every item on the ground is an object — its own type and pickup range.
  - The game loop just calls methods on them: `enemy.update(delta)`, `bullet.move(delta)`.
- Image: none
- Caption: none
- Notes: Big-picture context. 2 minutes max. The point: objects aren't just a language feature — they're how any game with more than one entity works. Connects to D3's enemy list: those dicts are primitive objects. Today's Player class is the real thing.

#### Slide D4-S029 — How objects are used in D4 Fighter
- Format: G05 Concept Explanation
- Title: "One class. Two fighters."
- Body:
  - One `Player` class (in `player.gd`).
  - Instantiated **twice** — once for P1, once for P2.
  - Each instance has its own `hp`, `state`, `position`, and character stats.
  - They share the same methods: `take_damage()`, `attack()`, `set_state()`.
- Image: none
- Caption: none
- Notes: Connects the abstract panda metaphor directly to the game. Instructor: "Everything you add to `player.gd` this morning, *both* fighters get automatically. You write it once — it runs for two."

#### Slide D4-S030 — Where-in-game: player.gd:48-52
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `player.gd:48-52`"
- Body: none
- Image: `D4C1.png -- not done --` — player.gd open at lines 48-52, showing `# TODO #1` marker
- Caption: "Three properties at `# TODO #1` inside the Player class body. These are the first things every fighter needs to remember about itself."
- Notes: Instructor Ctrl+G → 48 in player.gd. Show kids the `#@todo` banner. The next slide is the action.

#### Slide D4-S031 — Action #1
- Format: G09 Concept + Task
- Title: "TODO #1 — core fighter properties"
- Body LHS:
  ```gdscript
  # Panda analogy:
  class Panda:
      var hp      := 100
      var max_hp  := 100
      var facing  := 1
  ```
- Image: `D4C1.png -- not done --` — player.gd:48-52, `# TODO #1` marker visible
- Caption: "Declare the three things every Player needs to remember about itself: hp (start at 100), max_hp (also 100, for the HP bar), and facing (start at 1 = looking right)."
- Notes: T1 verbatim. LHS board example uses Panda class to keep the metaphor alive. RHS screenshot shows the exact location. Kids type three `var` lines. No after-works payoff yet — note that on next slide.

#### Slide D4-S032 — No after-works (chunk #1)
- Format: G04 Headline / Divider
- Title: "No visible payoff yet"
- Body: "Chunk #1 adds properties the game will use — but nothing appears on screen until chunk #4. Keep going."
- Image: none
- Caption: none
- Notes: Manage expectations. Kids sometimes think they broke the game when nothing changes. Reassure: "The game is like a car — you installed the fuel tank (chunk #1). You still need to install the engine (chunks #2-#4) before it moves."

### 10.5 Walks C/D (S033–S036)

#### Slide D4-S033 — Walk C Challenge: Run and confirm
- Format: G07 Step / Challenge
- Title: "Run the game — confirm no errors"
- Body: "Run the game and confirm it opens without errors."
- Image: none
- Caption: none
- Notes: Jog-memory challenge after chunk #1. Even with empty chunks, the game should compile. A typo in the var declarations will surface here. Give ~30 seconds.

#### Slide D4-S034 — Walk C Hint
- Format: G08 Step / Hint
- Title: "Walk C — hint"
- Body:
  - Press **F5** → "Set Main Scene?" → **Select Current** → game window opens.
  - Press **F8** to stop.
- Image: none
- Caption: none
- Notes: Text only — no screenshot. If kids hit the "Set Main Scene?" prompt and panic, reassure: click "Select Current" — Godot just needs to know which scene is the entry point.

#### Slide D4-S035 — Walk D Challenge: Find the error
- Format: G07 Step / Challenge
- Title: "Game didn't open? Find the error."
- Body: "Game didn't open? Find the error."
- Image: none
- Caption: none
- Notes: Only show this slide if kids report the game didn't open. Don't dwell — advance to hint after 15 seconds.

#### Slide D4-S036 — Walk D Hint
- Format: G08 Step / Hint
- Title: "Walk D — hint"
- Body:
  - Output panel (bottom) → look for red text or a blue underlined line number.
  - Click the blue line number → jumps to the error in the script.
  - Fix the typo → **Ctrl+S** → **F5** again.
- Image: none
- Caption: none
- Notes: Text only — no screenshot. Most errors at this stage are missing colons or wrong indentation in the `var` declarations. Common fix: `var hp = 100` should be `var hp := 100` (walrus operator for type inference), or the property was accidentally placed outside the class body.

### 10.6 Chunk #2 — Character-data properties (S037–S041)

#### Slide D4-S037 — Recap-bridge: data-driven properties
- Format: G04 Headline / Divider
- Title: "Remember what KIND of panda it is"
- Body: "Every fighter has different stats — Knight hits hard, Ninja moves fast. Those differences live in the CHARACTERS dict. Now we pull them into the object."
- Image: none
- Caption: none
- Notes: Recap bridge. The panda metaphor connects: "We gave the panda an hp counter (chunk #1). Now we give it the stats that make it *this specific panda* — its personality data."

#### Slide D4-S038 — Concept: data-driven properties
- Format: G05 Concept Explanation
- Title: "Dict → setup() → object vars"
- Body:
  - The `CHARACTERS` dict in `main.gd` holds raw stat values for each character.
  - `setup(char_key, player_num)` runs once when a fighter spawns — it reads the dict and copies values into `self` properties.
  - After `setup()`, the fighter knows its own `walk_speed`, `attack_damage`, etc. — no more looking up the dict.
- Image: none
- Caption: none
- Notes: Diagram on board: draw three boxes: `CHARACTERS["knight"]` → `setup()` → `self.walk_speed = ...`. The key insight: the class defines the *shape* (property names), the dict provides the *values* (per-character numbers), and `setup()` is the bridge.

#### Slide D4-S039 — Quiz: P1 Knight vs P2 Ninja walk_speed
- Format: G05 Concept Explanation
- Title: "Quick check"
- Body:
  - P1 picks Knight (`walk_speed: 220.0`). P2 picks Ninja (`walk_speed: 310.0`).
  - After `setup()` runs for each fighter, what is `p1.walk_speed`? What is `p2.walk_speed`?
  - Answer: `p1.walk_speed = 220.0`, `p2.walk_speed = 310.0`. Independent copies.
- Image: none
- Caption: none
- Notes: Rhetorical quiz. Reinforce: same class, different property values. This is exactly why objects beat dicts — Knight and Ninja are both `Player` objects, but their walk_speed properties differ because `setup()` loaded different dict values.

#### Slide D4-S040 — Where-in-game: player.gd:54-61
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `player.gd:54-61`"
- Body: none
- Image: `D4C2.png -- not done --` — player.gd open at lines 54-61, `# TODO #2` marker visible
- Caption: "Five more properties at `# TODO #2` — the character-specific stats. `setup()` will overwrite these defaults with the picked character's values."
- Notes: Instructor Ctrl+G → 54. The `setup()` function is already written (pre-given) — kids just need to declare the properties it will write to.

#### Slide D4-S041 — Action #2
- Format: G09 Concept + Task
- Title: "TODO #2 — character-data properties"
- Body LHS:
  ```gdscript
  # In main.gd CHARACTERS["knight"]:
  "walk_speed":    220.0,
  "jump_impulse":  540.0,
  "attack_type":   "melee",
  "attack_damage": 15,
  "attack_cooldown": 0.5,
  ```
- Image: `D4C2.png -- not done --` — player.gd:54-61, `# TODO #2` marker visible
- Caption: "Declare five more properties — walk_speed, jump_impulse, attack_type, attack_damage, attack_cooldown — with Knight's stats as defaults (see main.gd:6-59 CHARACTERS[\"knight\"]). setup() overwrites them with the picked character's stats."
- Notes: T2 verbatim. LHS shows the source dict values so kids know where the default numbers come from. Kids declare five `var` lines with Knight defaults. Remind: `setup()` will overwrite them — the defaults just keep the editor happy.

### 10.7 Chunk #3 — Method: take_damage() (S042–S046)

#### Slide D4-S042 — Recap-bridge: teach the panda to lose HP
- Format: G04 Headline / Divider
- Title: "Teach the panda how to lose HP"
- Body: "Properties store data. Methods make the object *do* something. Now we write the fighter's first method."
- Image: none
- Caption: none
- Notes: Recap bridge. Properties = memory. Methods = behavior. The panda has `hp` now — `take_damage()` is the method that changes it.

#### Slide D4-S043 — Method concept: func feed()
- Format: G10 Code
- Title: "A method changes an object's own data"
- Body:
  ```gdscript
  class Panda:
      var hunger := 50

      func feed():
          hunger -= 10
          print("Panda ate. Hunger now:", hunger)
  ```
- Image: none
- Caption: none
- Notes: Board example using the panda. Key point: the method changes `hunger` — the panda's *own* property. No argument needed. Contrast with `take_damage(amount)` which takes an argument (the amount). Both patterns appear in player.gd today.

#### Slide D4-S044 — Pieces you'll use
- Format: G05 Concept Explanation
- Title: "Pieces already in the file"
- Body:
  - `hp` — the property you declared in chunk #1.
  - `max_hp` — also from chunk #1; used to compute HP bar fill ratio.
  - `hit_flash_timer` — pre-given float; set it to `0.2` to trigger a flash effect.
  - `set_state(new_state)` — pre-given stub (chunk #5 fills it); call it with `"hit"`.
  - `die()` — pre-given method; call it when hp hits zero.
  - `$HPBar` — pre-given node; set `scale.x` = `hp / max_hp` to shrink the bar.
- Image: none
- Caption: none
- Notes: Remind kids that `set_state()` is not yet written — they'll fill it in chunk #5. For now it's a stub that prints. The code will technically run but `set_state` won't change behavior until chunk #5 is filled. Instructor: "Don't worry — the game won't run fully until chunk #5. Type chunk #3 now and move on."

#### Slide D4-S045 — Where-in-game: player.gd:167-176
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `player.gd:167-176`"
- Body: none
- Image: `D4C3.png -- not done --` — player.gd open at lines 167-176, `# TODO #3` marker visible
- Caption: "The `take_damage(amount)` method body at `# TODO #3`. Six lines — subtract, flash, switch state, shrink bar, maybe die."
- Notes: Instructor Ctrl+G → 167. Show the function signature above the TODO: `func take_damage(amount: float) -> void:`. Kids fill the body.

#### Slide D4-S046 — Action #3
- Format: G09 Concept + Task
- Title: "TODO #3 — take_damage()"
- Body LHS:
  ```gdscript
  # Panda analogy:
  func take_damage(amount):
      hp -= amount
      hit_flash_timer = 0.2
      set_state("hit")
      $HPBar.scale.x = hp / max_hp
      if hp <= 0:
          die()
  ```
- Image: `D4C3.png -- not done --` — player.gd:167-176, `# TODO #3` marker visible
- Caption: "Subtract amount from hp, set hit_flash_timer to 0.2, switch state to \"hit\", shrink the HP bar to match the new hp/max_hp ratio, and call die() if hp dropped to zero."
- Notes: T3 verbatim. Note: `set_state()` stub exists but chunk #5 is not yet filled — the file will compile, but the hit state won't visually change behavior yet. Kids type six lines. After this chunk, the method exists but won't be called until chunk #7 connects the attack flow.

### 10.8 Chunk #4 — Two instances (S047–S052)

#### Slide D4-S047 — Recap-bridge: spawn two fighters
- Format: G04 Headline / Divider
- Title: "Time to spawn two of them"
- Body: "The Player class exists. The properties are declared. Now we create two instances — one for each player — and put them in the scene."
- Image: none
- Caption: none
- Notes: Recap bridge. The panda metaphor: "You wrote the Panda blueprint (chunks #1-#3). Now you're stamping out two actual pandas and dropping them into the world."

#### Slide D4-S048 — Class vs instance refresher
- Format: G10 Code
- Title: "Panda.new() × 2"
- Body:
  ```gdscript
  # Two independent instances from one blueprint
  var panda_a = Panda.new()
  var panda_b = Panda.new()

  panda_a.hp = 80   # only A changes
  print(panda_b.hp) # still 100 — B is unaffected
  ```
- Image: none
- Caption: none
- Notes: Refresher board example. Directly revisits the S025 quiz. Instructor: "This is exactly what main.gd does with the Player scene — twice."

#### Slide D4-S049 — Godot instantiate framing
- Format: G05 Concept Explanation
- Title: "In Godot: PLAYER_SCENE.instantiate()"
- Body:
  - `Panda.new()` in plain GDScript = `PLAYER_SCENE.instantiate()` in Godot.
  - Both create a fresh copy of the blueprint.
  - After `instantiate()`, call `add_child()` to put it in the scene tree, then `setup()` to load character data.
- Image: none
- Caption: none
- Notes: Bridge between the panda metaphor and Godot's scene system. Instructor: "The Player scene is the panda blueprint. `instantiate()` stamps out a copy. `add_child()` drops it into the world. `setup()` tells it which character it is."

#### Slide D4-S050 — Where-in-game: main.gd:205-212
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `main.gd:205-212`"
- Body: none
- Image: `D4C4.png -- not done --` — main.gd open at lines 205-212, `# TODO #4` marker visible
- Caption: "Two instantiate + setup calls at `# TODO #4` in `main.gd`. One for P1, one for P2."
- Notes: Instructor Ctrl+G → 205 in main.gd. Point out `PLAYER_SCENE` is already declared at the top of the file as a `preload()`.

#### Slide D4-S051 — Action #4
- Format: G09 Concept + Task
- Title: "TODO #4 — spawn two fighters"
- Body LHS:
  ```gdscript
  # Panda analogy:
  var panda_a = Panda.new()
  add_child(panda_a)

  var panda_b = Panda.new()
  add_child(panda_b)
  ```
- Image: `D4C4.png -- not done --` — main.gd:205-212, `# TODO #4` marker visible
- Caption: "Instantiate the Player scene twice — once for Player 1, once for Player 2. Add each to the tree and call setup() — Player 1 at Vector2(200, 500), Player 2 at Vector2(1080, 500)."
- Notes: T4 verbatim. Kids write six lines. Exact shape: `var p1 = PLAYER_SCENE.instantiate()`, `add_child(p1)`, `p1.setup("knight", 1, Vector2(200, 500))` (actual signature — char key, player number, start position). Same for p2 with the P2 character key and `Vector2(1080, 500)`. After-works payoff is HUGE — advance to next slide.

#### Slide D4-S052 — After-works PAYOFF: fighters on screen
- Format: G12 Screenshot + Caption
- Title: "FIGHTERS ARE ON SCREEN."
- Body: none
- Image: `D4WalkMF5.png -- not done --` — fight screen now showing two fighter sprites at opposite ends
- Caption: "FIGHTERS ARE ON SCREEN. They can't move yet — chunk #6 is still empty. But they exist. Press R to restart."
- Notes: FIRST VISIBLE PAYOFF of the day. Make this a moment. Instructor: F5 → char-select → map-select → countdown → two fighters appear. Kids cheer. Then: "They're frozen because we haven't given them a state machine yet. That's chunk #5 and #6."

### 10.9 Chunk #5 — State variable + set_state() (S053–S063)

#### Slide D4-S053 — State concept divider
- Format: G04 Headline / Divider
- Title: "Objects can change mode."
- Body: none
- Image: none
- Caption: none
- Notes: Section divider. Transition cue: "The panda exists. Now we teach it to know what it's doing."

#### Slide D4-S054 — Hook: traffic light
- Format: G04 Headline / Divider
- Title: "What does the light know?"
- Body: none
- Image: `D4Traffic1.png -- not done --` — full-bleed traffic light image
- Caption: none
- Notes: Full-bleed image. No text. Instructor: "Look at this traffic light. What does it know right now?" Pause. "It knows it's RED. That one piece of information — red, yellow, or green — changes everything it does." Then advance.

#### Slide D4-S055 — Word reveal: STATE
- Format: G05 Concept Explanation
- Title: "STATE"
- Body: "A state is a mode — one string that tells the object what it's doing right now."
- Image: `D4Traffic1.png -- not done --` — same traffic light image, "STATE" overlaid
- Caption: none
- Notes: Word reveal ON the traffic light. One sentence definition. The traffic light's state is `"red"`, `"yellow"`, or `"green"`. A fighter's state is `"idle"`, `"walk"`, `"jump"`, `"attack"`, `"hit"`, or `"dead"`.

#### Slide D4-S056 — Three states + behaviors table
- Format: G05 Concept Explanation
- Title: "State controls behavior"
- Body:
  | State | What the light does |
  |-------|-------------------|
  | `"red"` | Cars must stop. Pedestrians walk. |
  | `"yellow"` | Cars slow down. No new pedestrians. |
  | `"green"` | Cars go. Pedestrians wait. |
- Image: none
- Caption: none
- Notes: Table format. Key insight: the SAME traffic light does completely different things depending on one string. No new hardware — just a different state. Fighters work identically: `"idle"` → stand still; `"walk"` → move; `"jump"` → apply gravity and check landing.

#### Slide D4-S057 — Transitions on events
- Format: G05 Concept Explanation
- Title: "States change on events"
- Body:
  - Timer runs out → `"red"` → `"green"`
  - Timer runs out → `"green"` → `"yellow"`
  - Timer runs out → `"yellow"` → `"red"`
  - A state machine: a set of states + the rules for switching between them.
- Image: none
- Caption: none
- Notes: Draw the cycle on the whiteboard: red → green → yellow → red (circle with arrows). Fighters: idle → walk (move key pressed) → jump (jump key pressed) → fall (velocity positive) → idle (landed). Events trigger transitions.

#### Slide D4-S058 — Shape in code: traffic light class
- Format: G10 Code
- Title: "State machine in GDScript"
- Body:
  ```gdscript
  class TrafficLight:
      var state := "red"

      func tick(delta):
          match state:
              "red":
                  cars_must_stop()
              "yellow":
                  cars_slow_down()
              "green":
                  cars_go()

      func set_state(new_state):
          if new_state == state:
              return
          state = new_state
  ```
- Image: none
- Caption: none
- Notes: Board example. This is the exact shape of the Player class — just with different state names and different branch functions. `match state:` is GDScript's `switch`. `set_state()` guards against redundant transitions (same state → do nothing).

#### Slide D4-S059 — Quiz: state transition
- Format: G05 Concept Explanation
- Title: "Quick check"
- Body:
  - Traffic light is `"red"`. A pedestrian presses the crossing button.
  - `set_state("green")` is called.
  - What happens? What is `state` after the call?
  - Answer: `state` becomes `"green"`. On next `tick()`, `cars_go()` runs instead of `cars_must_stop()`.
- Image: none
- Caption: none
- Notes: Rhetorical quiz. Reinforce: one string variable changes the whole object's behavior. That's it.

#### Slide D4-S060 — D4 Fighter state diagram
- Format: G05 Concept Explanation
- Title: "Your fighter's 6 states"
- Body:
  - `"idle"` → stand still; press move → `"walk"`; press jump → `"jump"`
  - `"walk"` → move; release → `"idle"`; jump key → `"jump"`
  - `"jump"` → rising; velocity flips → `"fall"`
  - `"fall"` → falling; land → `"idle"`
  - `"attack"` → swing/fire; timer done → `"idle"` (pre-given)
  - `"hit"` → flash; timer done → `"idle"` (pre-given)
  - `"dead"` → terminal; no transitions out (pre-given)
- Image: none
- Caption: none
- Notes: Circle diagram in the body or on the whiteboard. Kids will fill transitions for idle, walk, jump, and fall in chunk #6 (4 sub-holes). Attack, hit, and dead transitions are pre-given.

#### Slide D4-S061 — Where-in-game: player.gd:63-72
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `player.gd:63-72`"
- Body: none
- Image: `D4C5.png -- not done --` — player.gd open at lines 63-72, `# TODO #5` marker visible
- Caption: "The state variable declaration and `set_state()` body at `# TODO #5`."
- Notes: Instructor Ctrl+G → 63. Show the `set_state()` function stub above the TODO — kids fill the declaration and the guard + assignment inside the function.

#### Slide D4-S062 — Action #5
- Format: G09 Concept + Task
- Title: "TODO #5 — state variable + set_state()"
- Body LHS:
  ```gdscript
  # Traffic light analogy:
  var state := "red"

  func set_state(new_state):
      if new_state == state:
          return
      print(new_state)
      state = new_state
  ```
- Image: `D4C5.png -- not done --` — player.gd:63-72, `# TODO #5` marker visible
- Caption: "Declare state (start at \"idle\"). In set_state(new_state): return if it matches the current state, otherwise print new_state and update state."
- Notes: T5 verbatim. LHS uses the traffic light shape for continuity. Kids write: `var state := "idle"` and the three-line `set_state()` body. After this chunk, the Output panel will print state transitions — powerful debugging tool for chunk #6.

#### Slide D4-S063 — No after-works (chunk #5)
- Format: G04 Headline / Divider
- Title: "No new visible payoff"
- Body: "State is declared. But nothing reacts to it yet — chunk #6 fills the branches. Keep going."
- Image: none
- Caption: none
- Notes: Manage expectations. Quick beat — move immediately to chunk #6 section divider.

### 10.10 Chunk #6 R5 partial (S064–S073)

#### Slide D4-S064 — Recap-bridge: use the state variable
- Format: G04 Headline / Divider
- Title: "Use the state — make the panda behave per state"
- Body: "The state string exists. Now write the rules: what does each state DO every frame?"
- Image: none
- Caption: none
- Notes: Recap bridge. The traffic light analogy: tick() reads the state and branches. `_physics_process()` in player.gd does the same thing — it reads `state` every frame and branches on it.

#### Slide D4-S065 — `match` framing
- Format: G05 Concept Explanation
- Title: "`match state:` — six branches"
- Body:
  - `_physics_process(delta)` runs every frame (~60×/second).
  - Inside it: `match state:` checks the current state string.
  - Six branches: `"idle"`, `"walk"`, `"jump"`, `"fall"`, `"attack"`, `"hit"`.
  - Each branch runs ONLY when the fighter is in that state.
- Image: none
- Caption: none
- Notes: `match` is GDScript's switch/case. The six-branch structure is pre-given (Chunk #6 is R5 partial — the dispatcher + velocity code + attack/hit/dead exits are pre-written). Kids only fill 4 sub-holes: the state-transition `if` blocks inside idle, walk, jump, and fall.

#### Slide D4-S066 — Pre-given vs kid breakdown
- Format: G05 Concept Explanation
- Title: "What's written vs what you write"
- Body:
  - Pre-given (gray):
    - The `match state:` dispatcher itself
    - Velocity application (gravity, horizontal movement)
    - `attack` branch (full — you wrote attack() in chunk #7)
    - `hit` branch (full — uses hit_flash_timer)
    - `dead` branch (full — freezes the fighter)
  - You write (red — 4 holes):
    - Inside `"idle"`: when to switch to `"walk"` and `"jump"`
    - Inside `"walk"`: when to switch to `"idle"` and `"jump"`
    - Inside `"jump"`: when to switch to `"fall"`
    - Inside `"fall"`: when to switch to `"idle"`
- Image: none
- Caption: none
- Notes: Two-tone framing: gray = pre-given, red = kid holes. This is the R5 partial-section approach. Reassure: "Most of the state machine is already there — you're filling four transition guards, nothing else."

#### Slide D4-S067 — get_move_direction() helper
- Format: G10 Code
- Title: "`get_move_direction()` helper"
- Body:
  ```gdscript
  # Pre-given helper — already in player.gd
  func get_move_direction() -> float:
      var left  = Input.is_action_pressed("p%d_left"  % player_num)
      var right = Input.is_action_pressed("p%d_right" % player_num)
      return float(right) - float(left)
      # Returns: -1.0 (left), 0.0 (still), 1.0 (right)
  ```
- Image: none
- Caption: none
- Notes: Pre-given helper — kids call it, don't write it. Returns -1, 0, or 1. Non-zero → the player is pressing a move key. Zero → no input. Used in idle and walk branches to detect whether to switch state.

#### Slide D4-S068 — Where-in-game: full two-tone overlay
- Format: G12 Screenshot + Caption
- Title: "The full state machine — your four holes"
- Body: none
- Image: `D4C6.png` — player.gd:109-159 with two-tone overlay (gray pre-given lines, red kid-hole lines)
- Caption: "Gray = already written for you. Red = your four holes — one per state."
- Notes: Two-tone overlay. Instructor: point to each red section in turn. "Idle → you write two if-blocks. Walk → two more. Jump → one. Fall → one." Per-hole action slides follow.

#### Slide D4-S069 — Action #6a: idle exits
- Format: G09 Concept + Task
- Title: "TODO #6a — idle exits"
- Body LHS:
  ```gdscript
  # Traffic light: red → green on button press
  if button_pressed:
      set_state("green")

  # Idle exits:
  if get_move_direction() != 0:
      set_state("walk")
  if jump_pressed and is_on_floor():
      velocity.y = -jump_impulse
      set_state("jump")
  ```
- Image: `D4C6.png` — player.gd:116-122, idle branch red overlay
- Caption: "We know idle exists — inside the idle branch: switch to \"walk\" when get_move_direction() is non-zero, and switch to \"jump\" (with upward velocity.y) when jump is pressed on the floor."
- Notes: T6a verbatim. `jump_pressed` = `Input.is_action_just_pressed("p%d_jump" % player_num)` — already computed earlier in `_physics_process()` (pre-given). `is_on_floor()` is a built-in CharacterBody2D method.

#### Slide D4-S070 — Action #6b: walk exits
- Format: G09 Concept + Task
- Title: "TODO #6b — walk exits"
- Body LHS:
  ```gdscript
  # Walk exits — symmetric to idle:
  if get_move_direction() == 0:
      set_state("idle")
  if jump_pressed and is_on_floor():
      velocity.y = -jump_impulse
      set_state("jump")
  ```
- Image: `D4C6.png` — player.gd:126-132, walk branch red overlay
- Caption: "Inside the walk branch: when get_move_direction() is zero, switch back to \"idle\". When jump is pressed on the floor, set velocity.y = -jump_impulse and switch to \"jump\"."
- Notes: T6b verbatim. Mirror of idle — symmetric structure reinforces the pattern. The jump block is identical to the idle branch; instructor can ask "what's the same? what's different?" (Only the first condition differs: `!= 0` vs `== 0`.)

#### Slide D4-S071 — Action #6c: jump exit
- Format: G09 Concept + Task
- Title: "TODO #6c — jump exit"
- Body LHS:
  ```gdscript
  # Jumped up — now falling:
  if velocity.y > 0:
      set_state("fall")
  ```
- Image: `D4C6.png` — player.gd:136-139, jump branch red overlay
- Caption: "Inside the jump branch: when velocity.y > 0 (upward velocity has run out), switch to \"fall\"."
- Notes: T6c verbatim. Gravity (pre-given) pulls velocity.y toward positive every frame. Once it crosses zero, the panda is falling. Smallest hole — two lines. Quick win.

#### Slide D4-S072 — Action #6d: fall exit
- Format: G09 Concept + Task
- Title: "TODO #6d — fall exit"
- Body LHS:
  ```gdscript
  # Landed:
  if is_on_floor():
      set_state("idle")
  ```
- Image: `D4C6.png` — player.gd:143-146, fall branch red overlay
- Caption: "When is_on_floor() is true, the player has landed — switch back to \"idle\"."
- Notes: T6d verbatim. Smallest hole — two lines. After this, the Output panel prints `walk`, `jump`, `fall`, `idle` as the fighter moves — major feedback moment even before the payoff screenshot.

#### Slide D4-S073 — After-works BIG PAYOFF: panda moves
- Format: G12 Screenshot + Caption
- Title: "PANDA MOVES."
- Body: none
- Image: `D4B2S4.png -- not done --` — game running mid-jump, fighter airborne
- Caption: "PANDA MOVES. Press A/D to walk. W to jump. Watch the Output panel — walk / jump / fall / idle print as states change. Attack key fires but does no damage yet — that's chunk #7."
- Notes: SECOND VISIBLE PAYOFF. Make this a moment. Kids test movement for 2-3 minutes. Instructor circulates. If the Output panel isn't printing, the `set_state()` print line is missing — quick fix. Attack animations may fire (pre-given trigger) but no damage yet.

### 10.11 Chunk #7 — attack() body (S074–S080)

#### Slide D4-S074 — Recap-bridge: make the attack do something
- Format: G04 Headline / Divider
- Title: "Make the attack DO something"
- Body: "Fighters can move. Now make the attack key actually deal damage."
- Image: none
- Caption: none
- Notes: Recap bridge. Quick beat — kids are energised from the movement payoff. Channel it into the final morning chunk.

#### Slide D4-S075 — `match attack_type` framing
- Format: G05 Concept Explanation
- Title: "`match attack_type:` — two branches"
- Body:
  - `attack_type` is `"melee"` or `"projectile"` (set by chunk #2 / `setup()`).
  - Inside `attack()`: `match attack_type:` branches once — melee hits the nearby opponent directly; projectile fires a scene instance.
  - Same `match` pattern as the state machine — one string decides what happens.
- Image: none
- Caption: none
- Notes: Connects back to the state machine shape. `match` is the hammer; kids have already used it in chunk #6. Now they use it again with two branches instead of six.

#### Slide D4-S076 — Pieces you'll use
- Format: G05 Concept Explanation
- Title: "Pieces already in the file"
- Body:
  - `attack_cooldown_timer` — pre-given float; set to `attack_cooldown` to start the cooldown.
  - `melee_swing_timer` — pre-given float; set to `0.15` to trigger the swing rectangle draw.
  - `queue_redraw()` — pre-given Godot call; redraws the swing rectangle.
  - `get_opponent()` — pre-given method; returns the other Player node (or null if dead).
  - `spawn_projectile()` — pre-given method; fires a Projectile scene in the facing direction.
- Image: none
- Caption: none
- Notes: Kids use these five pieces — they don't write them. The core logic they write: compute `to_opp`, evaluate `facing_opponent`, and run the `if` check. Two lines are also pre-given inside the todo block (`in_range` and `same_height` using `abs()`).

#### Slide D4-S077 — No wicked one-liners
- Format: G09 Concept + Task
- Title: "Name your booleans"
- Body LHS:
  ```gdscript
  # BAD — one wicked one-liner:
  if abs(opponent.pos.x - pos.x) < rng \
     and abs(opponent.pos.y - pos.y) < 40 \
     and sign(opponent.pos.x - pos.x) == facing:
      opponent.take_damage(dmg)
  ```
- Image: none
- Caption: "The same check with named booleans: three readable lines instead of one unreadable wall. If it breaks, you know which condition failed."
- Notes: RHS (or body continuation) shows the GOOD version:
  ```gdscript
  var in_range       = abs(to_opp.x) < attack_range
  var same_height    = abs(to_opp.y) < 40.0
  var facing_opponent = sign(to_opp.x) == facing
  if in_range and facing_opponent and same_height:
      opponent.take_damage(attack_damage)
  ```
  Instructor: "When you debug, you can print each bool separately. You can't debug a wall." This is the concept payoff for the R5 two-tone overlay approach.

#### Slide D4-S078 — Where-in-game: player.gd:178-199
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `player.gd:178-199`"
- Body: none
- Image: `D4C7.png -- not done --` — player.gd:178-199, `# TODO #7` marker visible with two-tone overlay (gray pre-given lines, red kid lines)
- Caption: "The `attack()` body at `# TODO #7`. Gray lines are pre-given. Red lines are yours."
- Notes: Two-tone overlay on the screenshot. Gray: `in_range` and `same_height` lines (pre-given inside the block). Red: `facing_opponent` bool and the final `if` check. The `"projectile":` branch is one line: `spawn_projectile()`.

#### Slide D4-S079 — Action #7
- Format: G09 Concept + Task
- Title: "TODO #7 — attack() body"
- Body LHS:
  ```gdscript
  # Named booleans — the good way:
  var in_range = abs(to_opp.x) < attack_range  # pre-given
  var same_height = abs(to_opp.y) < 40.0       # pre-given
  var facing_opponent = sign(to_opp.x) == facing  # YOU write this
  if in_range and facing_opponent and same_height: # YOU write this
      opponent.take_damage(attack_damage)
  ```
- Image: `D4C7.png -- not done --` — player.gd:178-199 with two-tone overlay
- Caption: "Start the cooldown: attack_cooldown_timer = attack_cooldown. Then match attack_type: — \"melee\": set melee_swing_timer = 0.15, call queue_redraw(), get the opponent with get_opponent(). return if they're null or already dead. Compute to_opp = opponent.position - position. Two lines are pre-given in your code (in_range and same_height — both use abs()). You write: var facing_opponent = sign(to_opp.x) == facing. Then if in_range and facing_opponent and same_height: opponent.take_damage(attack_damage). \"projectile\": call spawn_projectile()."
- Notes: T7 verbatim. R5 note: `in_range` and `same_height` lines are pre-given inside the block (marked `# Pre-given:`). Kid writes `facing_opponent` and the final `if` check only. Use R5 two-tone overlay on RHS screenshot: gray on `# Pre-given:` lines, red on kid lines.

#### Slide D4-S080 — After-works HUGE PAYOFF: fight loop complete
- Format: G12 Screenshot + Caption
- Title: "FIGHT LOOP COMPLETE."
- Body: none
- Image: `D4Smash1.png -- not done --` — fight screen with both fighters, HP bars visible, mid-fight
- Caption: "FIGHT LOOP COMPLETE. Hits deal damage. HP bars shrink. Hit flash fires. Someone hits 0 HP → WinLabel appears. Press R → back to char-select. The game is a game."
- Notes: THIRD AND BIGGEST PAYOFF of the morning. Let kids play for 5-10 minutes. They've earned it. Instructor circulates and asks: "Who has HP bars moving? Who got a KO?" If attack isn't registering, most common issue: `facing_opponent` bool is wrong or `to_opp` computation is off. Quick check: add `print(in_range, same_height, facing_opponent)` inside the `if` block.

### 10.12 Personalization (S081–S098)

#### Slide D4-S081 — Personalization divider
- Format: G04 Headline / Divider
- Title: "Make it yours"
- Body: none
- Image: none
- Caption: none
- Notes: Section divider. Transition cue: "Game works. Now make it *yours*. Five beats — pick any, do them in any order."

#### Slide D4-S082 — Beat 1 intro: tune character stats
- Format: G12 Screenshot + Caption
- Title: "Beat 1 — Tune a character's stats"
- Body: none
- Image: `D4B1S1.png -- not done --` — main.gd CHARACTERS dict showing Knight's walk_speed: 220.0
- Caption: "Make Knight stupidly fast or Ninja deal twice the damage. Open main.gd lines 6-59 and change any number."
- Notes: Beat 1 intro. Instructor: "Stats are just numbers in the CHARACTERS dict. Change one, save, F5 — done." This beat takes 60 seconds and produces visible results immediately.

#### Slide D4-S083 — Beat 1 before/after: stat change
- Format: G12 Screenshot + Caption
- Title: "Beat 1 — Change the value"
- Body: none
- Image: `D4B1S2.png -- not done --` — same line edited to walk_speed: 600.0
- Caption: "walk_speed: 220.0 → walk_speed: 600.0. Save → F5 → watch Knight zoom."
- Notes: Show the single-line edit. Properties to try: walk_speed, jump_impulse, attack_damage, attack_cooldown, attack_range, projectile_speed.

#### Slide D4-S084 — Beat 1 in-game result
- Format: G12 Screenshot + Caption
- Title: "Beat 1 — In-game result"
- Body: none
- Image: `D4B1S3.png -- not done --` — game running with Knight visibly faster than P2
- Caption: "Knight is now faster than Ninja. Both fighters updated automatically — same class, different setup() values."
- Notes: Reinforce the object lesson: one dict change affects that character everywhere — because `setup()` loads from the dict into the object.

#### Slide D4-S085 — Beat 2 intro: re-tint a character
- Format: G12 Screenshot + Caption
- Title: "Beat 2 — Re-tint a character"
- Body: none
- Image: `D4B2S1.png -- not done --` — Ninja in default pink tint in-game
- Caption: "The CHARACTERS dict has a \"tint\" entry: Color(R, G, B). Change it to any colour you want."
- Notes: Beat 2 intro. Very quick win — one Color() change.

#### Slide D4-S086 — Beat 2 code change
- Format: G12 Screenshot + Caption
- Title: "Beat 2 — Edit the tint"
- Body: none
- Image: `D4B2S2.png -- not done --` — CHARACTERS dict showing Ninja's tint line being edited
- Caption: "\"tint\": Color(1.0, 0.85, 0.85) → Color(0.4, 1.0, 0.4). RGB values: 0.0 = dark, 1.0 = full."
- Notes: R, G, B each 0.0–1.0. Example colour suggestions: red Knight `Color(1.0, 0.4, 0.4)`, blue Mage `Color(0.4, 0.6, 1.0)`, green Ninja `Color(0.4, 1.0, 0.4)`.

#### Slide D4-S087 — Beat 2 code after + in-game
- Format: G12 Screenshot + Caption
- Title: "Beat 2 — Green Ninja"
- Body: none
- Image: `D4B2S3.png -- not done --` — CHARACTERS dict with tint edited to Color(0.4, 1.0, 0.4)
- Caption: "Save → F5 → green Ninja. The tint applies via Modulate on the Sprite2D node — no art assets needed."
- Notes: none

#### Slide D4-S088 — Beat 2 in-game result
- Format: G12 Screenshot + Caption
- Title: "Beat 2 — In-game result"
- Body: none
- Image: `D4B2S4.png -- not done --` — game running with green Ninja vs default Knight
- Caption: "Green Ninja vs default Knight. Your tint, your fighter."
- Notes: Quick payoff. Move on.

#### Slide D4-S089 — Beat 3 intro: swap a sprite
- Format: G12 Screenshot + Caption
- Title: "Beat 3 — Swap a character's sprite"
- Body: none
- Image: `D4B3S1.png -- not done --` — FileSystem panel open showing assets/kenney_pp/characters/ folder
- Caption: "Browse the Kenney character tiles. Anything from tile_0004.png upward is fair game."
- Notes: Beat 3. Steps: FileSystem → assets/kenney_pp/characters/ → pick tile_0004.png or higher → change the "sprite" line in CHARACTERS → save → F5.

#### Slide D4-S090 — Beat 3 edit + result
- Format: G12 Screenshot + Caption
- Title: "Beat 3 — New sprite loaded"
- Body: none
- Image: `D4B3S2.png -- not done --` — CHARACTERS dict with sprite path edited to tile_0005.png
- Caption: "\"sprite\": \"res://assets/kenney_pp/characters/tile_0005.png\". Save → F5 → new fighter face."
- Notes: Remind: keep the `res://` prefix and the full path. Common mistake: dropping the `res://` prefix or using a Windows backslash.

#### Slide D4-S091 — Beat 3 in-game result
- Format: G12 Screenshot + Caption
- Title: "Beat 3 — In-game result"
- Body: none
- Image: `D4B3S3.png -- not done --` — game running with the new sprite visible
- Caption: "Different character art, same fighter logic. The sprite is just a property — swap it and everything else stays."
- Notes: none

#### Slide D4-S092 — Beat 4 intro: edit platform layout
- Format: G12 Screenshot + Caption
- Title: "Beat 4 — Edit a map's platforms"
- Body: none
- Image: `D4B4S1.png -- not done --` — default Pokémon Stadium layout with 2 platforms
- Caption: "Each map's platforms are an array in the MAPS dict: [x, y, width, height, one_way]. Add one."
- Notes: Beat 4. Steps: open main.gd lines 61-85 → find MAPS dict → pick a map → add a new platform tuple.

#### Slide D4-S093 — Beat 4 code edit
- Format: G12 Screenshot + Caption
- Title: "Beat 4 — Add a platform"
- Body: none
- Image: `D4B4S2.png -- not done --` — MAPS dict platforms array with new entry appended
- Caption: "Add [600, 320, 100, 16, true] — a small one-way platform at the centre. true = one-way (jump through from below)."
- Notes: Format: [x, y, width, height, one_way_bool]. one_way = true means you can jump through from below but land on top. false = solid wall/floor.

#### Slide D4-S094 — Beat 4 code after
- Format: G12 Screenshot + Caption
- Title: "Beat 4 — Platform in the array"
- Body: none
- Image: `D4B4S3.png -- not done --` — same array showing the new tuple added
- Caption: "Save → F5 → pick that map. Your platform is there."
- Notes: none

#### Slide D4-S095 — Beat 4 in-game result
- Format: G12 Screenshot + Caption
- Title: "Beat 4 — New platform visible"
- Body: none
- Image: `D4B4S4.png -- not done --` — game running on the edited map with new platform visible
- Caption: "New platform visible mid-stage. Fighters can jump onto it — because one_way is true."
- Notes: none

#### Slide D4-S096 — Beat 5 intro: add a fifth map
- Format: G12 Screenshot + Caption
- Title: "Beat 5 — Add a fifth map"
- Body: none
- Image: `D4B5S1.png -- not done --` — MAPS dict with 4 existing entries
- Caption: "The MAPS dict has 4 entries. Add a fifth with your own platform layout."
- Notes: Beat 5 (most involved personalisation beat). Steps: add a `"my_map": {...}` entry to MAPS → add `"my_map"` to the keys array in `_unhandled_input` → update the map-select label text.

#### Slide D4-S097 — Beat 5 code: new map entry
- Format: G12 Screenshot + Caption
- Title: "Beat 5 — New map in the dict"
- Body: none
- Image: `D4B5S2.png -- not done --` — MAPS dict with new my_map entry added
- Caption: "Add a \"my_map\" key with display_name and platforms array. Design your own stage layout."
- Notes: Template:
  ```
  "my_map": {
      "display_name": "My Map",
      "platforms": [
          [0, 600, 1280, 120, false],
          [400, 450, 150, 16, true],
          [800, 450, 150, 16, true],
      ],
  },
  ```

#### Slide D4-S098 — Beat 5 keys array + result
- Format: G12 Screenshot + Caption
- Title: "Beat 5 — Hook it into the menu"
- Body: none
- Image: `D4B5S3.png -- not done --` — _unhandled_input showing keys array with "my_map" added
- Caption: "Add \"my_map\" to the keys array in _unhandled_input. Update the map-select label: \"4 = My Map\"."
- Notes: After this, F5 → char-select → map-select → press 4 → kid's custom map loads. The beat5 payoff screenshot (D4B5S5.png) is shown on the next slide.

#### Slide D4-S099 — Beat 5 in-game result
- Format: G12 Screenshot + Caption
- Title: "Beat 5 — Your map in the game"
- Body: none
- Image: `D4B5S4.png -- not done --` — map-select panel showing "4 = My Map"
- Caption: "Press 4 in map-select — your map is playable."
- Notes: If time allows, show D4B5S5.png (game running on custom map). This beat often takes 5-10 minutes — it's the deepest personalisation option.

#### Slide D4-S100 — Beat 6: Take on the Final Challenge
- Format: G04 Headline / Divider
- Title: "Done with beats? Take on the Final Challenge."
- Body: "Invent a 5th fighter: custom stats, custom sprite, custom attack. Then fight your friend with it."
- Image: none
- Caption: none
- Notes: Pointer to FC section. Kids who finish all 5 beats quickly come here. Don't explain FC details on this slide — the FC section has its own walkthrough.

### 10.13 Final Challenge (S101–S115)

#### Slide D4-S101 — FC section divider
- Format: G04 Headline / Divider
- Title: "Final Challenge — Invent Your Own Fighter"
- Body: none
- Image: none
- Caption: none
- Notes: Section divider. FC is optional — for kids who finished all beats and are hungry for more.

#### Slide D4-S102 — FC payoff card
- Format: G05 Concept Explanation
- Title: "What you unlock"
- Body:
  - Build a 5th playable character with whatever stats, sprite, and attack type you want.
  - Give them a custom attack: invent the behavior — projectile burst, screen shake, freeze, anything.
  - Play it against your friend in the map you built in Beat 5.
- Image: none
- Caption: none
- Notes: Motivational framing. The payoff is a fully custom fighter in the game. Kids who finish all three holes have a character no one else has.

#### Slide D4-S103 — R3 pointer slide
- Format: G05 Concept Explanation
- Title: "You already know how to do this"
- Body:
  - FC-1 ← chunks #1 + #2 (property declarations → a fresh stats dict)
  - FC-2 ← chunk #4 (hook a new instance into the existing system)
  - FC-3 ← chunks #6 + #7 (add a new `match` branch + invent attack behavior)
  - Every FC hole is a *reword* of something you wrote this morning.
- Image: none
- Caption: none
- Notes: R3 required pointer slide. Instructor: "Stuck? Scroll up to the morning chunk it mirrors. Copy the *shape*, not the words." This framing prevents the FC from feeling like brand-new work.

#### Slide D4-S104 — FC enable step 1: open final_challenge.gd
- Format: G08 Step / Hint
- Title: "FC enable — step 1"
- Body:
  - FileSystem → `final_challenge.gd` → double-click.
  - Find `const CUSTOM_CHARACTER := {` at the top.
  - This is your character's stats dict — currently empty placeholders.
- Image: none
- Caption: none
- Notes: Walkthrough slide. Instructor shows `final_challenge.gd` open. Point out the empty dict and the three `# FC-1`, `# FC-2`, `# FC-3` comment markers.

#### Slide D4-S105 — FC enable step 2: wire up in main.gd
- Format: G08 Step / Hint
- Title: "FC enable — step 2"
- Body:
  - Open `main.gd` `_ready()`.
  - Add: `CHARACTERS["custom"] = CUSTOM_CHARACTER`
  - Open `player.gd` `attack()`.
  - Add a `"custom":` branch in the `match attack_type:` block.
  - Save all three files → F5.
- Image: none
- Caption: none
- Notes: The enable walkthrough wires all three files together. If kids skip FC-1 (leave CUSTOM_CHARACTER empty) the game loads but the custom character has no stats. Common: forgetting to add `"custom"` to the `keys` array in `_unhandled_input` (so the char-select panel doesn't show it).

#### Slide D4-S106 — FC-1 action slide
- Format: G09 Concept + Task
- Title: "FC-1 — Fill CUSTOM_CHARACTER"
- Body LHS:
  ```gdscript
  # Mirror of chunks #1 + #2:
  const CUSTOM_CHARACTER := {
      "display_name": "MyFighter",
      "sprite": "res://assets/kenney_pp/characters/tile_0004.png",
      "tint": Color(1, 1, 1),
      "walk_speed": 250.0,
      "jump_impulse": 540.0,
      "attack_type": "custom",
      "attack_damage": 12,
      "attack_cooldown": 0.6,
      "attack_range": 0.0,
      "projectile_speed": 0.0,
      "projectile_gravity_scale": 0.0,
  }
  ```
- Image: `D4FC1.png -- not done --` — final_challenge.gd open at CUSTOM_CHARACTER dict
- Caption: "Fill the CUSTOM_CHARACTER dict with stats for your fighter. Pick a sprite from assets/kenney_pp/characters/ (try tile_0004.png and up). Set attack_type to \"custom\" so your FC-3 branch handles it."
- Notes: Mirror of chunks #1 + #2. All 11 keys required — the game crashes if any are missing. Suggest `"attack_type": "custom"` so FC-3's match branch fires instead of melee/projectile.

#### Slide D4-S107 — FC-2 action slide
- Format: G09 Concept + Task
- Title: "FC-2 — Register in CHARACTERS"
- Body LHS:
  ```gdscript
  # In main.gd _ready(), after CHARACTERS dict:
  CHARACTERS["custom"] = CUSTOM_CHARACTER

  # In _unhandled_input keys array:
  var keys = ["knight","ninja","mage","archer","custom"]

  # Update char-select label to include:
  # "5 = MyFighter"
  ```
- Image: none
- Caption: "Register your character in main.gd so the game knows about it. Add it to the keys array and update the char-select label to show key 5."
- Notes: Mirror of chunk #4. Three touch-points: `_ready()` for the dict assignment, `_unhandled_input` for the keys array, the char-select label string. If the kid forgets the label update, the panel just shows 4 options — character still selectable by pressing 5 blindly, but less polished.

#### Slide D4-S108 — FC-3 action slide
- Format: G09 Concept + Task
- Title: "FC-3 — Custom attack branch"
- Body LHS:
  ```gdscript
  # In player.gd attack(), inside match attack_type:
  "custom":
      # Invent anything:
      # — spawn_projectile() fires forward
      # — opponent.take_damage(attack_damage * 2)
      # — call set_state("attack") again
      # — get_opponent() and push them back
      pass  # replace with your idea
  ```
- Image: `D4C7.png -- not done --` — player.gd attack() with "custom": branch location visible
- Caption: "Add a \"custom\": branch to the match attack_type block in player.gd attack(). Invent any behavior — double damage, projectile burst, screen shake, knockback. Use get_opponent(), spawn_projectile(), and take_damage() as building blocks."
- Notes: Mirror of chunks #6 + #7. The "custom" branch fires when attack_type == "custom" — which they set in FC-1. Full creativity licence. Instructor: "What would make your character feel powerful? Unfair? Funny?" Common choices: double damage one-liner, two `spawn_projectile()` calls (burst), or `opponent.take_damage()` without a range check (always hits).

#### Slide D4-S109 — Creativity menu slide 1
- Format: G05 Concept Explanation
- Title: "More ideas — stats"
- Body:
  - Max walk_speed before clipping through walls: ~800. Above 1000 = chaos.
  - jump_impulse = 1000 → moon jump.
  - attack_cooldown = 0.05 → machine gun attacks.
  - attack_damage = 99 → one-punch.
  - Combine: slow + high damage = tank. Fast + low damage = glass cannon.
- Image: none
- Caption: none
- Notes: Creativity menu. Instructor reads bullets to spark ideas. These are all safe values — nothing crashes the game.

#### Slide D4-S110 — Creativity menu slide 2
- Format: G05 Concept Explanation
- Title: "More ideas — attack behavior"
- Body:
  - Two projectiles: call `spawn_projectile()` twice with a tiny delay trick.
  - Area burst: `opponent.take_damage(attack_damage)` without checking `in_range` — always hits if facing.
  - Boomerang: set projectile_gravity_scale to a negative value in the dict.
  - Self-heal: instead of damaging the opponent, call `hp = min(hp + 10, max_hp)`.
  - Taunt: call `set_state("attack")` without dealing damage — wastes the opponent's dodge.
- Image: none
- Caption: none
- Notes: More advanced creativity prompts. Self-heal and boomerang require understanding the existing code. Taunt is a funny troll option. Instructor: "There's no wrong answer — whatever makes you laugh."

#### Slide D4-S111 — FC payoff: custom fighter in-game
- Format: G12 Screenshot + Caption
- Title: "FC done — fight your friend"
- Body: none
- Image: `D4FC4.png -- not done --` — game running with custom fighter visible in char-select or fighting
- Caption: "Your fighter is in the game. Pick them in char-select (press 5), choose your custom map, and go."
- Notes: FC payoff. If kids have time, encourage a tournament: winner stays on, next kid picks the custom character and challenges.

#### Slide D4-S112 — FC full-game payoff screenshot
- Format: G12 Screenshot + Caption
- Title: "Full roster — five fighters"
- Body: none
- Image: `D4FC5.png -- not done --` — char-select screen showing all 5 character options including custom
- Caption: "Knight. Ninja. Mage. Archer. And yours."
- Notes: Wrap up the FC pack. Instructor: "You didn't just play the game — you extended it. You added a new data object, registered it in the system, and wrote a new behavior branch. That's how professional games get new characters."

### 10.14 Day closer (S113–S115)

#### Slide D4-S113 — Recap
- Format: G05 Concept Explanation
- Title: "Objects + State. Two big ideas."
- Body:
  - **OBJECT** — a thing in code that remembers its own data and can do things. Every fighter is one `Player` object with its own `hp`, `walk_speed`, and `state`.
  - **STATE** — a mode that changes the object's behavior every frame. Six states: `idle`, `walk`, `jump`, `fall`, `attack`, `hit`/`dead`.
  - Together: a fighter that knows what it is AND what it's doing. That's a game character.
- Image: none
- Caption: none
- Notes: Day recap. Two-column format: Object (left) + State (right). Instructor can ask: "What concept from today do you think will show up in *every* game you ever build?" (Answer: both — every game entity is an object, every entity has a state.)

#### Slide D4-S114 — Tomorrow teaser
- Format: G04 Headline / Divider
- Title: "Tomorrow: Day 5"
- Body: "No new code. Play what you built across four days, show it off, and take it home."
- Image: none
- Caption: none
- Notes: Keep it brief. Kids are tired and excited. Tease the showcase without over-explaining. Mention the Windows export ZIP — they'll have a playable file they can share with friends.

#### Slide D4-S115 — Export pointer
- Format: G04 Headline / Divider
- Title: "Export time"
- Body: "Instructor will run the export for you. You leave with a .zip that runs on any Windows PC — no Godot needed."
- Image: none
- Caption: none
- Notes: Instructor note: run Project → Export → Windows Desktop. Pre-built export template should already be in Godot. ZIP the .exe + .pck + assets folder. Hand the ZIP to each kid on a USB drive or share via Google Drive link.
