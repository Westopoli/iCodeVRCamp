# Day 4 — 2-Player Fighter (Smash Bros lite) — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 4 slide deck.
> Verified against `Day4_Fighter/main.gd` + `player.gd` + `projectile.gd` +
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

## 3. Chunk table — verified against code

In lesson order (BIBLE §4 D4 order: 1 → 2 → 3 → 4 → 5 → 6 → 7).

| # | Concept | File location | Hole lines | Hole size |
|---|---|---|---|---|
| #1 | Object properties — core (hp, facing) | `player.gd:48-52` | 3 | small |
| #2 | Object properties — character data (speed, attack stats) | `player.gd:55-61` | 5 | small |
| #3 | Method — `take_damage(amount)` | `player.gd:154-161` | 6 | medium |
| #4 | Two instances of the same class | `main.gd:205-212` | 6 | medium |
| #5 | State variable + `set_state()` helper | `player.gd:64-72` | 8 | medium |
| #6 | `match state:` block in `_physics_process` | `player.gd:103-148` | 45 | large |
| #7 | `attack()` body with `match attack_type:` | `player.gd:165-179` | 14 | medium |

**Total**: 7 `#@todo` blocks across **7 conceptual chunks**. Chunks #6 and #7 are the longest blocks of the entire camp — heavy on the kid, but the payoff is the *game becomes a fighting game* the moment they're done.

---

## 4. Pre-coding setup

> Day 1 walkthroughs A/B/C/D (open project, open script, run, read errors) reused — re-targeted to `Day4_Fighter/`. Two D4-specific moves before chunks start.

### Instructor demo — Walk the menu flow

> Run this **before** chunks start. Even though the fight loop is empty until #6 + #7 are filled, the menu screens (char select → map select → countdown → fight → end) already work. Shows kids the *shape* of the game they're about to make playable.

1. Open the project (Day 1 Walkthrough A reapplied to `Day4_Fighter`).
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
- **Goal**: Declare the three core properties every Player needs to track its own state: `hp` (health, starts at 100), `max_hp` (also 100 — used to scale the HP bar), and `facing` (1 = facing right, -1 = facing left, starts at 1). Without these, the Player class has no idea what it's *supposed* to remember.
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

---

### Chunk #2 — Object properties (character-data driven)

- **Concept**: An object's properties can come from a configuration dictionary — not every property has to be hard-coded. The `setup()` method in `player.gd` reads from `MAIN.CHARACTERS[char_name]` and copies those values into per-player vars.
- **Goal**: Declare the five properties that mirror the character config: `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`. Default values are the Knight's stats — but `setup()` overwrites them with whatever character the player picked. Without these, the Player has no idea how fast to walk, how high to jump, or which kind of attack to do.
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

---

### Chunk #3 — Method: `take_damage(amount)`

- **Concept**: A **method** is a function defined inside a class. It can read and update the object's own properties. Calling `player1.take_damage(10)` runs this method on `player1` — `hp` inside refers to `player1`'s hp.
- **Goal**: Write the body of `take_damage(amount)`: subtract `amount` from `hp`, flash the sprite red briefly, switch to the `"hit"` state, update the HP bar's visible width, and call `die()` if HP dropped to 0 or below. After this chunk, hits from the opponent actually do damage and the HP bar shrinks.
- **Board example**:
  ```gdscript
  func feed():
      hunger -= 10
  ```
- **In-file location**: `player.gd:154-161`, inside the empty `func take_damage(amount: int) -> void:` body.
- **As-typed code**:
  ```gdscript
  hp -= amount
  hit_flash_timer = 0.2
  set_state("hit")
  hp_bar_fill.size.x = (float(hp) / max_hp) * 80.0   # bar is 80px wide
  if hp <= 0:
      die()
  ```

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

> **After this chunk works**: run F5, pick characters + map → the countdown plays and both characters appear at opposite ends of the map. They don't move yet (chunk #6 is still empty) — but you can see them standing there.

---

### Chunk #5 — State variable + `set_state()` helper

