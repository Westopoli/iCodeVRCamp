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


## 10. Slide blueprint (Phase 2.5 — REVISED 2026-06-20)

> D4 §10 rewritten per D4_FEEDBACK: G13/G14 TODO format, panda OOP instance visual, traffic light kept, TODO #6 compressed to one slide, TODO #7 if-only hole, personalizations spread throughout day, FC R3.2, complete character-addition steps, literal surrounding code for hard-to-find TODOs.

### 10.0 Schema

Each slide entry uses:
- **Format**: G01/G02/G03/G04/G07/G10/G12/G13/G14
- **Title**, **Body**, **Image**, **Notes** (speaker-notes pane)
- G13: `Syntax:` (comma-separated syntax_table.py keys) + `Body RHS:` (fenced gdscript, comment-only)
- G14: `Body:` = exact same comment lines as G13 RHS + **What:**/**Why:**/**How:** bullets

---

### 10.1 Opener pack (slides S001–S007)

#### Slide D4-S001 — Day title
- Format: G01 Day Title
- Title: "Day 4 — 2-Player Fighter"
- Body: "Super Smash Bros. era (N64, 1999). Today: Objects + State."
- Image: `D4T1.png` — finished fighter game, two characters mid-fight.
- Notes: —

#### Slide D4-S002 — What we're building
- Format: G04 Headline / Divider
- Title: "Today we'll build…"
- Body:
  - "A 2-player fighter game — one keyboard, two players."
  - "Four characters. Three maps. Last fighter standing wins."
  - "All playable on a Windows PC before you leave today."
- Image: `D4T1.png`
- Notes: —

#### Slide D4-S003 — Historical context
- Format: G04 Headline / Divider
- Title: "Why fighters matter"
- Body:
  - "**1991** — Street Fighter II: solo-vs-solo arcade boom."
  - "**1992** — Mortal Kombat: breakout home-console fighter."
  - "**1999** — Super Smash Bros (N64): invented roster + multi-character + percent-damage."
  - "**Today** — Smash Ultimate has 87 characters. All trace back to that N64 disc."
- Image: none
- Notes: One beat each. Keep brief.

#### Slide D4-S004 — Yesterday → Today
- Format: G04 Headline / Divider
- Title: "Yesterday → Today"
- Body:
  - "**D3:** Lists + deeper functions — enemies, towers, waves."
  - "**D4:** Two new ideas — **Objects** and **State**."
  - "Same `for` loops. Same `func` shapes. New way to package code."
- Image: none
- Notes: Callback to D3 quickly. Objects = new container. State = new label for mode.

#### Slide D4-S005 — 5-day arc
- Format: G02 Timeline / Arc
- Title: "5-day arc"
- Body:
  - "**D1 ✓** Variables + Conditions (Pong)"
  - "**D2 ✓** Loops + Functions (Maze)"
  - "**D3 ✓** Functions deep + Lists (Base Defense)"
  - "**D4 → TODAY** Objects + State (Fighter)"
  - "**D5** No new code — Escape Simulator + showcase"
- Image: none
- Notes: D4 highlighted. D5 tease.

#### Slide D4-S006 — Today's two concepts
- Format: G04 Headline / Divider
- Title: "Today's two big ideas"
- Body:
  - "**Objects** — blueprints that hold data + methods together. One class, many instances, each with its own copy of every property."
  - "**State** — a label that lets one object behave differently depending on what mode it's in."
- Image: none
- Notes: One-liner each. Don't expand — the panda and traffic light do the heavy lifting.

#### Slide D4-S007 — GDScript vs Python: class
- Format: G03 GDScript vs Python
- Title: "GDScript vs Python — classes"
- Body LHS:
  ```python
  class Player:
      def __init__(self):
          self.hp = 100

      def take_damage(self, n):
          self.hp -= n
  ```
- Body RHS:
  ```gdscript
  extends CharacterBody2D

  var hp = 100

  func take_damage(n):
      hp -= n
  ```
- Notes: Three differences only — no `class Player:` header (use `extends`), no `__init__` (vars at top), no `self.` prefix. Everything else is identical.

---

### 10.2 Pre-coding setup (slides S008–S020)

#### Slide D4-S008 — Section divider: pre-coding setup
- Format: G04 Headline / Divider
- Title: "Pre-coding setup"
- Body: "Open the project and meet the menu flow before writing any code."
- Image: none
- Notes: —

#### Slide D4-S009 — Walk A challenge: open the project
- Format: G04 Headline / Divider
- Title: "Walk A — open the Day 4 project"
- Body: "Open the Day 4 Fighter project the same way you did yesterday."
- Image: none
- Notes: Challenge slide. Wait for kids to try before showing hint.

#### Slide D4-S010 — Walk A hint
- Format: G04 Headline / Divider
- Title: "Walk A — hint"
- Body:
  - "Godot launcher → **Import** → navigate to `Day4_Fighter_Game/project.godot` → **Import & Edit**"
- Image: none
- Notes: Text + arrows only, no screenshot.

#### Slide D4-S011 — Walk B challenge: open player.gd
- Format: G04 Headline / Divider
- Title: "Walk B — open `player.gd`"
- Body: "Open `player.gd` in the script editor — most of today's work lives here."
- Image: none
- Notes: Challenge slide.

#### Slide D4-S012 — Walk B hint
- Format: G04 Headline / Divider
- Title: "Walk B — hint"
- Body:
  - "FileSystem panel → `player.gd` → double-click → Script editor opens"
- Image: none
- Notes: Text only.

#### Slide D4-S013 — Walk MF step 1: menu overview
- Format: G12 Screenshot + Caption
- Title: "Menu flow — the game already works"
- Body: "Even with empty chunks, the character select screen is live. Run it."
- Image: `D4MF1.png` — char-select panel, P1 pick prompt on screen.
- Caption: "Run F5. The menu system is fully pre-given."
- Notes: Walk through the full flow. Kids see the shell of the game before writing a single line.

