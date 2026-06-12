# Day 3 — Base Defense — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 3 slide deck.
> Verified against `Day3_BaseDef_Game/main.gd`, `endless_mode.gd`, `enemy.gd`, `Main.tscn`,
> `Enemy.tscn` on 2026-05-26. Student-facing content (chunks, FC holes, teaching order)
> is stable. Non-student bits (sprite picks, obstacles, balance tuning) flagged as
> **flux** in §8 — refresh that section as rework lands. Reads top-to-bottom as the
> day's lesson flow.

## Table of contents

- **§1 Day narrative card** — era, iconic touchpoints, concepts introduced, GDScript-vs-Python card.
- **§2 Build narrative** — how Base Defense is built: scene tree, file manifest, asset pack, sim-tuning story, difficulty knob.
- **§3 Chunk table** — chunk ID → concept → file location → hole size, in BIBLE/lesson order.
- **§4 Pre-coding setup** — open project, run, read errors (Day 1 walkthroughs reused) + difficulty-knob demo specific to D3.
- **§5 Lesson chunks** — per-chunk slide source in BIBLE order. Concept → Goal → Board example → In-file location → As-typed code → Hint progression. Chunk #6 includes an "After this chunk works" walkthrough showing the game playable.
- **§6 Personalization layer** — "make it yours" end-of-day beat: tune stats, re-tint, swap sprites, drag scenery.
- **§7 Stretch goals — Final Challenge (`endless_mode.gd`)** — 4 mirror holes (FC-1..FC-4) that mirror chunks #1/#2a/#5a/#7. Ends with the endless-mode enable walkthrough.
- **§8 Asset / atlas reference** — stable items + flux flags (sprite picks, obstacles, tower physics pending rework).
- **§9 Verification checklist** — internal sanity; re-run if `main.gd` or `endless_mode.gd` changes.

---

## 1. Day narrative card