- **Concept**: A **state machine** is a pattern where an object remembers what mode it's in (a string or number), and behaves differently based on that mode. The state itself is just a regular property — but it's the *anchor* for chunk #6's branching logic.
- **Goal**: Declare a `state` property (starts at `"idle"`) and write a `set_state(new_state)` helper that only triggers a change when the new state is different (so we don't spam-log every frame). The helper prints a debug line so kids can watch state transitions in the Output panel when they play. Without this, chunk #6 has nothing to branch on.
- **Board example**:
  ```gdscript
  var state = "asleep"
  func set_state(new):
      state = new
  ```
- **In-file location**: `player.gd:64-72`, under `# === KID CHUNK #5 — state var + set_state helper ===`.
- **As-typed code**:
  ```gdscript
  var state: String = "idle"

  func set_state(new_state: String) -> void:
      if new_state == state:
          return
      print("[P%d %s] state %s -> %s" % [player_num, character_name, state, new_state])
      state = new_state
  ```

---

### Chunk #6 — State machine in `_physics_process`

- **Concept**: A `match` statement reads a variable and runs the branch whose pattern matches. We use it on `state` to give each mode (`idle / walk / jump / fall / attack / hit`) its own per-frame behaviour. This is the chunk that *makes the character respond to input*.
- **Goal**: Write the `match state:` block inside `_physics_process`. Each branch decides how the player accepts input and updates velocity *for that state*. Six branches (idle, walk, jump, fall, attack, hit). After this chunk, the characters walk, jump, fall, and switch states based on input — watch the Output panel to see state transitions print as you play.
- **Board example**:
  ```gdscript
  match state:
      "asleep":
          if loud_noise():
              set_state("awake")
      "awake":
          if tired:
              set_state("asleep")
  ```
- **In-file location**: `player.gd:103-148`, inside `_physics_process(delta)`, under `# === KID CHUNK #6 — STATE MACHINE MATCH ===`.
- **As-typed code**:
  ```gdscript
  match state:
      "idle":
          velocity.x = 0
          if get_input_pressed("left") or get_input_pressed("right"):
              set_state("walk")
          if get_input_just_pressed("jump") and is_on_floor():
              velocity.y = -jump_impulse
              set_state("jump")
          if get_input_just_pressed("attack") and attack_cooldown_timer <= 0.0:
              attack()
              set_state("attack")
      "walk":
          velocity.x = walk_speed * (-1 if get_input_pressed("left") else 1 if get_input_pressed("right") else 0)
          if velocity.x == 0:
              set_state("idle")
          if get_input_just_pressed("jump") and is_on_floor():
              velocity.y = -jump_impulse
              set_state("jump")
          if get_input_just_pressed("attack") and attack_cooldown_timer <= 0.0:
              attack()
              set_state("attack")
      "jump":
          velocity.x = walk_speed * (-1 if get_input_pressed("left") else 1 if get_input_pressed("right") else 0) * 0.85
          if velocity.y > 0:
              set_state("fall")
          if get_input_just_pressed("attack") and attack_cooldown_timer <= 0.0:
              attack()
              set_state("attack")
      "fall":
          velocity.x = walk_speed * (-1 if get_input_pressed("left") else 1 if get_input_pressed("right") else 0) * 0.85
          if is_on_floor():
              set_state("idle")
          if get_input_just_pressed("attack") and attack_cooldown_timer <= 0.0:
              attack()
              set_state("attack")
      "attack":
          # cooldown is timed via attack_cooldown_timer started by attack()
          velocity.x = walk_speed * (-1 if get_input_pressed("left") else 1 if get_input_pressed("right") else 0) * (1.0 if is_on_floor() else 0.85)
          if attack_cooldown_timer <= 0.0:
              set_state("idle" if is_on_floor() else "fall")
      "hit":
          velocity.x = 0
          if hit_flash_timer <= 0.0:
              set_state("idle" if is_on_floor() else "fall")
  ```

> **After this chunk works**: characters walk + jump + fall correctly. Attack key triggers the `attack` state but doesn't do anything yet (that's #7). Hit state freezes the player briefly after taking damage. Open the Output panel during gameplay to see `[P1 Knight] state idle -> walk` style lines print as states change.

---

### Chunk #7 — `attack()` body

- **Concept**: A method can branch on one of its own object's properties. `match attack_type` lets a single `attack()` method handle both melee (Knight, Ninja) and projectile (Mage, Archer) attacks — each character picks which branch via `attack_type`.
- **Goal**: Write the body of `attack()`. Start the cooldown timer. Then branch on `attack_type`: if melee, draw a swing rectangle and damage the opponent if they're in range and facing direction; if projectile, spawn a Projectile via the pre-given helper. Without this, the attack key triggers the `attack` state but nothing visible happens.
- **Board example**:
  ```gdscript
  func bark():
      match volume:
          "loud":
              wake_neighbours()
          "soft":
              annoy_cat()
  ```
- **In-file location**: `player.gd:165-179`, inside `func attack() -> void:`, under `# === KID CHUNK #7 — attack ===`.
- **As-typed code**:
  ```gdscript
  attack_cooldown_timer = attack_cooldown
  match attack_type:
      "melee":
          melee_swing_timer = 0.15
          queue_redraw()
          var opponent = get_opponent()
          if opponent != null and not opponent.is_dead():
              var to_opp = opponent.position - position
              # in range AND in facing direction
              if abs(to_opp.x) <= character_data["attack_range"] and sign(to_opp.x) == facing and abs(to_opp.y) <= 60:
                  opponent.take_damage(attack_damage)
      "projectile":
          spawn_projectile()
  ```

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

## 9. Verification checklist (re-run if code changes)

- [x] All 6 `#@todo` blocks in `player.gd` mapped to chunk rows in §3 (#1, #2, #3, #5, #6, #7).
- [x] 1 `#@todo` block in `main.gd` mapped to chunk #4.
- [x] 1 `#@todo` block in `final_challenge.gd` mapped to FC-1.
- [x] As-typed code blocks byte-identical to source between `#@todo` and `#@end` markers.
- [x] Scene tree in §2 matches `Main.tscn` + `Player.tscn` + `Projectile.tscn` node names + types.
- [x] CHARACTERS table (§8) matches `main.gd:6-59`.
- [x] MAPS table (§8) matches `main.gd:61-85`.
- [x] Input map (§8) matches `project.godot`.
- [x] Narrative-arc card (§1) matches BIBLE §15 universal narrative arc memory (Smash Bros = 1999 N64).
- [x] Chunk order in §3 + §5 matches BIBLE §4 D4 order (1, 2, 3, 4, 5, 6, 7).
- [x] No "stretch" tag on any morning chunk; "Stretch goals" applies only to §7 FC.
- [x] Each walkthrough (Pre-coding demo + per-chunk "After this chunk works" + Personalization + FC enable) appears exactly once at its lesson position.
- [ ] Sprite picks confirmed correct on visual playtest — **PENDING**.
- [ ] Real-fight playtest with two humans — **PENDING** (stats may need rebalancing).

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 4." Output should require no follow-up clarification on chunk content. Visual playtest screenshots are a separate user-driven pass.