#### Slide D4-S014 — Walk MF step 2: picking characters
- Format: G12 Screenshot + Caption
- Title: "Walk MF — pick your fighters"
- Body: "P1 presses **1** (Knight). P2 presses **2** (Ninja). Map select appears."
- Image: `D4MF2.png` — map select panel visible.
- Caption: "Press 1 for Battlefield. Countdown appears."
- Notes: —

#### Slide D4-S015 — Walk MF step 3: countdown
- Format: G12 Screenshot + Caption
- Title: "Walk MF — countdown"
- Body: "3… 2… 1… GO! The fight screen opens — but the fighters don't appear yet."
- Image: `D4MF3.png` — countdown label visible, empty fight arena.
- Caption: "Chunk #4 fills this gap. After you fill it, two fighters appear here."
- Notes: —

#### Slide D4-S016 — Walk MF step 4: empty arena
- Format: G12 Screenshot + Caption
- Title: "Walk MF — empty arena (chunk #4 is your fix)"
- Body: "No fighters — chunk #4 is empty. After you fill it, P1 and P2 appear here. **R** restarts to character select."
- Image: `D4MF4.png` — empty fight screen, platforms visible.
- Caption: "This gap is temporary."
- Notes: —

#### Slide D4-S017 — Walk CD step 1: CHARACTERS dict
- Format: G12 Screenshot + Caption
- Title: "CHARACTERS dict — the stat sheet"
- Body: "Open `main.gd`. Lines 6–59: the `CHARACTERS` dictionary. Each character is 11 properties."
- Image: `D4CD1.png` — main.gd open, CHARACTERS dict block visible.
- Caption: "Scroll to show all four entries."
- Notes: —

#### Slide D4-S018 — Walk CD step 2: 11 properties
- Format: G04 Headline / Divider
- Title: "11 properties per character"
- Body:
  - "`display_name`, `sprite`, `tint`"
  - "`walk_speed`, `jump_impulse` ← become chunk #2 vars"
  - "`attack_type`, `attack_damage`, `attack_cooldown`, `attack_range` ← chunk #2 vars"
  - "`projectile_speed`, `projectile_gravity_scale` ← pre-given, projectile chars only"
- Image: none
- Notes: Highlight the five that become chunk #2 vars. Bridge to "Player class gets these same names."

#### Slide D4-S019 — Walk CD step 3: bridge to Player class
- Format: G04 Headline / Divider
- Title: "The Player class mirrors this dict"
- Body:
  - "Each character's numbers live in `CHARACTERS`."
  - "`setup()` copies them onto the Player object."
  - "Pick Knight → your Player gets Knight's `walk_speed`, `attack_damage`, etc."
- Image: none
- Notes: Bridge to chunk #1 + Panda metaphor.

#### Slide D4-S020 — Many right answers
- Format: G04 Headline / Divider
- Title: "Code isn't the only way."
- Body:
  - "D1, D2, D3 — every solution looked different. All ran."
  - "Same rule today. If your version makes the game work, it's correct."
- Image: none
- Notes: Reset perfectionism pressure before a heavy OOP day.

---

### 10.3 Lesson section divider (slide S021)

#### Slide D4-S021 — Lesson section divider
- Format: G04 Headline / Divider
- Title: "Let's code."
- Body: "Seven chunks. Two big ideas. One fighter game."
- Image: none
- Notes: —

---

### 10.4 Chunk #1 — Core object properties (slides S022–S034)

#### Slide D4-S022 — Section divider: OBJECTS
- Format: G04 Headline / Divider
- Title: "Big idea #1 — Objects"
- Body: "Every fighter is an object. Let's see what that means."
- Image: none
- Notes: —

#### Slide D4-S023 — Hook: Minecraft pandas
- Format: G12 Screenshot + Caption
- Title: "Three pandas. Same game. Same script."
- Body: "What's different about them?"
- Image: `D4P1.png` — three Minecraft pandas in different poses (lazy, playful, aggressive).
- Caption: "Call out the differences: HP, pose, mood."
- Notes: No technical words yet. Invite observations.

#### Slide D4-S024 — Word reveal: Object
- Format: G04 Headline / Divider
- Title: "Each panda is one **Object**."
- Body:
  - "Minecraft has ONE panda script."
  - "But it can spawn as many pandas as it wants."
  - "Each one is its own object — its own HP, its own personality, its own position."
- Image: none
- Notes: Drop the word "object" on top of the mental image just formed.

#### Slide D4-S025 — Class vs instance visual (panda OOP)
- Format: G10 Code Shape
- Title: "Blueprint → Instances"
- Body:
  ```
  ┌────────────────────────┐
  │   Panda  (blueprint)   │
  │   hp: int              │
  │   personality: String  │
  │   facing: int          │
  └────────────────────────┘
          ↓         ↓         ↓
  ┌──────────┐ ┌──────────┐ ┌──────────┐
  │  Panda A │ │  Panda B │ │  Panda C │
  │  hp=20   │ │  hp=18   │ │  hp=5    │
  │  lazy    │ │  playful │ │  worried │
  │  facing=1│ │ facing=-1│ │  facing=1│
  └──────────┘ └──────────┘ └──────────┘
  ```
  "One blueprint. Three separate instances. Each with its OWN copy of every property."
- Image: none
- Notes: D4_FEEDBACK #2 — panda OOP instance visual. Stress OWN COPY. "Two siblings — same family, different people."

#### Slide D4-S026 — Properties + Methods
- Format: G04 Headline / Divider
- Title: "Properties + Methods"
- Body:
  - "**Properties** — what each panda *remembers*: `hp`, `personality`, `facing`"
  - "**Methods** — what each panda can *do*: `eat()`, `roll_over()`, `take_damage()`"
  - "An object bundles both together."
- Image: none
- Notes: Two words, two beats. Methods introduced here so chunk #3 doesn't feel out of nowhere.

#### Slide D4-S027 — Quiz: two pandas
- Format: G04 Headline / Divider
- Title: "Quiz"
- Body:
  - "Panda A — HP: 18. Panda B — HP: 20."
  - "You damage Panda A for 5."
  - "What's Panda B's HP?"
  - "→ **20**. Hitting A doesn't touch B. Each instance has its own copy."