- **Era**: 90s-2000s — the tower-defense / base-defense boom (Rampart 1990, Warcraft III's "Tower Defense" custom maps 2002-2007, then Plants vs Zombies 2009 and the Bloons / Kingdom Rush wave).
- **Iconic touchpoints**: Plants vs Zombies, Bloons TD, Kingdom Rush.
- **Genre today**: real-time base defense — enemies seek your base, you spend coins on towers, multiple wave types, win by surviving the wave list.
- **Concepts introduced**: **Functions (deep)** + **Lists**. Take a list as a parameter, return one item from a list, return a filtered new list, scan-and-act on lists every frame.
- **Why this game today**: the morning's whole game loop is "scan the enemies list, scan the towers list, do something to each." Lists are the central data structure; everything the game knows about live entities lives in two lists. Functions stop being toy examples — a single `get_nearest_enemy_in_range(pos, range)` call is the load-bearing primitive every tower depends on.

### GDScript vs Python (Day 3 slide — pull verbatim)

```
Python:   enemies = []                GDScript:   var enemies = []
Python:   enemies.append("grunt")    GDScript:   enemies.append("grunt")
Python:   enemies.remove("grunt")    GDScript:   enemies.erase("grunt")
Python:   len(enemies)               GDScript:   enemies.size()

Python:   def total(numbers):        GDScript:   func total(numbers):
              s = 0                                  var s = 0
              for n in numbers:                      for n in numbers:
                  s += n                                 s += n
              return s                               return s
```

**Takeaway line**: "Lists work the same. Functions look the same — `def` is just spelled `func`. The only two-word change is `.remove(...)` → `.erase(...)` and `len(...)` → `.size()`."

---

## 2. Build narrative — how Base Defense was built

The field is a **32-tile-wide × 17-tile-tall grid** (40 px per tile → 1280 × 680 pixel playfield, plus a 40 px button bar at the bottom). The base is a two-cell red rectangle in the middle (cells `(15, 8)` and `(16, 8)`). Enemies spawn at a random outer-edge tile and walk toward a per-enemy attack point on the base perimeter (so they don't all converge on one pixel). When an enemy enters the base's Area2D, the base takes damage and the enemy is removed.

The kid spends the morning filling 8 chunks in `main.gd` — all the **list scans + function bodies** that make the game loop work. The pre-given code handles physics, sprite loading, mouse input, currency, the HUD, and the wave queue. The kid writes "what to *do* with enemies and towers each frame."

**Controls**: keys `1` / `2` / `3` (or the three buttons at the bottom) pick a tower type; **left-click** drops the selected tower on an empty grid cell if you can afford it; **SPACE** starts the next wave manually if you're not in one yet; **R** restarts. Eight waves total; survive them all → YOU WIN.

### Scene tree (Main.tscn)

```
Main (Node2D) — script: main.gd
├── Background    (ColorRect)   1280×720, dark-green (0.18, 0.42, 0.22)
├── Grid          (Node2D)      grid lines drawn at runtime (DRAW_GRID_LINES const)
├── Base          (Area2D)      position (640, 340)
│   ├── Sprite2D                tile249.png, scaled wide (1.25×0.625)
│   └── CollisionShape2D        RectangleShape2D 80×40
├── Enemies       (Node2D)      container; spawned at runtime
├── Towers        (Node2D)      container; spawned at runtime
├── Scenery       (Node2D)      pre-placed trees / rocks / fences / sign / bush
│   ├── Tree1, Tree2, Rock1, Rock2, Fence1, Fence2, Sign, Bush  (Sprite2D, art only)
│   └── Obstacle1..8           (StaticBody2D + Sprite2D + CollisionShape2D)
│                                — physical bumps on layer 4 [flux: see §8]
├── FlashLayer    (Node2D)      Line2D fire-flashes spawn here, fade out
└── UI            (CanvasLayer)
    ├── TopBar (HBox)           WaveLabel · CoinsLabel · BaseHPLabel · SelectedLabel
    ├── ButtonBar (HBox)        CannonButton · SniperButton · SplashButton · HintLabel
    ├── GameOverPanel           hidden until base HP ≤ 0
    └── YouWinPanel             hidden until all waves cleared
```

### File manifest

| File | Role | Kid edits? |
|---|---|---|
| `project.godot` | Window 1280×720; input map for `select_cannon/sniper/splash`, `start_wave`, `restart` | No |
| `Main.tscn` | Scene tree above | No (until §6 personalization, where they drag scenery) |
| `Enemy.tscn` | CharacterBody2D + CircleShape2D (radius 24) + Sprite2D + `enemy.gd` script | No |
| `main.gd` | All 8 kid chunks + every pre-given helper | **Yes — main scaffold** |
| `enemy.gd` | Per-instance enemy state (`hp`, `speed`, `enemy_type`, `target_pos`). Tiny by design. | No |
| `endless_mode.gd` | Final Challenge — 4 mirror holes (FC-1..FC-4) | **Yes — FC opt-in** |
| `INSTRUCTOR_NOTES.md` | Instructor reference | No |
| `assets/kenney_td/towerDefense_tileNNN.png` | 299-tile Kenney pack | No (kid swaps tile numbers in personalization) |

### Asset pack

- **Pack**: Kenney **Tower Defense (Top-Down)** 2D — kenney.nl, CC0 (no attribution required).
- **Filename convention**: `towerDefense_tileNNN.png` (001-299).
- **Tile picks in the scaffold** (subject to swap during visual playtest — see §8 flux):
  - Base: `tile249.png` (castle)
  - Cannon: `tile250.png`; Sniper: `tile251.png`; Splash: `tile252.png`
  - Grunt: `tile271.png`; Runner: `tile270.png`
  - Scenery: trees `tile132.png`, rocks `tile135.png`, fences `tile140.png`, sign `tile145.png`, bush `tile150.png`

### Sim / tuning story

Tower / enemy / wave tunings were **not** hand-tuned by playtest. They came from a headless Python simulation at `_balance/Day3/` that mirrors the in-game tick loop (`sim.py`), runs five scripted strategies (`strategies.py` — GreedyCannon, AllSniper, AllSplash, Mixed, Random), and iterates configs against fitness targets (`tune.py`). Final values pinned in `main.gd` lines 49-71 and mirrored in `_balance/Day3/configs.py`. Sim files live **outside** the Godot project and never ship to students.

The kid does **not** see this — slides should mention it as a one-line "the difficulty was tuned by running a Python simulation 50 times for each tower combo to make sure no tower type beats the game by itself" framing, then move on.

**Difficulty knob (`const DIFFICULTY := 2` at `main.gd:43`)**: kid-facing. 0 = easy, 1 = normal, 2 = hard. Scales enemy HP and per-wave HP bonus. Pure data-driven (`DIFF_HP_MULT`, `DIFF_WAVE_HP_BONUS` arrays). Slides should call this out as "edit one number, replay the whole game at a different difficulty — that's lists indexed by state."

---

## 3. Chunk table — verified against `main.gd`

In lesson order (BIBLE §4 order: 1 → 2 → 3 → 4 → 5a → 5b → 6 → 7). Chunk #2 has three `#@todo` sites (2a append + 2b reward-branch erase + 2b no-reward-branch erase) — presented together as a single lesson concept.

| # | Concept | File location | Hole lines | Hole size |
|---|---|---|---|---|
| #1 | Variable declaration: lists + counters | `main.gd:117-122` | 4 | small |
| #2a | `.append()` (in `spawn_enemy`) | `main.gd:284-286` | 1 | tiny |
| #2b (reward) | `.erase()` + coin reward (in `kill_enemy`) | `main.gd:307-310` | 2 | tiny |
| #2b (no-reward) | `.erase()` only (enemy reached base) | `main.gd:313-315` | 1 | tiny |
| #3 | Iterate two lists in `_process` | `main.gd:213-218` | 4 | small |
| #4 | `func` taking a list (`move_all`) | `main.gd:341-344` | 2 | small |
| #5a | `func` returning ONE from a list (`get_nearest_enemy_in_range`) | `main.gd:370-379` | 8 | medium |
| #5b | `func` returning a LIST from a list (`get_enemies_in_radius`) | `main.gd:403-409` | 5 | medium |
| #6 | Nested function calls (`match` in `tower_tick`) | `main.gd:452-464` | 11 | large |
| #7 | List size check + wave trigger | `main.gd:234-242` | 7 | medium |

**Total**: 10 `#@todo` blocks across **8 conceptual chunks**.

---

## 4. Pre-coding setup

> Day 1 walkthroughs A/B/C/D (open project, open script, run, read errors) are reused — kids already know the moves. Re-target to `Day3_BaseDef_Game/`. Below is the one Day-3-specific pre-coding move: the **difficulty-knob demo**, which the instructor runs before chunks start so kids see "edit one number, the whole game feels different."

### Instructor demo — Test the difficulty knob

> Run this **before** the kids start coding. Shows "change one number, the whole game changes" — primes them to recognise `const DIFFICULTY` as the data-indexed lever it is.

1. Open `main.gd` (Day 1 Walkthrough B reapplied to `Day3_BaseDef_Game`).
2. Scroll to line 43 — find `const DIFFICULTY := 2`.
3. Change `2` to `0` (easy).
4. Press **Ctrl+S** to save.
5. Press **F5** to run. Wave label shows "EASY"; enemies die fast.
6. Stop the game (close window or F8).
7. Change back to `2` (hard) — the camp's default.
8. Save again.

---

## 5. Lesson chunks (BIBLE order)

### Chunk #1 — Game state lists + counters

- **Concept**: Lists are made the same way as variables, just with `[]` for empty: `var x: Array = []`. Counters are just integers.
- **Goal**: Declare the four pieces of state the game needs to remember: an empty list of enemies, an empty list of towers, a coin counter starting at `START_COINS` (90), and a base-HP counter starting at `START_BASE_HP` (22). Without these, *nothing* else in the file compiles.
- **Board example**:
  ```gdscript
  var fruits: Array = []
  var score: int = 0
  ```
- **In-file location**: `main.gd:117-122`, under `# TODO #1: GAME STATE LISTS + COUNTERS`. Right after the long block of `@onready` references and the `ENEMY_SCENE` preload.
- **Surrounding context (lines 100-122)**:
  ```gdscript
  # --- preloads ---
  const ENEMY_SCENE := preload("res://Enemy.tscn")

  # ============================================================
  #  TODO #1: GAME STATE LISTS + COUNTERS
  #  ...
  # ============================================================
  #@todo
  ```
- **As-typed code**:
  ```gdscript
  var enemies: Array = []
  var towers: Array = []
  var coins: int = START_COINS
  var base_hp: int = START_BASE_HP
  ```
---

### Chunk #2 — `.append()` and `.erase()` (3 sites)

This chunk has **three `#@todo` sites** in `main.gd` — one append + two erases. They're three tiny holes that teach one concept: "lists grow with `.append()` and shrink with `.erase()`." Present them together on slides: same concept, three places to use it.

#### 2a — `.append()` in `spawn_enemy`

- **Concept**: `list.append(thing)` adds `thing` to the end of the list. The list is now one longer.
- **Goal**: After `spawn_enemy` has built a fresh enemy (`e`) and attached it to the scene, add it to the `enemies` list so the game loop knows about it. **One line.** Without this, every enemy that spawns is invisible to the game logic — it walks toward the base but never gets shot, never gets counted, never gets removed.
- **Board example**:
  ```gdscript
  fruits.append("apple")
  ```
- **In-file location**: `main.gd:284-286`, near the bottom of `spawn_enemy(...)`, under `# TODO #2a: ADD THIS ENEMY TO THE LIST`.
- **As-typed code**:
  ```gdscript
  enemies.append(e)
  ```
#### 2b — `.erase()` + coin reward (kill payout)

- **Concept**: `list.erase(thing)` removes the first occurrence of `thing` from the list. Coins are just an integer: `coins += amount`.
- **Goal**: When a tower kills an enemy, two things must happen before the enemy is freed: take it out of the `enemies` list, and pay the player the kill reward. **Two lines.** Without these, dead enemies stay in the list (and get shot at by every tower in range forever) and the player never earns coins.
- **Board example**:
  ```gdscript
  fruits.erase("apple")
  score += 10
  ```
- **In-file location**: `main.gd:307-310`, inside `kill_enemy(e, give_reward=true)`'s reward branch, under `# TODO #2b: REMOVE FROM LIST + PAY OUT`.
- **As-typed code**:
  ```gdscript
  enemies.erase(e)
  coins += reward
  ```
#### 2b (no-reward branch) — `.erase()` only

- **Goal**: When an enemy reaches the base, it's gone from the list — but the player gets no coins (the enemy *succeeded*; no tower killed it). **One line.** Without this, base-hit enemies stay in the list and the game starts misbehaving as waves stack up.
- **In-file location**: `main.gd:313-315`, in the `else` branch of `kill_enemy`.
- **As-typed code**:
  ```gdscript
  enemies.erase(e)
  ```
---

### Chunk #3 — Iterate two lists every frame

- **Concept**: `for x in list:` lets us "do something to each item." Two of them, back to back, is the entire game engine for the day.
- **Goal**: Every frame, walk through every enemy and call `step_enemy(e, delta)` on it, then walk through every tower and call `tower_tick(t, delta)` on it. Without this chunk, **nothing in the game moves or shoots** — the enemies just stand at their spawn points.
- **Board example**:
  ```gdscript
  for s in scores:
      print(s)
  ```
- **In-file location**: `main.gd:213-218`, inside `_process(delta)`, under `# TODO #3: MOVE THE WORLD`.
- **As-typed code**:
  ```gdscript
  for e in enemies:
      step_enemy(e, delta)
  for t in towers:
      tower_tick(t, delta)
  ```
> **After this chunk works**: enemies still aren't on the `enemies` list (that's #2a, which slot before #3 in BIBLE order means the spawn-and-append wiring is already in place). Run F5 — wave 1 auto-starts after a 2-second grace; enemies walk toward the base. Towers don't fire yet (that's #6) but movement is live.

---

### Chunk #4 — Function taking a list as a parameter

- **Concept**: A function can accept a list (or any collection) as one of its inputs. Inside the function, the parameter behaves exactly like a regular variable.
- **Goal**: Write `move_all(enemy_list, delta)` — same shape as chunk #3's enemy loop, but the list now comes in *through the parameter* instead of from the file-scope `enemies` variable. The chunk teaches the *shape* of a list-taking function; nothing in the scaffold calls it by default, but the kid can refactor chunk #3 to use it if they want.
- **Board example**:
  ```gdscript
  func total(numbers):
      var s = 0
      for n in numbers:
          s += n
      return s
  ```
- **In-file location**: `main.gd:341-344`, body of `func move_all(enemy_list: Array, delta: float) -> void:`.
- **As-typed code**:
  ```gdscript
  for e in enemy_list:
      step_enemy(e, delta)
  ```
---

### Chunk #5a — Function returning ONE from a list (`get_nearest_enemy_in_range`)

- **Concept**: A function can look through a list and return a *single* item that matches some condition. We track a "best so far" candidate as we go.
- **Goal**: Scan every enemy, keep track of the closest one that's still within the tower's `tower_range`, and return it. Return `null` if no enemy is in range. Cannon and Sniper towers both use this — it's the load-bearing call for single-target firing.
- **Board example**:
  ```gdscript
  func nearest(list, pos):
      var best = null
      var best_d = 999999.0
      for item in list:
          var d = pos.distance_to(item.position)
          if d < best_d:
              best = item
              best_d = d
      return best
  ```
- **In-file location**: `main.gd:370-379`, body of `func get_nearest_enemy_in_range(pos: Vector2, tower_range: float) -> Node:`.
- **As-typed code**:
  ```gdscript
  var nearest: Node = null
  var best_dist: float = tower_range + 1.0
  for e in enemies:
      var d: float = pos.distance_to(e.position)
      if d <= tower_range and d < best_dist:
          nearest = e
          best_dist = d
  return nearest
  ```
---

### Chunk #5b — Function returning a LIST from a list (`get_enemies_in_radius`)

- **Concept**: Same shape as #5a, but instead of stopping at one winner, we *collect every match into a new list*.
- **Goal**: Scan every enemy, and for each one that's within `radius` of `pos`, add it to a result list. After the loop, return the whole list. Splash towers need this — they hit *everyone* in their radius, not just the closest one.
- **Board example**:
  ```gdscript
  func filter_in_radius(list, pos, r):
      var result = []
      for item in list:
          if pos.distance_to(item.position) <= r:
              result.append(item)
      return result
  ```
- **In-file location**: `main.gd:403-409`, body of `func get_enemies_in_radius(pos: Vector2, radius: float) -> Array:`.
- **As-typed code**:
  ```gdscript
  var result: Array = []
  for e in enemies:
      if pos.distance_to(e.position) <= radius:
          result.append(e)
  return result
  ```
---

### Chunk #6 — Nested function calls (`match` in `tower_tick`)

- **Concept**: We can pass the *result* of one function straight into another function as its argument. `fire_at(t, get_nearest_enemy_in_range(...))` does two function calls in one line.
- **Goal**: Based on the tower's type, pick the right targeting function (`5a` for Cannon/Sniper, `5b` for Splash) and pass its result into the pre-given `fire_at(...)` helper. Reset the tower's `cooldown` after firing. **This is the chunk that actually makes the game playable** — until #6 is filled, towers stand still and never shoot.
- **Board example**:
  ```gdscript
  shoot(get_target(enemies))
  ```
- **In-file location**: `main.gd:452-464`, inside `tower_tick(t, delta)`, under `# TODO #6: NESTED FUNCTION CALLS — PICK + FIRE`.
- **As-typed code**:
  ```gdscript
  match t_type:
      "cannon", "sniper":
          var target: Node = get_nearest_enemy_in_range(t.position, t_range)
          if target != null:
              fire_at(t, target, t_damage)
              t.set_meta("cooldown", t_rate)
      "splash":
          var targets: Array = get_enemies_in_radius(t.position, t_range)
          if targets.size() > 0:
              fire_at(t, targets, t_damage)
              t.set_meta("cooldown", t_rate)
  ```
#### After this chunk works — Place towers and trigger a wave

> Once #6 is filled, towers actually fire. Walk the class through the in-game controls so they see their code take a wave down.

1. Press **F5** to run.
2. Look at the bottom button bar — three buttons: Cannon, Sniper, Splash.
3. Press the **1** key (or click **Cannon $28**) — top-right "Selected" label updates.
4. **Left-click** an empty grid cell near the base — a cannon sprite appears. Coins drop by 28.
5. Place two or three more towers (try a Sniper at the corner — keys **2**).
6. Press **SPACE** to start wave 1 (or just wait — wave 1 auto-starts 2 seconds in).
7. Watch enemies spawn from the edges and walk toward the base. Towers fire automatic — yellow line flashes.
8. Earn coins per kill (Coins label ticks up). Buy more towers between waves.
9. Press **R** to restart any time. (After wave 8 with chunk #7 also filled: **YOU WIN** panel.)

---

### Chunk #7 — Wave trigger + win check

- **Concept**: `list.size()` tells us how many items are in a list. We use it to detect "wave is finished".
- **Goal**: Detect when the current wave is finished (no enemies alive AND no enemies left to spawn). When it is: mark the wave as done, bump the wave counter, and either call `start_next_wave()` or — if we just finished the last wave — call `you_win()`. Without this, wave 1 never ends.
- **Board example**:
  ```gdscript
  if enemies.size() == 0:
      next_wave()
  ```
- **In-file location**: `main.gd:234-242`, in `_process`, under `# TODO #7: WAVE TRIGGER + WIN CHECK`.
- **As-typed code**:
  ```gdscript
  if wave_in_progress and enemies.size() == 0 and enemies_to_spawn.size() == 0:
      wave_in_progress = false
      wave_index += 1
      if wave_index >= WAVES.size():
          you_win()
      else:
          start_next_wave()
  ```
---

## 6. Personalization layer ("make it yours")

End-of-day beat after all morning chunks. Each beat = one walkthrough.

### Beat 1 — Tune the tower stats in code

> "Make your cannon overpowered."

1. Open `main.gd`.
2. Scroll to lines 49-53 — find the `TOWER_STATS` dictionary.
3. Each tower has: `cost`, `range`, `fire_rate`, `damage`, `hp`. Change any value.
4. Example: `"damage": 3` → `"damage": 30` on cannon → cannons one-shot grunts.
5. Save (Ctrl+S), run (F5).

### Beat 2 — Re-tint a tower with Modulate

> The simplest visual change in Godot: pick any colour for any sprite.

1. Open `main.gd` lines 49-53.
2. Each tower row ends with `"color": Color(R, G, B)`. Pick new RGB values (0.0 to 1.0).
3. Example: `Color(1.0, 0.6, 0.4)` (orange) → `Color(0.4, 0.4, 1.0)` (blue cannon).
4. Save, run — your cannons paint themselves blue.

### Beat 3 — Swap a tower's sprite

> Try a different Kenney tile for any tower.

1. Open `assets/kenney_td/` in the FileSystem panel.
2. Browse the previews — pick a tile number you like (e.g., `tile240.png`).
3. Open `main.gd` lines 49-53.
4. Change the tower row's `"tile": 250` to your new number.
5. Save, run.

### Beat 4 — Drag a Kenney scenery prop into the scene

> Add a tree or rock anywhere on the field, no code.

1. In the Godot editor, click the `Scenery` node in the scene tree.
2. In the FileSystem panel, navigate to `assets/kenney_td/` and find a sprite you like (e.g., `tile132.png` — tree).
3. **Drag** the sprite file into the 2D viewport — Godot creates a Sprite2D child of `Scenery`.
4. Move it around by dragging.
5. (Optional) In the Inspector, set `Scale` to `(0.625, 0.625)` to match the other scenery.
6. Save (Ctrl+S) — your new prop is part of the scene.

### Beat 5 — Flip the difficulty knob

1. Open `main.gd`, line 43 — `const DIFFICULTY := 2`.
2. Try `0` (easy) or `1` (normal). Save, run.

### Beat 6 (stretch) — Edit the wave list

1. Open `main.gd`, lines 62-71 — find the `WAVES` array.
2. Each entry: `[count, type]`. Add more waves, bigger waves, different mixes.
3. Save, run.

---

## 7. Stretch goals — Final Challenge (`endless_mode.gd`)

> **What "stretch goals" means in this camp**: every day ends with a Final Challenge file. The FC tasks are **reworded versions of the morning chunks** — same concepts, new context. Repetition is the point: every FC hole drives a morning concept deeper, no new ideas required.

**File**: `endless_mode.gd`.
**Payoff**: rip out the 8-wave list, replace it with **infinite timer-based spawning that escalates over time**. No win panel — game ends only when the base falls.
**Hint level**: half-guided. The file's comment blocks give plain-English rules; the kid writes the code. Slides may show the mirror map but should NOT show verbatim code (per the show-vs-copy rule).

### Mirror map

| FC hole | Mirrors morning chunk | Concept practiced |
|---|---|---|
| FC-1 | #1 | Declare state variables |
| FC-2 | #2a | Append (on a timer instead of from a wave list) |
| FC-3 | #5a | Return ONE thing (a string this time, not a node) |
| FC-4 | #7 | `enemies.size() == 0` check (with a different consequence) |

### Hole FC-1 — State variables for endless mode

- **Mirrors**: TODO #1.
- **Goal**: Declare three top-level variables: a timer (float, starts at 0.0), a difficulty counter (int, starts at 1), and a spawn interval (float, starts at 2.0 seconds). Without these, the rest of `endless_mode.gd` can't compile.
- **Expected solution**:
  ```gdscript
  var spawn_timer: float = 0.0
  var difficulty: int = 1
  var spawn_interval: float = 2.0
  ```
### Hole FC-2 — Spawn on a timer

- **Mirrors**: TODO #2a.
- **Goal**: Each frame, tick the `spawn_timer` up by `delta`. When it crosses `spawn_interval`, spawn an enemy at a random edge (call `pick_enemy_type()` from FC-3 to pick the type, then `main.spawn_enemy(random_edge(), the_type)`), and reset the timer to 0. Without this, no enemies ever spawn in endless mode.
- **Expected solution**:
  ```gdscript
  spawn_timer += delta
  if spawn_timer >= spawn_interval:
      var t: String = pick_enemy_type()
      main.spawn_enemy(random_edge(), t)
      spawn_timer = 0.0
  ```
### Hole FC-3 — Return ONE thing based on difficulty

- **Mirrors**: TODO #5a.
- **Goal**: Decide which enemy type to spawn based on `difficulty`. Return `"grunt"` at low difficulty, `"runner"` at high difficulty. Kid picks the threshold.
- **Expected solution** (one possible shape):
  ```gdscript
  if difficulty > 3:
      return "runner"
  else:
      return "grunt"
  ```
### Hole FC-4 — Size check + escalation

- **Mirrors**: TODO #7.
- **Goal**: When the screen clears (no enemies left), bump difficulty by 1 and shrink the spawn interval to 90% of its current value (spawns come faster). The "screen clear" detection itself is in the pre-given `endless_tick`; the kid writes the *consequence*.
- **Expected solution**:
  ```gdscript
  difficulty += 1
  spawn_interval *= 0.9
  ```
### Enable endless mode — flip the toggle

> After all 4 FC holes are filled.

1. Open `main.gd`.
2. Find line 76 — `const ENDLESS_MODE := false`.
3. Change `false` to `true`.
4. Save, run.
5. Endless mode runs: spawns escalate over time, no wave limit, no "YOU WIN" panel. Game ends only when the base falls.

---

## 8. Asset / atlas reference — and flux flags

> **FLUX BANNER** (2026-05-26): D3 is in non-student rework. The chunks in §5 and FC holes in §7 are **stable** — kid-facing scope, won't change. The items in this §8 may still shift in the next build chat. Refresh this section after each rework.

### Stable (does not change with rework)

- **Pack**: Kenney **Tower Defense (Top-Down)** 2D — kenney.nl, CC0.
- **Filename convention**: `assets/kenney_td/towerDefense_tileNNN.png`, 001-299.
- **Viewport**: 1280 × 720.
- **Grid**: 32 columns × 17 rows, 40 px per tile. Bottom 40 px row is the button bar.
- **Base cells**: `(15, 8)` and `(16, 8)` — combined into one Area2D rectangle at world `(640, 340)`, 80×40 px.
- **Input map**: `select_cannon`/`select_sniper`/`select_splash` (keys 1/2/3), `start_wave` (SPACE), `restart` (R).

### Flux — sprite picks (subject to swap during visual playtest)

Current scaffold tile picks:

| Role | Tile file | Notes |
|---|---|---|
| Base | `tile249.png` | Castle-ish. Scaled wide 1.25×0.625 to cover both cells. |
| Cannon | `tile250.png` | Modulate `Color(1.0, 0.6, 0.4)` (orange). |
| Sniper | `tile251.png` | Modulate `Color(0.6, 0.8, 1.0)` (blue). |
| Splash | `tile252.png` | Modulate `Color(1.0, 0.9, 0.4)` (yellow). |
| Grunt | `tile271.png` | Modulate `Color(0.85, 0.85, 0.85)` (light grey). |
| Runner | `tile270.png` | Modulate `Color(0.5, 1.0, 0.5)` (green). |
| Scenery | trees 132, rocks 135, fences 140, sign 145, bush 150 | Pre-placed in `Main.tscn` corners/edges. |

If any of these look wrong in playtest, swap the tile number in `main.gd`'s `TOWER_STATS` / `ENEMY_STATS` dictionaries or in `Main.tscn`'s ExtResource paths.

### Flux — scaffold structure (currently in rework)

- **Obstacles**: `Main.tscn` ships 8 `StaticBody2D` obstacles (collision layer 4) inside `Scenery`. May be removed or repurposed in the next rework.
- **Tower-vs-enemy collision**: current scaffold has no tower physical body — enemies walk *through* towers. Tower-as-StaticBody2D may come back in rework.
- **Sim tuning**: balance values in `main.gd:48-71` are pinned from `_balance/Day3/` iteration 13. Rework may re-run the sim with different fitness targets and produce new constants.

### `@export` / Inspector-visible variables

None currently. All tuning lives in `const TOWER_STATS`, `const ENEMY_STATS`, `const WAVES`, `const DIFFICULTY`. Personalization beats (§6) are all code edits, not Inspector edits.

---

## 9. Verification checklist (re-run if code changes)

- [x] All 10 `#@todo` blocks in `main.gd` mapped to chunk rows in §3 (#1 ×1, #2 ×3, #3 ×1, #4 ×1, #5a ×1, #5b ×1, #6 ×1, #7 ×1).
- [x] All 4 `#@todo` blocks in `endless_mode.gd` documented in §7.
- [x] As-typed code blocks byte-identical to source between `#@todo` and `#@end` markers.
- [x] Scene tree in §2 matches `Main.tscn` node names + types.
- [x] Constants table (§2) matches `main.gd:22-79`.
- [x] Asset references (§8) match `Main.tscn` ExtResource paths.
- [x] Narrative-arc card (§1) matches BIBLE §15 universal narrative arc memory (TD = 90s-2000s).
- [x] Chunk order in §3 + §5 matches BIBLE §4 D3 order (1, 2, 3, 4, 5a, 5b, 6, 7).
- [x] No "stretch" tag on any morning chunk; "Stretch goals" applies only to §7 FC.
- [x] Each walkthrough (Pre-coding demo + per-chunk "After this chunk works" + Personalization + FC enable) appears exactly once at its lesson position.
- [ ] Sprite picks confirmed correct on visual playtest — **PENDING**.
- [ ] Obstacles + tower physics: rework decision pending — refresh §8 once locked.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 3." Output should require no follow-up clarification on chunk content. Visual playtest screenshots are a separate user-driven pass.