- Image: none
- Notes: Fast. Drives home instance independence.

#### Slide D4-S028 — Code shape: Panda class
- Format: G10 Code Shape
- Title: "What a class looks like in code"
- Body:
  ```gdscript
  extends CharacterBody2D   # "I am a CharacterBody2D"

  var hp = 100              # property — each panda's own HP
  var personality = "lazy"  # property — each panda's own mood

  func eat():               # method — what pandas can do
      hp += 5
  ```
  "Vars at the top = properties. Funcs below = methods. Today's Player looks exactly like this."
- Image: none
- Notes: One look, one line.

#### Slide D4-S029 — Personalities bridge to State
- Format: G04 Headline / Divider
- Title: "7 panda personalities — same script, different behavior"
- Body:
  - "lazy / worried / playful / aggressive / weak / brown / normal"
  - "Each personality changes how the panda acts."
  - "That's the second big idea today: **State**. You'll meet it after chunk #4."
- Image: none
- Notes: Plant the State seed. Don't explain yet.

#### Slide D4-S030 — Objects in games
- Format: G04 Headline / Divider
- Title: "Objects everywhere in games"
- Body:
  - "Mario coin = object (collected flag, position)"
  - "Zelda enemy = object (HP, AI state, facing)"
  - "Fortnite weapon = object (ammo, damage, rarity)"
  - "If a thing has its own stats and behavior — it's an object."
- Image: none
- Notes: Quick tour. 3 beats.

#### Slide D4-S031 — D4 Fighter diagram
- Format: G04 Headline / Divider
- Title: "Today: one Player class, two instances"
- Body:
  - "ONE `Player.tscn` blueprint (same file for P1 and P2)"
  - "TWO instances at runtime (P1 Knight + P2 Ninja)"
  - "Same code — different `player_num`, different character, different HP"
- Image: none
- Notes: Mirror the panda slide. Blueprint → two instances.

#### Slide D4-S032 — Where-in-game chunk #1
- Format: G10 Code Shape
- Title: "Where in `player.gd` — TODO #1"
- Body:
  ```gdscript
  # player.gd — after setup(), declare your core properties:

  # TODO #1: Declare the three core properties every Player needs...
  #
  # Syntax:
  #   - var name: int = value
  #@todo
                           ← your code goes here
  #@end
  ```
  "Three `var` lines. Declare them directly below the TODO #1 comment block."
- Image: none
- Notes: Literal surrounding code per D4_FEEDBACK #10.

#### Slide D4-S033 — G14 Pre-TODO #1
- Format: G14 Pre-TODO
- Title: "TODO #1 — prep: three core properties"
- Body:
  ```gdscript
  # var hp: int = 100
  # var max_hp: int = 100
  # var facing: int = 1
  ```
  - **What:** Every Player needs to track its own HP and which direction it faces.
  - **Why:** `hp` and `max_hp` scale the HP bar. `facing` drives sprite flip and attack direction.
  - **How:** Three `var` lines directly inside the `#@todo` block.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S034 — G13 TODO #1
- Format: G13 TODO
- Title: "**TODO #1** — three core properties"
- Badge: "TODO #1 — three core properties"
- Syntax: var
- Body RHS:
  ```gdscript
  # var hp: int = 100
  # var max_hp: int = 100
  # var facing: int = 1
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

---

### 10.5 Chunk #2 — Character-data properties (slides S035–S040a)

#### Slide D4-S035 — Section divider chunk #2
- Format: G04 Headline / Divider
- Title: "Chunk #2 — what kind of panda are you?"
- Body: "Core HP is declared. Now declare which character's stats apply."
- Image: none
- Notes: —

#### Slide D4-S036 — Data-driven properties concept
- Format: G04 Headline / Divider
- Title: "Each character is a dictionary of stats"
- Body:
  - "`CHARACTERS[\"knight\"]` → `{walk_speed: 220, attack_damage: 18, ...}`"
  - "`setup()` copies those values onto the Player object."
  - "Pick Knight → your Player gets Knight's numbers."
- Image: none
- Notes: Bridge from Walk CD. The five vars to declare = same keys as the dict.

#### Slide D4-S037 — Quiz chunk #2
- Format: G04 Headline / Divider
- Title: "Quiz"
- Body:
  - "P1 picks Knight — `walk_speed = 220`."
  - "P2 picks Ninja — `walk_speed = 320`."
  - "Same property name. Who walks faster?"
  - "→ **P2 (Ninja)**. Same name, each instance has its OWN value."
- Image: none
- Notes: Fast. Drives home instance independence.

#### Slide D4-S038 — Where-in-game chunk #2
- Format: G10 Code Shape
- Title: "Where in `player.gd` — TODO #2"
- Body:
  ```gdscript
  # player.gd — right after TODO #1:

  # TODO #2: Declare the five properties that mirror the character config.
  #
  # Syntax:
  #   - var name: float = value
  #   - var name: String = "value"
  #@todo
                           ← your code goes here
  #@end
  ```
  "Five vars. Knight's defaults. `setup()` overwrites them when the game starts."
- Image: none
- Notes: Per D4_FEEDBACK #10 — show literal surrounding code.

#### Slide D4-S039 — G14 Pre-TODO #2
- Format: G14 Pre-TODO
- Title: "TODO #2 — prep: character config vars"
- Body:
  ```gdscript
  # var walk_speed: float = 220.0
  # var jump_impulse: float = 520.0
  # var attack_type: String = "melee"
  # var attack_damage: int = 18
  # var attack_cooldown: float = 0.55
  ```
  - **What:** Declare five properties that mirror the character dict keys.
  - **Why:** `setup()` overwrites these from `CHARACTERS[char_name]`. Defaults let the file compile before the game starts.
  - **How:** Five `var` lines right after TODO #1's block.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S040 — G13 TODO #2
- Format: G13 TODO
- Title: "**TODO #2** — character config vars"
- Badge: "TODO #2 — character config vars"
- Syntax: var
- Body RHS:
  ```gdscript
  # var walk_speed: float = 220.0
  # var jump_impulse: float = 520.0
  # var attack_type: String = "melee"
  # var attack_damage: int = 18
  # var attack_cooldown: float = 0.55
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

#### Slide D4-S040a — Personalization #1: tune character stats
- Format: G04 Headline / Divider
- Title: "Personalization #1 — tune your fighter"
- Body:
  - "In `main.gd` lines 6–59: find your character and change some numbers."
  - "Double Knight's `walk_speed`. Give Ninja's `attack_damage` a boost."
  - "Run the game (F5) and feel the difference."
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: After #2 — stats exist, a visible tweak is immediately possible.

---

### 10.6 Chunk #3 — `take_damage(amount)` (slides S041–S046)

#### Slide D4-S041 — Section divider chunk #3
- Format: G04 Headline / Divider
- Title: "Chunk #3 — teach the panda how to take damage"
- Body: "You declared HP. Now write the method that makes it go down."
- Image: none
- Notes: —

#### Slide D4-S042 — Method concept
- Format: G10 Code Shape
- Title: "Methods — functions inside a class"
- Body:
  ```gdscript
  # A method is a func INSIDE a class.
  # It can read and change the object's own properties.

  func eat():
      hunger -= 10   # changes THIS panda's hunger
  ```
  "When you call `panda.eat()`, it changes THAT panda's hunger — not any other."
- Image: none
- Notes: One-line definition. Panda flavored.

#### Slide D4-S043 — Pieces you'll use
- Format: G04 Headline / Divider
- Title: "What's available in `take_damage()`"
- Body:
  - "`hp` — your chunk #1 property"
  - "`max_hp` — also chunk #1"
  - "`hit_flash_timer` — set to `0.2` to start the red flash"
  - "`set_state(\"hit\")` — chunk #5, not written yet. Type the line and move on."
  - "`hp_bar_fill.size.x` — set to `float(hp) / max_hp * 80.0` to shrink the bar"
  - "`die()` — pre-given, call if `hp <= 0`"
- Image: none
- Notes: Flag the set_state dependency explicitly: "type the line — the game won't fully run until chunk #5 is done. That's fine."

#### Slide D4-S044 — Where-in-game chunk #3
- Format: G10 Code Shape
- Title: "Where in `player.gd` — TODO #3"
- Body:
  ```gdscript
  func take_damage(amount: int) -> void:
      # TODO #3: Fill this function body.
      # Given: hp, max_hp, hit_flash_timer
      #        set_state("hit"), hp_bar_fill.size.x, die()
      #@todo
                           ← your code goes here
      #@end
  ```
  "The function signature is pre-given. Fill the body between `#@todo` and `#@end`."
- Image: none
- Notes: Per D4_FEEDBACK #10 — literal surrounding code so kids know exactly where they are.

#### Slide D4-S045 — G14 Pre-TODO #3
- Format: G14 Pre-TODO
- Title: "TODO #3 — prep: take_damage body"
- Body:
  ```gdscript
  # hp -= amount
  # hit_flash_timer = 0.2
  # set_state("hit")
  # hp_bar_fill.size.x = float(hp) / max_hp * 80.0
  # if hp <= 0:
  #     die()
  ```
  - **What:** Fill the `take_damage()` body so opponents can actually hurt each other.
  - **Why:** Without this, the HP bar never changes and nobody dies — no fight.
  - **How:** Five lines in order: subtract hp, set flash timer, switch state, resize bar, check for death.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S046 — G13 TODO #3
- Format: G13 TODO
- Title: "**TODO #3** — take_damage body"
- Badge: "TODO #3 — take_damage body"
- Syntax: minus_eq, dot_eq, if, func_call
- Body RHS:
  ```gdscript
  # hp -= amount
  # hit_flash_timer = 0.2
  # set_state("hit")
  # hp_bar_fill.size.x = float(hp) / max_hp * 80.0
  # if hp <= 0:
  #     die()
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

---

### 10.7 Walk C/D — Run and read errors (slides S047–S050)

#### Slide D4-S047 — Walk C challenge
- Format: G04 Headline / Divider
- Title: "Walk C — run the project"
- Body: "Run the game. Confirm it opens without errors."
- Image: none
- Notes: Challenge. Wait before showing hint.

#### Slide D4-S048 — Walk C hint
- Format: G04 Headline / Divider
- Title: "Walk C — hint"
- Body:
  - "**F5** → Set Main Scene? → Select Current → game opens → **F8** to stop"
- Image: none
- Notes: Text only.

#### Slide D4-S049 — Walk D challenge
- Format: G04 Headline / Divider
- Title: "Walk D — reading an error"
- Body: "Game didn't open? Find the error and fix it."
- Image: none
- Notes: Challenge.

#### Slide D4-S050 — Walk D hint
- Format: G04 Headline / Divider
- Title: "Walk D — hint"
- Body:
  - "Output panel → click the blue line number → script editor jumps to error → fix → **Ctrl+S** → **F5** again"
- Image: none
- Notes: Text only.

---

### 10.8 Chunk #4 — Two instances (slides S051–S056)

#### Slide D4-S051 — Section divider chunk #4
- Format: G04 Headline / Divider
- Title: "Chunk #4 — two fighters appear"
- Body: "You have a Player class. Time to make two of them."
- Image: none
- Notes: —

#### Slide D4-S052 — Instantiate concept
- Format: G10 Code Shape
- Title: "Instantiate = `/summon panda`"
- Body:
  ```gdscript
  # Minecraft: /summon panda           → one new panda instance
  # Godot:     PLAYER_SCENE.instantiate()  → one new Player instance

  var player1 = PLAYER_SCENE.instantiate()
  add_child(player1)           # puts it in the scene tree (it exists + runs)
  player1.setup(1, "knight", Vector2(200, 500))  # configures it
  ```
  "`instantiate()` builds a fresh Player. `add_child` puts it in the world. `setup()` tells it who it is."
- Image: none
- Notes: Minecraft /summon is the bridge. Same idea — call it, get a live object.

#### Slide D4-S053 — Where-in-game chunk #4
- Format: G10 Code Shape
- Title: "Where in `main.gd` — TODO #4"
- Body:
  ```gdscript
  func start_match(p1_char: String, p2_char: String, map_id: String) -> void:
      clear_match_state()
      build_map(map_id)

      # TODO #4: Build two Player instances — one for P1, one for P2.
      # Given: PLAYER_SCENE, player1, player2, p1_char, p2_char
      #        PLAYER_SCENE.instantiate(), add_child(node)
      #        node.setup(num, char, Vector2(x, y))
      #@todo
                           ← your code goes here
      #@end

      set_screen("countdown")
  ```
  "This is in `main.gd`, NOT `player.gd`. Inside `start_match()`."
- Image: none
- Notes: Per D4_FEEDBACK #10 — hard-to-find location. Literal surrounding code.

#### Slide D4-S054 — G14 Pre-TODO #4
- Format: G14 Pre-TODO
- Title: "TODO #4 — prep: two Player instances"
- Body:
  ```gdscript
  # player1 = PLAYER_SCENE.instantiate()
  # add_child(player1)
  # player1.setup(1, p1_char, Vector2(200, 500))
  # player2 = PLAYER_SCENE.instantiate()
  # add_child(player2)
  # player2.setup(2, p2_char, Vector2(1080, 500))
  ```
  - **What:** Spawn two Player instances at opposite ends of the map.
  - **Why:** Without this, the fight screen stays empty — no fighters appear.
  - **How:** Instantiate, add to scene, call setup. Do it twice — P1 left side, P2 right side.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S055 — G13 TODO #4
- Format: G13 TODO
- Title: "**TODO #4** — two Player instances"
- Badge: "TODO #4 — two Player instances"
- Syntax: instantiate, func_call
- Body RHS:
  ```gdscript
  # player1 = PLAYER_SCENE.instantiate()
  # add_child(player1)
  # player1.setup(1, p1_char, Vector2(200, 500))
  # player2 = PLAYER_SCENE.instantiate()
  # add_child(player2)
  # player2.setup(2, p2_char, Vector2(1080, 500))
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

#### Slide D4-S056 — After-works PAYOFF: fighters appear
- Format: G12 Screenshot + Caption
- Title: "After-works: two fighters on screen"
- Body: "F5 → pick fighters → pick map → countdown → **two characters appear at opposite ends**."
- Image: `D4AW4.png` — fight screen, P1 (Knight) on left, P2 (Ninja) on right, both standing still.
- Caption: "They can't move yet — chunk #6 is still empty. But they EXIST."
- Notes: First visible payoff of the day. Big moment.

---

### 10.9 Chunk #5 — State + `set_state()` (slides S057–S067a)

#### Slide D4-S057 — Section divider: STATE
- Format: G04 Headline / Divider
- Title: "Big idea #2 — State"
- Body: "Your fighters exist. Now teach them to change mode."
- Image: none
- Notes: —

#### Slide D4-S058 — Hook: traffic light
- Format: G12 Screenshot + Caption
- Title: "One intersection. Same hardware. Totally different behavior."
- Body: "What changes?"
- Image: `D4TL1.png` — real intersection with traffic light at red.
- Caption: "The color of the light. What the drivers do."
- Notes: Invite kids to call out what changes. No technical words yet.

#### Slide D4-S059 — Word reveal: State
- Format: G04 Headline / Divider
- Title: "The light's current mode is its **State**."
- Body:
  - "Right now the state is `\"red\"`. Cars stop."
  - "30 seconds later the state is `\"green\"`. Same intersection. Cars go."
  - "Same hardware. Different behavior. That's state."
- Image: none
- Notes: Drop the word on top of the traffic light image.

#### Slide D4-S060 — Three states table
- Format: G07 Table
- Title: "Three states — three behaviors"
- Body:
  | State | Cars do |
  |---|---|
  | `"red"` | Stop |
  | `"yellow"` | Slow down |
  | `"green"` | Go |
  "Same intersection. The state decides everything."
- Image: none
- Notes: —

#### Slide D4-S061 — Transitions on events
- Format: G04 Headline / Divider
- Title: "States change on events"
- Body:
  - "`\"red\"` → (30 s timer) → `\"green\"`"
  - "`\"green\"` → (25 s timer) → `\"yellow\"`"
  - "`\"yellow\"` → (3 s timer) → `\"red\"`"
  - "For your fighter: `\"idle\"` → (jump pressed) → `\"jump\"`"
- Image: none
- Notes: Draw the loop on a whiteboard if helpful. Timer = event. Keypress = event. Same idea.

#### Slide D4-S062 — Code shape: state machine
- Format: G10 Code Shape
- Title: "State machine in code"
- Body:
  ```gdscript
  var state = "red"

  match state:              # check current mode
      "red":
          cars_must_stop()
      "yellow":
          cars_slow_down()
      "green":
          cars_go()

  func set_state(new_state):   # helper to change mode
      if new_state == state:
          return
      print(new_state)
      state = new_state
  ```
  "One var. One match. One helper. That's a state machine. Your Player will look exactly like this."
- Image: none
- Notes: The `match` in `_physics_process` is pre-given. Kids write the helper and declare the var.

#### Slide D4-S063 — Quiz: state transition
- Format: G04 Headline / Divider
- Title: "Quiz"
- Body:
  - "Light is green. Pedestrian hits the crosswalk button. What state comes next?"
  - "→ **yellow** (then red). Green never jumps straight to red."
  - "Same rule for your panda: `\"idle\"` never jumps straight to `\"fall\"`."
- Image: none
- Notes: Fast. Drives home ordered transitions.

#### Slide D4-S064 — D4 Fighter state diagram
- Format: G04 Headline / Divider
- Title: "Your fighter's 6 states"
- Body:
  - "`\"idle\"` ↔ `\"walk\"` (move direction changes)"
  - "`\"idle\"` / `\"walk\"` → `\"jump\"` (jump pressed on floor)"
  - "`\"jump\"` → `\"fall\"` (velocity.y goes positive)"
  - "`\"fall\"` → `\"idle\"` (landed on floor)"
  - "→ `\"attack\"` from any movement state (attack pressed)"
  - "→ `\"hit\"` when damaged"
- Image: none
- Notes: Read aloud. Draw on whiteboard if time allows.

#### Slide D4-S065 — Where-in-game chunk #5
- Format: G10 Code Shape
- Title: "Where in `player.gd` — TODO #5"
- Body:
  ```gdscript
  # player.gd — after TODO #1 and #2:

  # TODO #5: Declare `state` and write the set_state() helper.
  #@todo
                           ← var state goes here
                           ← func set_state() goes here
  #@end
  ```
  "One `#@todo` block covers both the var and the function."
- Image: none
- Notes: Per D4_FEEDBACK #10. The hole is unusual — spans both a var and a func.

#### Slide D4-S066 — G14 Pre-TODO #5
- Format: G14 Pre-TODO
- Title: "TODO #5 — prep: state var + set_state helper"
- Body:
  ```gdscript
  # var state: String = "idle"
  #
  # func set_state(new_state: String) -> void:
  #     if new_state == state:
  #         return
  #     print(new_state)
  #     state = new_state
  ```
  - **What:** Declare the `state` variable and write the helper that changes it safely.
  - **Why:** Chunk #6 reads `state` every frame. Without it, the match statement breaks.
  - **How:** Declare `var state` first. Then write `func set_state()` with the guard + print + assignment.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S067 — G13 TODO #5
- Format: G13 TODO
- Title: "**TODO #5** — state var + set_state helper"
- Badge: "TODO #5 — state var + set_state"
- Syntax: var, func_param, if, return, print
- Body RHS:
  ```gdscript
  # var state: String = "idle"
  #
  # func set_state(new_state: String) -> void:
  #     if new_state == state:
  #         return
  #     print(new_state)
  #     state = new_state
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

#### Slide D4-S067a — Personalization #2: watch state transitions
- Format: G04 Headline / Divider
- Title: "Personalization #2 — watch your states print"
- Body:
  - "After filling chunk #5, run the game (F5). Watch the Output panel."
  - "Every state change prints: `idle`, `walk`, `jump`, `fall`, `attack`, `hit`…"
  - "Try renaming `\"idle\"` to `\"chilling\"` in your `var state` line. Does it still work?"
  - "*Low on time? Skip. Finished early? This is for you.*"
- Image: none
- Notes: Light creative touch after a pure-logic chunk.

---

### 10.10 Chunk #6 — State machine branches (slides S068–S073a)

#### Slide D4-S068 — Section divider chunk #6
- Format: G04 Headline / Divider
- Title: "Chunk #6 — write the state machine"
- Body: "You have a state variable. Now decide WHEN the state changes."
- Image: none
- Notes: —

#### Slide D4-S069 — Traffic light callback
- Format: G04 Headline / Divider
- Title: "Back to the traffic light"
- Body:
  - "The `match` block runs every frame — it's already in `_physics_process` (pre-given)."
  - "Each branch checks: *should I switch state right now?*"
  - "`\"idle\"` branch: if moving → `\"walk\"`. If jump pressed → `\"jump\"`."
  - "You fill the `if` blocks inside each branch."
- Image: none
- Notes: Pre-given match dispatcher is the outer shell. Kids write the if guards inside.

#### Slide D4-S070 — Where-in-game chunk #6
- Format: G10 Code Shape
- Title: "Where in `player.gd` — TODO #6 (inside `_physics_process`)"
- Body:
  ```gdscript
  match state:
      "idle":
          velocity.x = 0       # pre-given (gray)
          # TODO #6a: switch to "walk" or "jump"
          #@todo  ←  your if blocks  #@end
      "walk":
          velocity.x = walk_speed * get_move_direction()  # pre-given (gray)
          # TODO #6b: switch to "idle" or "jump"
          #@todo  ←  your if blocks  #@end
      "jump":
          velocity.x = walk_speed * get_move_direction() * 0.85  # pre-given (gray)
          # TODO #6c: switch to "fall" when rising is done
          #@todo  ←  #@end
      "fall":
          velocity.x = walk_speed * get_move_direction() * 0.85  # pre-given (gray)
          # TODO #6d: switch to "idle" when landed
          #@todo  ←  #@end
  ```
  "Gray = pre-given velocity lines. Red = your 4 holes inside each branch."
- Image: none
- Notes: Per D4_FEEDBACK #10. Deeply nested — show full match context.

#### Slide D4-S071 — G14 Pre-TODO #6
- Format: G14 Pre-TODO
- Title: "TODO #6 — prep: 4 state transitions"
- Body:
  ```gdscript
  # "idle" branch (#6a):
  #     if get_move_direction() != 0: set_state("walk")
  #     if get_input_just_pressed("jump") and is_on_floor():
  #         velocity.y = -jump_impulse
  #         set_state("jump")
  # "walk" branch (#6b):
  #     if get_move_direction() == 0: set_state("idle")
  #     if get_input_just_pressed("jump") and is_on_floor():
  #         velocity.y = -jump_impulse
  #         set_state("jump")
  # "jump" branch (#6c):
  #     if velocity.y > 0: set_state("fall")
  # "fall" branch (#6d):
  #     if is_on_floor(): set_state("idle")
  ```
  - **What:** Fill four `if` blocks — one per state branch — deciding when to transition.
  - **Why:** Without this, fighters can't move, jump, or fall.
  - **How:** Each branch gets `if` checks on the given conditions. Call `set_state()` to switch.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S072 — G13 TODO #6 (compressed all 4 branches)
- Format: G13 TODO
- Title: "**TODO #6** — 4 state transitions (6a / 6b / 6c / 6d)"
- Badge: "TODO #6 — state transitions"
- Syntax: if, func_call
- Body RHS:
  ```gdscript
  # "idle" branch (#6a):
  #     if get_move_direction() != 0: set_state("walk")
  #     if get_input_just_pressed("jump") and is_on_floor():
  #         velocity.y = -jump_impulse
  #         set_state("jump")
  # "walk" branch (#6b):
  #     if get_move_direction() == 0: set_state("idle")
  #     if get_input_just_pressed("jump") and is_on_floor():
  #         velocity.y = -jump_impulse
  #         set_state("jump")
  # "jump" branch (#6c):
  #     if velocity.y > 0: set_state("fall")
  # "fall" branch (#6d):
  #     if is_on_floor(): set_state("idle")
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

#### Slide D4-S073 — After-works PAYOFF: fighters move
- Format: G12 Screenshot + Caption
- Title: "After-works: fighters move and jump"
- Body: "F5 → pick fighters → fight screen → fighters walk, jump, and fall."
- Image: `D4AW6.png` — P1 mid-jump, P2 walking, fight screen active.
- Caption: "Still can't attack — but the controls WORK."
- Notes: Second big payoff. Let them move around for a minute.

#### Slide D4-S073a — Personalization #3: add a platform
- Format: G04 Headline / Divider
- Title: "Personalization #3 — build your own map"
- Body:
  - "In `main.gd`, find `const MAPS := {...}`. Each platform is `[x, y, w, h, one_way]`."
  - "Add a new platform to `\"battlefield\"` — try `[540, 500, 150, 16, true]`."
  - "Run the game (F5). Jump on your platform."
  - "*Low on time? Skip. Finished early? This is for you.*"
- Image: none
- Notes: After #6 payoff (fighters move) — natural creative break.

---

### 10.11 Chunk #7 — `attack()` body (slides S074–S079a)

#### Slide D4-S074 — Section divider chunk #7
- Format: G04 Headline / Divider
- Title: "Chunk #7 — let them fight"
- Body: "State machine works. Time to write the hit check."
- Image: none
- Notes: —

#### Slide D4-S075 — attack() structure
- Format: G10 Code Shape
- Title: "`attack()` — the outer shell (pre-given)"
- Body:
  ```gdscript
  func attack() -> void:
      attack_cooldown_timer = attack_cooldown   # pre-given
      match attack_type:                        # pre-given
          "melee":
              melee_swing_timer = 0.15          # pre-given
              queue_redraw()                    # pre-given
              var opponent = get_opponent()     # pre-given
              # ── pre-given math (gray) ──────────────────
              var in_range = abs(to_opp.x) <= character_data["attack_range"]
              var facing_opponent = sign(to_opp.x) == facing
              var same_height = abs(to_opp.y) <= 60
              # ← YOUR HOLE: the if check that uses these three
          "projectile":
              spawn_projectile()               # pre-given
  ```
  "Gray = pre-given math. Your hole = the `if` that uses `in_range`, `facing_opponent`, `same_height`."
- Image: none
- Notes: Per D4_FEEDBACK #5 — students only write the if check. The abs()/sign() math is pre-given.

#### Slide D4-S076 — Where-in-game chunk #7
- Format: G10 Code Shape
- Title: "Where in `player.gd` — TODO #7"
- Body:
  ```gdscript
  # Pre-given (gray — you don't write this):
  var in_range = abs(to_opp.x) <= character_data["attack_range"]
  var facing_opponent = sign(to_opp.x) == facing
  var same_height = abs(to_opp.y) <= 60
  # TODO #7: write the if check that uses all three:
  #@todo
                           ← just the if block goes here
  #@end
  ```
  "Gray = math you don't write. Red = your two-line if check."
- Image: none
- Notes: Per D4_FEEDBACK #10. Literal surrounding code. Gray overlay on pre-given math lines.

#### Slide D4-S077 — G14 Pre-TODO #7
- Format: G14 Pre-TODO
- Title: "TODO #7 — prep: the hit-check `if`"
- Body:
  ```gdscript
  # if in_range and facing_opponent and same_height:
  #     opponent.take_damage(attack_damage)
  ```
  - **What:** Write the `if` that decides whether a melee attack lands.
  - **Why:** Three conditions must all be true: close enough, facing them, same height.
  - **How:** Two lines. `in_range`, `facing_opponent`, `same_height` are all pre-given above your hole.
- Bottom note: "This is one approach — yours works if it runs."

#### Slide D4-S078 — G13 TODO #7
- Format: G13 TODO
- Title: "**TODO #7** — the hit-check `if`"
- Badge: "TODO #7 — the hit check"
- Syntax: if, func_call
- Body RHS:
  ```gdscript
  # if in_range and facing_opponent and same_height:
  #     opponent.take_damage(attack_damage)
  ```
- Bottom note: "Detailed instructions are in your code file, right next to this TODO."

#### Slide D4-S079 — After-works PAYOFF: fight loop complete
- Format: G12 Screenshot + Caption
- Title: "After-works: the fight loop is COMPLETE"
- Body: "F5 → pick fighters → **someone can actually win.**"
- Image: `D4AW7.png` — P2 WINS! screen visible.
- Caption: "HP bars drop. Last fighter standing wins. THAT'S A FIGHTER GAME."
- Notes: Biggest payoff of the day. Let them play 2-3 minutes.

#### Slide D4-S079a — Personalization #4: tune attack stats
- Format: G04 Headline / Divider
- Title: "Personalization #4 — tune your attack"
- Body:
  - "In `main.gd` `CHARACTERS` dict: find your fighter."
  - "`attack_range` — smaller = must be close. Bigger = long reach."
  - "`attack_cooldown` — smaller = faster attacks. Bigger = slower."
  - "Make one fighter feel sluggish and one feel snappy."
  - "*Low on time? Skip. Finished early? This is for you.*"
- Image: none
- Notes: After the fight loop complete payoff — natural stat-tuning moment.

---

### 10.12 Final Challenge (slides S080–S083)

#### Slide D4-S080 — FC section divider
- Format: G04 Headline / Divider
- Title: "Final Challenge — Invent your own character"
- Body:
  - "Open `final_challenge.gd` — a separate script with `#@todo` holes."
  - "Fill FC-1, FC-2, FC-3 to add a brand-new 5th character to the roster."
  - "Pick any sprite, any stats, any attack behavior."
- Image: none
- Notes: FC is stretch/optional. Not required content.

#### Slide D4-S081 — Add new character: complete steps
- Format: G04 Headline / Divider
- Title: "Add a new character — every step"
- Body:
  - "**Step 1** — In `final_challenge.gd`: fill `CUSTOM_CHARACTER` dict (FC-1). Set `attack_type: \"custom\"`."
  - "**Step 2** — In `main.gd` `_ready()`: add `CHARACTERS[\"custom\"] = CUSTOM_CHARACTER`."
  - "**Step 3** — In `main.gd` `_unhandled_input`: add `\"custom\"` to the `keys` array as index 4."
  - "**Step 4** — Update `title_label.text` to include `5 = <YourCharacterName>`."
  - "**Step 5** — In `player.gd` `attack()`: add `\"custom\":` branch to `match attack_type:` (FC-3). Write any behavior."
  - "**Step 6** — Save all three files (`final_challenge.gd`, `main.gd`, `player.gd`). Press F5. Press 5 at char select."
- Image: none
- Notes: Per D4_FEEDBACK #8 — every step listed. No missing instructions.

#### Slide D4-S082 — FC pointer: mirror map
- Format: G04 Headline / Divider
- Title: "You already know how to do this."
- Body:
  - "**FC-1** ← Chunks **#1 + #2** (property declarations — fill the stats dict)"
  - "**FC-2** ← Chunk **#4** (hook a new instance into the system)"
  - "**FC-3** ← Chunks **#6 + #7** (match branch + hit check)"
- Image: none
- Notes: R3 requirement — read aloud. Kids find the mirror chunks first.

#### Slide D4-S083 — FC R3.2 compressed
- Format: G07 Table
- Title: "Final Challenge — all holes"
- Body:
  | FC | Mirrors | Syntax | Write this (comments) |
  |---|---|---|---|
  | **FC-1** `CUSTOM_CHARACTER` dict | #1 + #2 | `var` | `# Fill all 11 keys: display_name, sprite, tint, walk_speed, jump_impulse, attack_type ("custom"), attack_damage, attack_cooldown, attack_range, projectile_speed, projectile_gravity_scale` |
  | **FC-2** Register in CHARACTERS | #4 | `func_call` | `# CHARACTERS["custom"] = CUSTOM_CHARACTER` / `# Add "custom" to keys array` / `# Update title_label.text to show "5 = YourName"` |
  | **FC-3** custom attack branch | #6 + #7 | `match_stmt, if, func_call` | `# "custom":` / `#     opponent.take_damage(attack_damage)` / `#     (or: spawn_projectile(), hp += 5, or anything)` |
- Image: none
- Notes: Detailed instructions in `final_challenge.gd` right next to each `#@todo`.

---

### 10.13 Export to .exe (slides S084–S092)

> Reuses D1 export screenshots (`D1B6S1`–`D1B6S8`) — Godot export flow is identical every day.

#### Slide D4-S084 — Section divider: Take it home
- Format: G04 Headline / Divider
- Title: "Take it home"
- Body: "Turn your Fighter game into a real Windows `.exe` — no Godot needed."
- Image: none
- Notes: —

#### Slide D4-S085 — Export 1
- Format: G12 Screenshot + Caption
- Title: "Step 1 — Project → Export…"
- Body: "In the top menu bar, click **Project**, then **Export…**"
- Image: `D1B6S1.png`
- Notes: Save first (Ctrl+S).

#### Slide D4-S086 — Export 2
- Format: G12 Screenshot + Caption
- Title: "Step 2 — The Export window"
- Body: "Click **Add…** to add a platform target."
- Image: `D1B6S2.png`
- Notes: —

#### Slide D4-S087 — Export 3
- Format: G12 Screenshot + Caption
- Title: "Step 3 — Windows Desktop"
- Body: "Pick **Windows Desktop**."
- Image: `D1B6S3.png`
- Notes: —

#### Slide D4-S088 — Export 4
- Format: G12 Screenshot + Caption
- Title: "Step 4 — Preset ready"
- Body: "Windows Desktop preset added. Leave options as-is — **Runnable** on, **x86_64**."
- Image: `D1B6S4.png`
- Notes: —

#### Slide D4-S089 — Export 5
- Format: G12 Screenshot + Caption
- Title: "Step 5 — If a red error shows up"
- Body: "See **'No export template found'**? Click **Manage Export Templates**."
- Image: `D1B6S5.png`
- Notes: —

#### Slide D4-S090 — Export 6
- Format: G12 Screenshot + Caption
- Title: "Step 6 — Download templates"
- Body: "Click **Download and Install**. Let it finish."
- Image: `D1B6S6.png`
- Notes: —

#### Slide D4-S091 — Export 7
- Format: G12 Screenshot + Caption
- Title: "Step 7 — Name and save"
- Body: "Click **Export Project** → type `Day 4 - Fighter` → pick folder → **Save**."
- Image: `D1B6S7.png`
- Notes: —

#### Slide D4-S092 — Export 8
- Format: G12 Screenshot + Caption
- Title: "Step 8 — Double-click and play"
- Body: "Godot writes `.exe` + `.pck`. Double-click the `.exe` — runs without Godot. Keep both files together."
- Image: `D1B6S8.png`
- Notes: `.exe` needs `.pck` beside it — copy both if you move them.

---

### 10.14 Day closer (slide S093)

#### Slide D4-S093 — Tomorrow: Escape Simulator
- Format: G02 Timeline / Closer
- Title: "Tomorrow: no new code"
- Body: "Day 5 = Steam Escape Simulator workshop + showcase. You BUILD an escape room. Then you play each other's."
- Image: none
- Notes: Tease D5. No new GDScript. Pure creative application of everything built this week.

---

> Status: D4 §10 rebuilt 2026-06-20. All D4_FEEDBACK items applied: G13/G14 for all 7 TODOs, panda OOP instance visual (S025), traffic light kept (S058-S062), TODO #6 compressed to one G13 slide (S072), TODO #7 if-only hole (S078), 4 personalizations spread (S040a/S067a/S073a/S079a), FC R3.2 compressed table (S083), complete character-addition steps (S081), literal surrounding code in G14 for hard-to-find TODOs (S032/S038/S044/S053/S065/S070/S076).
