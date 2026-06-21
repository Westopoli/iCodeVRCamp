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

## 3. Chunk table — verified against `main.gd` (refreshed 2026-05-29 under R1-R6 + R3.1)

In lesson order (BIBLE §4 order: 1 → 2 → 3 → 4 → 5a → 5b → 6 → 7). Chunk #2 has three `#@todo` sites (2a append + 2b reward-branch erase + 2b no-reward-branch erase) — presented together as a single lesson concept. Chunk #6 is now an R5 partial-section hole — pre-given `match` dispatcher with two kid sub-holes (6a single-target + 6b list-target).

| # | Concept | File location | Kid LoC | Hole size |
|---|---|---|---|---|
| #1 | Variable declaration: lists + counters | `main.gd:117-122` | 4 | small |
| #2a | `.append()` (in `spawn_enemy`) | `main.gd:310-312` | 1 | tiny |
| #2b (reward) | `.erase()` + coin reward (in `kill_enemy`) | `main.gd:337-340` | 2 | tiny |
| #2b (no-reward) | `.erase()` only (enemy reached base) | `main.gd:343-345` | 1 | tiny |
| #3 | Iterate two lists in `_process` | `main.gd:229-234` | 4 | small |
| #4 | `func` taking a list (`move_all`) | `main.gd:376-379` | 2 | small |
| #5a | `func` returning ONE from a list (R5 partial — kid writes loop body only; init + return pre-given) | `main.gd:409-415` | 5 | medium |
| #5b | `func` returning a LIST from a list (`get_enemies_in_radius`) | `main.gd:444-450` | 5 | medium |
| #6a | Single-target branch (Cannon + Sniper) — R5 partial split inside pre-given `match` | `main.gd:498-503` | 4 | small |
| #6b | List-target branch (Splash) — R5 partial split inside pre-given `match` | `main.gd:506-511` | 4 | small |
| #7 | List size check + wave trigger | `main.gd:254-262` | 7 | medium |

**Total**: 11 `#@todo` sub-holes across **8 chunks** (BIBLE §4 D3 table). Morning kid LoC ≈ **39**.

**Notes (R1-R6 + R3.1 compliance):**
- No mid-day stretch tags (R1).
- Every kid line is single-purpose; `match` dispatcher pre-given (R2 D3 ceiling: nested calls allowed, but `match` is a D4 concept so it's pre-given here per R5).
- TODO comments state goal in outcome / input → output terms; no pseudo-code (R6).
- #5a + #6 are R5 partial-section holes — kid writes only the at-ceiling section, init/return/dispatcher shells are pre-given with `# Pre-given:` annotations.
- FC mirrors every morning chunk (R3.1) — see §7.

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
- **In-file location**: `main.gd:310-312`, near the bottom of `spawn_enemy(...)`, under `# TODO #2a: ADD THIS ENEMY TO THE LIST`.
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
- **In-file location**: `main.gd:337-340`, inside `kill_enemy(e, give_reward=true)`'s reward branch, under `# TODO #2b: REMOVE FROM LIST + PAY OUT`.
- **As-typed code**:
  ```gdscript
  enemies.erase(e)
  coins += reward
  ```
#### 2b (no-reward branch) — `.erase()` only

- **Goal**: When an enemy reaches the base, it's gone from the list — but the player gets no coins (the enemy *succeeded*; no tower killed it). **One line.** Without this, base-hit enemies stay in the list and the game starts misbehaving as waves stack up.
- **In-file location**: `main.gd:343-345`, in the `else` branch of `kill_enemy`.
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
- **In-file location**: `main.gd:229-234`, inside `_process(delta)`, under `# TODO #3: MOVE THE WORLD`.
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
- **In-file location**: `main.gd:376-379`, body of `func move_all(enemy_list: Array, delta: float) -> void:`.
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
- **In-file location**: `main.gd:409-415`, inside the body of `func get_nearest_enemy_in_range(pos: Vector2, tower_range: float) -> Node:`.
- **Hole type**: **R5 partial-section hole.** Init (`nearest = null`, `best_dist = tower_range + 1.0`) and the final `return nearest` are pre-given inside the function body (marked `# Pre-given:`). The kid's `#@todo` block holds only the loop-and-update section.
- **Full function (pre-given + kid hole), as it lives in the Complete ZIP**:
  ```gdscript
  func get_nearest_enemy_in_range(pos: Vector2, tower_range: float) -> Node:
      # Pre-given:
      var nearest: Node = null
      var best_dist: float = tower_range + 1.0

      # TODO #5a: kid writes this section.
      for e in enemies:
          var d: float = pos.distance_to(e.position)
          if d <= tower_range and d < best_dist:
              nearest = e
              best_dist = d

      # Pre-given:
      return nearest
  ```
- **Kid types (between `#@todo`/`#@end` only)**:
  ```gdscript
  for e in enemies:
      var d: float = pos.distance_to(e.position)
      if d <= tower_range and d < best_dist:
          nearest = e
          best_dist = d
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
- **In-file location**: `main.gd:444-450`, body of `func get_enemies_in_radius(pos: Vector2, radius: float) -> Array:`.
- **As-typed code**:
  ```gdscript
  var result: Array = []
  for e in enemies:
      if pos.distance_to(e.position) <= radius:
          result.append(e)
  return result
  ```
---

### Chunk #6 — Nested function calls (kid fills two `match` branches)

- **Concept**: We can pass the *result* of one function straight into another function. `fire_at(t, get_nearest_enemy_in_range(...))` is two function calls in one line — and even when the scaffold unpacks them onto two lines (`var target = ...; fire_at(t, target, ...)`), the same nesting idea is at work.
- **Goal**: Two branches, one chunk. Cannon and Sniper share a branch (single-target via #5a). Splash gets its own branch (list-target via #5b). In each branch, pick the target, fire if there's something to hit, reset the tower's cooldown. **This is the chunk that actually makes the game playable** — until #6a + #6b are filled, towers stand still and never shoot.
- **Board example**:
  ```gdscript
  shoot(get_target(enemies))
  ```
- **Hole type**: **R5 partial-section hole.** The `match t_type:` dispatcher itself (and its branch labels `"cannon", "sniper":` / `"splash":`) are pre-given — `match` is a D4 concept, so kids don't write it here. The kid's two `#@todo` blocks sit inside each branch and hold the per-branch body only.
- **In-file location**:
  - **#6a** (single-target body, Cannon + Sniper): `main.gd:498-503`.
  - **#6b** (list-target body, Splash): `main.gd:506-511`.
- **Full function fragment (pre-given match + kid bodies), as it lives in the Complete ZIP**:
  ```gdscript
  # Pre-given: dispatch by tower type — kid fills each branch.
  match t_type:
      "cannon", "sniper":
          # TODO #6a — single-target branch (Cannon + Sniper)
          var target: Node = get_nearest_enemy_in_range(t.position, t_range)
          if target != null:
              fire_at(t, target, t_damage)
              t.set_meta("cooldown", t_rate)
      "splash":
          # TODO #6b — list-target branch (Splash)
          var targets: Array = get_enemies_in_radius(t.position, t_range)
          if targets.size() > 0:
              fire_at(t, targets, t_damage)
              t.set_meta("cooldown", t_rate)
  ```
- **Kid types in #6a (between `#@todo`/`#@end` only)**:
  ```gdscript
  var target: Node = get_nearest_enemy_in_range(t.position, t_range)
  if target != null:
      fire_at(t, target, t_damage)
      t.set_meta("cooldown", t_rate)
  ```
- **Kid types in #6b (between `#@todo`/`#@end` only)**:
  ```gdscript
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
- **In-file location**: `main.gd:254-262`, in `_process`, under `# TODO #7: WAVE TRIGGER + WIN CHECK`.
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

## 7. Final Challenge — `endless_mode.gd` (R3 + R3.1 compliant, redesigned 2026-05-29)

> **What "Final Challenge" means**: every day ends with one FC file. The FC tasks are **reskins of the morning chunks** — same constructs, new context. The pointer slide (below) tells the kid exactly which morning chunk each FC hole mirrors. No new concepts. The payoff is the part that's new; the *code* is reused-shape.

**File**: `endless_mode.gd`.
**Payoff**: rip out the 8-wave list, replace with **infinite spawning that ramps forever** — enemies speed up every screen clear, towers ramp damage to keep up, base regenerates HP (no cap), no win panel. Game ends only when the base falls.
**Hook into main.gd**: pre-given. `const ENDLESS_MODE := false` lives at `main.gd:76`; flipping it to `true` triggers the pre-given wiring in `_ready()` (instantiates `endless_mode.gd` as a child of Main) and the pre-given branch in `_process()` (routes the tick to `fc_node.endless_tick(delta)` instead of the wave-based spawn ticker). All `load / new / add_child` boot-up + routing is pre-given as gated `if ENDLESS_MODE:` branches in main.gd.

### Pointer slide (REQUIRED in the deck per BIBLE §4 R3)

> **You already know how to do this.** Each TODO in `endless_mode.gd` is a near-mirror of a chunk you wrote this morning. If you get stuck, scroll up to that morning chunk in `main.gd` and copy the *shape* (not the words).
>
> - **FC-1**  ← Chunk **#1**  (declare state vars)
> - **FC-2a** ← Chunk **#2a** (`.append()` to a list)
> - **FC-2b** ← Chunk **#2b** (`.erase()` from a list + reward)
> - **FC-3**  ← Chunk **#3**  (iterate two lists each frame)
> - **FC-4**  ← Chunk **#4**  (function takes a list as a parameter)
> - **FC-5a** ← Chunk **#5a** (function returns ONE from a list)
> - **FC-5b** ← Chunk **#5b** (function returns a LIST from a list)
> - **FC-6**  ← Chunk **#6**  (`match` + per-branch nested calls)
> - **FC-7**  ← Chunk **#7**  (`list.size()` check + state transition)

### Mirror map (full)

| FC hole | Mirrors | What the kid writes | Kid LoC | New concept? |
|---|---|---|---|---|
| **FC-1** state vars | #1 | 5 var declarations (`spawn_timer`, `difficulty`, `spawn_interval`, `spawn_queue: Array = []`, `clear_streak`) | 5 | None |
| **FC-2a** `queue_spawn(t)` | #2a | `spawn_queue.append(t)` | 1 | None |
| **FC-2b** `take_next_spawn()` | #2b | pop_front + `main.spawn_enemy(...)` + `main.coins += STREAK_BONUS` | 3 | None |
| **FC-3** per-frame buff sweep (inline in `endless_tick`) | #3 | two for-loops: `for e in main.enemies: endless_buff(e, delta)` + `for t in main.towers: buff_tower(t, delta)` | 4 | None — same shape as morning #3 |
| **FC-4** `buff_all(enemy_list, delta)` | #4 | for-each over `enemy_list`, calling `endless_buff` | 2 | None — list-as-parameter same as morning #4 |
| **FC-5a** `get_fastest_enemy() -> Node` (R5 partial) | #5a | loop body only: walk `main.enemies`, track highest `.speed` | 3 | None |
| **FC-5b** `get_wounded_enemies() -> Array` | #5b | init `result = []`, loop + conditional append, return | 4 | None |
| **FC-6** `escalate()` match branches | #6 | four branches (easy/medium/hard/insane), each: `var t = pick_type_for_band(band)` + 1-4 `queue_spawn(t)` calls | 8 (2+3+4+5 across branches, less if kid uses nested) | None — same shape as morning #6 |
| **FC-7** `check_for_screen_clear()` | #7 | size check on both lists, bump streak + difficulty + interval + base_hp, call `escalate()` | 6 | None |

**Total FC kid LoC ≈ 36** (morning ≈ 39). Per BIBLE §4 R3.1: ±20% envelope — actual −8%. ✓

### Pre-given (kid never modifies — visible scaffold at top of file)

- Constants: `SPAWN_INTERVAL_START`, `SPAWN_INTERVAL_SHRINK`, `STREAK_BONUS`, `SPEED_RAMP_PER_STREAK`, `TOWER_DAMAGE_RAMP_PER_STREAK`, `WOUNDED_HP_THRESHOLD`, `BASE_HP_REGEN_PER_CLEAR`.
- `endless_tick(delta)` — per-frame entry called from main.gd's `_process` when ENDLESS_MODE is true.
- `spawn_timer_tick(delta)` — drains the queue at `spawn_interval` cadence; calls `escalate()` to refill if empty.
- `endless_buff(e, delta)` — per-frame enemy speed ramp (no cap).
- `buff_tower(t, delta)` — per-frame tower damage-bonus ramp (no cap).
- `difficulty_band() -> String` — returns `"easy"/"medium"/"hard"/"insane"` from current `difficulty`.
- `pick_type_for_band(band) -> String` — returns `"grunt"` or `"runner"` for a band.
- `random_edge() -> Vector2i` — wraps `main.random_edge_cell()`.
- Field `main: Node` — set via `@onready var main: Node = get_parent()`.

### Per-hole detail

#### FC-1 — State variables for endless mode
- **Mirrors**: morning #1 (variable declarations).
- **Goal**: declare 5 top-level variables for endless state.
- **Pre-given context**: tuning constants live just above the hole.
- **As-typed code**:
  ```gdscript
  var spawn_timer: float = 0.0
  var difficulty: int = 1
  var spawn_interval: float = SPAWN_INTERVAL_START
  var spawn_queue: Array = []
  var clear_streak: int = 0
  ```

#### FC-2a — `queue_spawn(t)`
- **Mirrors**: morning #2a (`.append`).
- **Goal**: append `t` (a type string) to `spawn_queue`.
- **As-typed code**:
  ```gdscript
  spawn_queue.append(t)
  ```

#### FC-2b — `take_next_spawn()`
- **Mirrors**: morning #2b reward branch (`.erase` + coin reward).
- **Goal**: pop the front of `spawn_queue`, spawn that type at a random edge, and pay `STREAK_BONUS` coins.
- **Pre-given helpers used**: `random_edge()`, `main.spawn_enemy(cell, type)`.
- **As-typed code**:
  ```gdscript
  var t: String = spawn_queue.pop_front()
  main.spawn_enemy(random_edge(), t)
  main.coins += STREAK_BONUS
  ```

#### FC-3 — Per-frame buff sweep (inline in `endless_tick`)
- **Mirrors**: morning #3 (two for-loops in `_process`).
- **Goal**: each frame, walk every enemy in `main.enemies` and call `endless_buff(e, delta)`; walk every tower in `main.towers` and call `buff_tower(t, delta)`.
- **Hole location**: inside `endless_tick(delta)` body, between two pre-given lines (`spawn_timer_tick(delta)` above, `check_for_screen_clear()` below).
- **As-typed code**:
  ```gdscript
  for e in main.enemies:
      endless_buff(e, delta)
  for t in main.towers:
      buff_tower(t, delta)
  ```

#### FC-4 — `buff_all(enemy_list, delta)`
- **Mirrors**: morning #4 (function takes a list as parameter; never called by default).
- **Goal**: loop the parameter list, calling `endless_buff(e, delta)` on each. Optional refactor target: kid can swap their FC-3 enemy half to `buff_all(main.enemies, delta)`.
- **As-typed code**:
  ```gdscript
  for e in enemy_list:
      endless_buff(e, delta)
  ```

#### FC-5a — `get_fastest_enemy() -> Node` (R5 partial hole)
- **Mirrors**: morning #5a (function returns ONE from list).
- **Goal**: return the enemy with the highest `.speed`. Pre-given init (`fastest = null`, `best_speed = 0.0`) and pre-given `return fastest` sandwich the kid hole. Kid writes only the loop-and-update section.
- **Kid types (between `#@todo`/`#@end`)**:
  ```gdscript
  for e in main.enemies:
      if e.speed > best_speed:
          fastest = e
          best_speed = e.speed
  ```

#### FC-5b — `get_wounded_enemies() -> Array`
- **Mirrors**: morning #5b (function returns a LIST from list).
- **Goal**: return a brand-new list of every enemy whose `.hp` is `<= WOUNDED_HP_THRESHOLD`.
- **As-typed code**:
  ```gdscript
  var result: Array = []
  for e in main.enemies:
      if e.hp <= WOUNDED_HP_THRESHOLD:
          result.append(e)
  return result
  ```

#### FC-6 — `escalate()` four-band match (kid fills each branch)
- **Mirrors**: morning #6 (`match` + nested calls).
- **Goal**: pre-given `match band:` dispatcher routes to four kid branches. In each branch: pick a type via `pick_type_for_band(band)` and call `queue_spawn(t)` a difficulty-appropriate number of times (1 for easy, 2 medium, 3 hard, 4 insane). Nested form (`queue_spawn(pick_type_for_band(band))`) is also accepted per R6.
- **Hole type**: four `#@todo` sub-blocks inside pre-given match arms.
- **As-typed code (one branch — same shape, different repetition count per band)**:
  ```gdscript
  "medium":
      var t: String = pick_type_for_band(band)
      queue_spawn(t)
      queue_spawn(t)
  ```

#### FC-7 — `check_for_screen_clear()`
- **Mirrors**: morning #7 (`.size()` check + state transition).
- **Goal**: when `main.enemies` is empty AND `spawn_queue` is empty, bump `clear_streak` + `difficulty` by 1, shrink `spawn_interval` by `SPAWN_INTERVAL_SHRINK`, regen `main.base_hp` by `BASE_HP_REGEN_PER_CLEAR` (no cap — base HP can climb past start value), and call pre-given `escalate()` to queue the next burst.
- **As-typed code**:
  ```gdscript
  if main.enemies.size() == 0 and spawn_queue.size() == 0:
      clear_streak += 1
      difficulty += 1
      spawn_interval *= SPAWN_INTERVAL_SHRINK
      main.base_hp += BASE_HP_REGEN_PER_CLEAR
      escalate()
  ```

### Enable endless mode — flip the toggle

> After all 9 FC holes are filled.

1. Open `main.gd`.
2. Find line 76 — `const ENDLESS_MODE := false`.
3. Change `false` to `true`.
4. Save, run.
5. Endless mode runs: spawns escalate forever, enemies and towers both ramp, base regens between clears, no "YOU WIN" panel. Game ends only when the base falls.

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

- [x] All 11 `#@todo` blocks in `main.gd` mapped to chunk rows in §3 (#1 ×1, #2 ×3, #3 ×1, #4 ×1, #5a ×1, #5b ×1, #6 ×2 (6a + 6b), #7 ×1).
- [x] All 12 `#@todo` sub-holes in `endless_mode.gd` documented in §7 (FC-1, FC-2a, FC-2b, FC-3, FC-4, FC-5a, FC-5b, FC-6 ×4 branches, FC-7 — 12 sub-holes mirroring all 8 morning chunks; FC-2 + FC-6 each map to one morning chunk despite shipping multiple sub-holes).
- [x] As-typed code blocks byte-identical to source between `#@todo` and `#@end` markers.
- [x] Scene tree in §2 matches `Main.tscn` node names + types.
- [x] Constants table (§2) matches `main.gd:22-79`.
- [x] Asset references (§8) match `Main.tscn` ExtResource paths.
- [x] Narrative-arc card (§1) matches BIBLE §15 universal narrative arc memory (TD = 90s-2000s).
- [x] Chunk order in §3 + §5 matches BIBLE §4 D3 order (1, 2, 3, 4, 5a, 5b, 6, 7).
- [x] No "(STRETCH)" tag on any morning chunk; Final Challenge lives in `endless_mode.gd` only (R1).
- [x] TODO comments state outcome (input → output / observable effect), no pseudo-code blocks (R6).
- [x] #5a + #6 ship as R5 partial-section holes (pre-given init/return shell for #5a; pre-given `match` dispatcher for #6).
- [x] FC mirrors all 8 morning chunks (R3.1) — see §7 pointer slide content + mirror map.
- [x] FC hook wired in `main.gd` `_ready` (`if ENDLESS_MODE: preload + new + add_child`) + `_process` (`fc_node.endless_tick(delta)` branch) + `update_hud` (endless-aware label).
- [x] Each walkthrough (Pre-coding demo + per-chunk "After this chunk works" + Personalization + FC enable) appears exactly once at its lesson position.
- [x] Sprite picks confirmed correct on visual playtest — **verified 2026-06-10**.
- [ ] Obstacles + tower physics: rework decision pending — refresh §8 once locked.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 3." Output should require no follow-up clarification on chunk content. Visual playtest screenshots are a separate user-driven pass.

---

## 10. Slide blueprint (Phase 2.5 — REVISED 2026-06-20)

> Per-slide build manifest for Day 3. Walk top to bottom; one slide per entry, in order.
> All D3_FEEDBACK.md items incorporated. All TODO slides use G13/G14 format (R7).

### 10.0 Schema

```
#### Slide D3-S### — <short label>
- Format: <G## name>
- Title: "<exact title text>"
- Body: <bullets, prose, or code block — verbatim>
- Image: <filename + description + overlay spec, or "none">
- Notes: <instructor cue, or "—">
```

- G13 TODO slides: `- Syntax: key1, key2` + `- Body RHS:` comment-only scaffold.
- G14 Pre-TODO: EXACT same comment lines as paired G13 RHS + **What:** / **Why:** / **How:** bullets. Bottom note: "This is one approach — yours works if it runs."

---

### 10.1 Opener pack (slides S001–S007)

#### Slide D3-S001 — Day title
- Format: G01 Day Title
- Title: "VR Creator - Day 3"
- Body:
  - "Base Defense · 1990 → 2009 · Tower Defense Era"
  - "Rampart → WC3 custom maps → Plants vs Zombies → Kingdom Rush"
- Image: `D3Defense1.png` — Plants vs Zombies screenshot (placeholder OK). No red overlay.
- Notes: Let kids name tower defense games they know before clicking forward.

#### Slide D3-S002 — Today we're building Base Defense
- Format: G12 Screenshot + Caption
- Title: "Today we're building Base Defense"
- Body: "Enemies pour in from the edges. You spend coins on towers. Survive 8 waves."
- Image: `D3TD1.png` — finished Base Defense game running, wave 1 in progress (placeholder OK).
- Notes: Quick one — let the screenshot sell it.

#### Slide D3-S003 — Why tower defense matters
- Format: G04 Headline / Divider
- Title: "A whole genre — invented by modders"
- Body:
  - "**Rampart** (1990) — hybrid first attempt. Castle walls + cannonballs."
  - "**Warcraft III custom maps** (2002–2007) — the entire genre invented by players tweaking someone else's game."
  - "**Plants vs Zombies** (2009) — mainstream breakout. 6 million copies in a year."
  - "**Bloons / Kingdom Rush** — mobile-era boom. Still going."
  - "Every tower defense game you've played traces back to a Warcraft III modder."
- Image: none
- Notes: "Kids are writing code that puts them in that lineage."

#### Slide D3-S004 — Yesterday → Today
- Format: G04 Headline / Divider
- Title: "Yesterday → Today"
- Body:
  - "**Day 2** — Loops + intro Functions. `for` loops, named blocks of code."
  - "**Day 3** — **Lists + Deeper Functions**. Same `for`-loop shape, new things to loop over."
  - "Today's two new ideas: a list is a collection of things. A deeper function scans a list and returns something useful."
- Image: none
- Notes: "Keep it brief. Kids already know loops."

#### Slide D3-S005 — 5-day arc timeline
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body: horizontal 5-step strip, today highlighted iCode red, Days 1–2 ticked:
  - Day 1 ✓ Pong — Vars + Conditions
  - Day 2 ✓ Pac-Man — Loops + Functions
  - **Day 3 ← Base Defense — Lists + Deeper Functions**
  - Day 4 Fighter — Objects + State
  - Day 5 Escape Room — Showcase
- Image: none
- Notes: "Three down after today. Two new ideas."

#### Slide D3-S006 — Today's two concepts
- Format: G04 Headline / Divider
- Title: "Today: **Lists** + **Deeper Functions**"
- Body:
  - "**Lists** — a collection of things your code can remember, walk through, add to, or remove from."
  - "**Deeper Functions** — functions that scan lists, return something useful, and chain into each other."
- Image: none
- Notes: "One breath per bullet. These two ideas power the whole game."

#### Slide D3-S007 — GDScript vs Python: list ops (D3 new only)
- Format: G03 GDScript vs Python
- Title: "GDScript list ops — two things change"
- Body LHS:
  ```
  list = []
  list.remove(x)
  len(list)
  ```
- Body RHS:
  ```gdscript
  var list = []
  list.erase(x)
  list.size()
  ```
- Image: none
- Notes: "`.append()` and `for x in list:` are **identical**. Only `.remove` → `.erase` and `len()` → `.size()` differ. That's it."

---

### 10.2 Pre-coding setup (slides S008–S017)

#### Slide D3-S008 — Section divider: Pre-coding setup
- Format: G04 Headline / Divider
- Title: "Pre-coding setup"
- Body:
- Image: none
- Notes: —

#### Slide D3-S009 — Walk A: Open the Day 3 project (Challenge only)
- Format: G04 Headline / Divider
- Title: "Walk A — Open the Day 3 project"
- Body: "Open the Base Defense project. You know how. Do it like yesterday."
- Image: none
- Notes: No hint slide — kids know the flow by Day 3. Wait ~30 seconds, then help individually.

#### Slide D3-S010 — Walk B: Open main.gd (Challenge only)
- Format: G04 Headline / Divider
- Title: "Walk B — Open `main.gd`"
- Body: "Open `main.gd` in the Script editor. Same as always."
- Image: none
- Notes: No hint slide. Let kids do it.

#### Slide D3-S011 — Walk DK: Find the difficulty knob
- Format: G12 Screenshot + Caption
- Title: "Walk DK — The difficulty knob"
- Body: "Near the top of `main.gd`, there's a `const DIFFICULTY := 2`. This one number changes how hard the whole game is."
- Image: `D3WDK1.png` — `main.gd` near the top showing `const DIFFICULTY := 2`, red overlay on that line.
- Notes: "Show this on the projector. Point to the line. Read it aloud."

#### Slide D3-S012 — Walk DK: What changing it would do
- Format: G04 Headline / Divider
- Title: "Walk DK — What this number controls"
- Body:
  - "`0` = Easy — enemies have less HP."
  - "`1` = Medium — standard HP."
  - "`2` = Hard — full HP (what you're coding on)."
  - "Change one number → the whole game runs at a different difficulty. You'll try this in a personalization session later."
- Image: none
- Notes: "Don't actually change the value now — just show that it exists. Leave it at 2 for coding."

#### Slide D3-S013 — Section divider: Lesson chunks
- Format: G04 Headline / Divider
- Title: "Lesson chunks"
- Body:
- Image: none
- Notes: —

#### Slide D3-S013a — There are thousands of right answers (callback)
- Format: G04 Headline / Divider
- Title: "Reminder: there are millions of right answers"
- Body:
  - "The examples on the LEFT of TODO slides are one way."
  - "Your way is valid if it runs."
- Image: none
- Notes: Brief callback. Don't dwell.

---

### 10.3 Chunk #1 — Game state lists + counters (slides S014–S024)

#### Slide D3-S014 — Concept 1/4: "List"
- Format: G04 Headline / Divider
- Title: "**List**"
- Body:
- Image: none
- Notes: Say the word. "What does *list* mean to you? Grocery list. Top-10 list. Attendance sheet."

#### Slide D3-S015 — Concept 2/4: Things in order
- Format: G04 Headline / Divider
- Title: "A list = things in order"
- Body:
  - "A grocery list holds items in order. You can add an item, remove one, or walk through all of them."
  - "In code: a list holds values. You can `.append()`, `.erase()`, and loop through them."
- Image: none
- Notes: —

#### Slide D3-S016 — Concept 3/4: Code shape
- Format: G10 Code Shape
- Title: "A list in GDScript"
- Body:
  ```gdscript
  var fruits: Array = []        # empty list
  fruits.append("apple")        # add to the end
  fruits.append("banana")
  print(fruits.size())          # prints: 2
  fruits.erase("apple")         # remove by value
  print(fruits.size())          # prints: 1
  ```
- Image: none
- Notes: "Empty brackets = empty list. `.append()` adds. `.erase()` removes by value. `.size()` counts."

#### Slide D3-S017 — Concept 4/4: Lists in games
- Format: G04 Headline / Divider
- Title: "Lists are everywhere in games"
- Body:
  - "All the active enemies on screen → a list."
  - "All the towers the player has placed → a list."
  - "Inventory items, quests, bullet projectiles — all lists."
- Image: none
- Notes: —

#### Slide D3-S018 — In our game: enemies + towers lists
- Format: G04 Headline / Divider
- Title: "In our game: `enemies` and `towers`"
- Body:
  - "`enemies` — every enemy currently walking toward your base."
  - "`towers` — every tower the player has placed."
  - "Both start empty `[]`. They grow as the game runs."
- Image: none
- Notes: —

#### Slide D3-S019 — Where TODO #1 lives
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — top of `main.gd`"
- Body: "At the `# TODO #1` marker near the top of `main.gd`, after the preloads."
- Image: `D3C1.png` — main.gd lines 103-119, showing `# TODO #1` banner + `#@todo` gap. No red overlay.
- Notes: —

#### Slide D3-S019a — Pre-TODO #1: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # var enemies: Array = [] (empty list)
  # var towers: Array = [] (empty list)
  # var coins: int = START_COINS
  # var base_hp: int = START_BASE_HP
  ```
  - "**What:** Four variable declarations — two empty lists, two integer counters."
  - "**Why:** Without these, the game has nowhere to store enemies, towers, or score."
  - "**How:** `Array = []` makes an empty list. `int = START_COINS` sets a typed integer to the starting constant."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S020 — TODO #1: game state lists + counters
- Format: G13 TODO
- Title: "**TODO #1** — Declare game state variables"
- Syntax: list_init, var, const
- Body RHS:
  ```gdscript
  # var enemies: Array = [] (empty list)
  # var towers: Array = [] (empty list)
  # var coins: int = START_COINS
  # var base_hp: int = START_BASE_HP
  ```
- Image: `D3C1.png` — main.gd lines 103-119, red overlay on `#@todo` gap.
- Notes: 4 lines. `START_COINS` and `START_BASE_HP` are pre-given constants at the top of the file.

---

### 10.4 Personalization #1 (slide S020a)

#### Slide D3-S020a — Personalization #1: tune starting coins
- Format: G04 Headline / Divider
- Title: "Personalization #1"
- Body:
  - "Want more starting coins? Find `const START_COINS` near the top of `main.gd`."
  - "Change the number. Run the game. How does it feel with 500 coins vs 50?"
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: open-ended. No screenshots.

---

### 10.5 Chunk #2 — `.append()` and `.erase()` (slides S021–S030)

#### Slide D3-S021 — Bridge: adding and removing from lists
- Format: G04 Headline / Divider
- Title: "Adding to lists and removing from them"
- Body:
  - "Last chunk: you declared the lists."
  - "This chunk: you wire the game so enemies **appear in** the list when they spawn, and **disappear from** it when they die."
- Image: none
- Notes: —

#### Slide D3-S022 — `.append()` code shape
- Format: G10 Code Shape
- Title: "`.append()` — add an item to the end"
- Body:
  ```gdscript
  var scores: Array = []
  scores.append(10)
  scores.append(20)
  # scores is now [10, 20]
  ```
- Image: none
- Notes: "The list grows by one each call. The new item lands at the end."

#### Slide D3-S023 — `.erase()` code shape
- Format: G10 Code Shape
- Title: "`.erase()` — remove an item by value"
- Body:
  ```gdscript
  var scores: Array = [10, 20, 30]
  scores.erase(20)
  # scores is now [10, 30]
  ```
- Image: none
- Notes: "Finds the item by value and removes it. If the item isn't there, nothing happens."

#### Slide D3-S024 — Where TODO #2a lives
- Format: G12 Screenshot + Caption
- Title: "Where #2a lives — inside `spawn_enemy()`"
- Body: "One line at the bottom of `spawn_enemy()`. After the enemy is built, add it to the list."
- Image: `D3C2a.png` — main.gd lines 291-302, showing `# TODO #2a` banner + `#@todo`. No red overlay.
- Notes: —

#### Slide D3-S024a — Pre-TODO #2a: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # add e to the enemies list: enemies.append(e)
  ```
  - "**What:** One line — append the new enemy to `enemies`."
  - "**Why:** Without this, spawned enemies never enter the list. The game loop can't see them."
  - "**How:** `enemies.append(e)` — `e` is the enemy node just built above your hole."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S025 — TODO #2a: append enemy to list
- Format: G13 TODO
- Title: "**TODO #2a** — Add enemy to list"
- Syntax: list_append
- Body RHS:
  ```gdscript
  # add e to the enemies list: enemies.append(e)
  ```
- Image: `D3C2a.png` — main.gd lines 291-302, red overlay on `#@todo` gap.
- Notes: 1 line. `e` is the enemy node instantiated just above this hole.

#### Slide D3-S026 — Where TODO #2b lives
- Format: G12 Screenshot + Caption
- Title: "Where #2b lives — inside `kill_enemy()`"
- Body: "Two holes inside `kill_enemy()`: one in the reward branch (erase + pay out), one in the no-reward branch (erase only)."
- Image: `D3C2b.png` — main.gd lines 313-342, showing both `# TODO #2b` banners. No red overlay.
- Notes: —

#### Slide D3-S026a — Pre-TODO #2b: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # reward branch (enemy killed by tower):
  # remove e from enemies: enemies.erase(e)
  # add reward to coins: coins += reward

  # no-reward branch (enemy reached the base):
  # remove e from enemies: enemies.erase(e)
  ```
  - "**What:** Two holes — both erase `e` from the list. The reward branch also pays out coins."
  - "**Why:** Without the erase, dead enemies stay in the list forever. The wave never ends."
  - "**How:** `enemies.erase(e)` removes by value. `coins += reward` adds the payout."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S027 — TODO #2b: erase enemy + pay out
- Format: G13 TODO
- Title: "**TODO #2b** — Remove enemy from list"
- Syntax: list_erase, plus_eq
- Body RHS:
  ```gdscript
  # reward branch (enemy killed by tower):
  # remove e from enemies: enemies.erase(e)
  # add reward to coins: coins += reward

  # no-reward branch (enemy reached the base):
  # remove e from enemies: enemies.erase(e)
  ```
- Image: `D3C2b.png` — main.gd lines 313-342. Two-tone overlay: gray = pre-given `if give_reward:` / `else:` guards; red = your two holes.
- Notes: 2 holes: reward branch = 2 lines, no-reward branch = 1 line. `reward` is already unpacked in the reward branch.

---

### 10.6 Chunk #3 — Loop enemies + towers each frame (slides S028–S032)

#### Slide D3-S028 — Bridge: the game loop
- Format: G04 Headline / Divider
- Title: "The game loop — move everything, every frame"
- Body:
  - "Every frame, the game needs to: step each enemy forward, tick each tower."
  - "You have a list of enemies. You have a list of towers."
  - "Two `for` loops — one for each list."
- Image: none
- Notes: "Same `for item in list:` shape as Day 2."

#### Slide D3-S029 — Where TODO #3 lives
- Format: G12 Screenshot + Caption
- Title: "Where #3 lives — inside `_process(delta)`"
- Body: "Inside `_process(delta)`, after the spawn ticker. This code runs every frame."
- Image: `D3C3.png` — main.gd lines 213-228, showing `# TODO #3` banner + `#@todo`. No red overlay.
- Notes: —

#### Slide D3-S029a — Pre-TODO #3: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # for each e in enemies: call step_enemy(e, delta)
  # for each t in towers: call tower_tick(t, delta)
  ```
  - "**What:** Two for-loops — move every enemy, tick every tower."
  - "**Why:** Without this, nothing on screen moves. The game is frozen."
  - "**How:** `step_enemy(e, delta)` and `tower_tick(t, delta)` are pre-given helpers. You write the loops."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S030 — TODO #3: loop enemies + towers each frame
- Format: G13 TODO
- Title: "**TODO #3** — Move the world each frame"
- Syntax: for_in
- Body RHS:
  ```gdscript
  # for each e in enemies: call step_enemy(e, delta)
  # for each t in towers: call tower_tick(t, delta)
  ```
- Image: `D3C3.png` — main.gd lines 213-228, red overlay on `#@todo` gap.
- Notes: 2 lines. `delta` is the frame time — already a parameter of `_process(delta)`.

#### Slide D3-S031 — After-works: Enemies walk!
- Format: G12 Screenshot + Caption
- Title: "Enemies walk toward your base!"
- Body: "Run the game. Press Space. Wave 1 spawns — enemies walk in."
- Image: none
- Notes: First visible payoff of the day. "Your for loop is running 60 times per second."

---

### 10.7 Chunk #4 — `move_all()` function (slides S032–S037)

#### Slide D3-S032 — Bridge: move_all() wraps the loop
- Format: G04 Headline / Divider
- Title: "Packaging a loop in a function"
- Body:
  - "You just wrote `for e in enemies: step_enemy(e, delta)` directly."
  - "The Final Challenge code needs the same loop — but passing in a *different* list."
  - "`move_all(enemy_list, delta)` is a function that takes **any** list and loops it."
- Image: none
- Notes: "Same concept as Day 2 `func` with a parameter. New use."

#### Slide D3-S033 — Where TODO #4 lives
- Format: G12 Screenshot + Caption
- Title: "Where #4 lives — inside `move_all()`"
- Body: "Inside `func move_all(enemy_list, delta)`. The function signature is pre-given; you write the body."
- Image: `D3C4.png` — main.gd lines 346-359, showing `func move_all` signature + `#@todo`. No red overlay.
- Notes: —

#### Slide D3-S033a — Pre-TODO #4: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # for each e in enemy_list: call step_enemy(e, delta)
  ```
  - "**What:** One line — loop the parameter list, step each enemy."
  - "**Why:** The FC (endless mode) calls `move_all()` with its own list. Same loop, different input."
  - "**How:** `enemy_list` is the parameter (not `enemies`). `step_enemy(e, delta)` is pre-given."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S034 — TODO #4: move_all() body
- Format: G13 TODO
- Title: "**TODO #4** — Write `move_all()` body"
- Syntax: for_in, func_param
- Body RHS:
  ```gdscript
  # for each e in enemy_list: call step_enemy(e, delta)
  ```
- Image: `D3C4.png` — main.gd lines 346-359, red overlay on `#@todo` gap.
- Notes: 1 line. Use `enemy_list` (the parameter), not `enemies`.

---

### 10.8 Personalization #2 (slide S034a)

#### Slide D3-S034a — Personalization #2: tune the difficulty knob
- Format: G04 Headline / Divider
- Title: "Personalization #2 — Flip the difficulty knob"
- Body:
  - "Find `const DIFFICULTY := 2` near the top of `main.gd`."
  - "Change to `0` (easy) or `1` (medium). Run the game. Feel the difference."
  - "Change it back to `2` when you're done experimenting."
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: "This is the appropriate moment for the DIFFICULTY demo — not at setup."

---

### 10.9 Chunk #5a — `get_nearest_enemy_in_range()` (slides S035–S041)

#### Slide D3-S035 — Bridge: functions that return something useful
- Format: G04 Headline / Divider
- Title: "Functions that SEARCH a list and return an answer"
- Body:
  - "So far: functions that do things (`step_enemy`) or loop lists (`move_all`)."
  - "New: a function that **scans** the enemies list and **hands back one result**."
  - "`get_nearest_enemy_in_range()` — scans all enemies, returns the closest one in range (or `null`)."
- Image: none
- Notes: —

#### Slide D3-S036 — Pre-design prompt: #5a outcome
- Format: G04 Headline / Divider
- Title: "Before you write: what does this need to DO?"
- Body:
  - "Tower has a position and a range. There are N enemies on the map."
  - "**Goal:** find which enemy is closest to the tower AND within its range."
  - "**Available:** `enemies` list, `pos` (tower position), `tower_range`, `pos.distance_to(e.position)`."
- Image: none
- Notes: "Give kids 30 seconds. How would they approach this?"

#### Slide D3-S037 — Pre-design prompt: #5a design question
- Format: G04 Headline / Divider
- Title: "How would YOU design this?"
- Body:
  - "How do you find the closest thing in a list?"
  - "What do you need to track as you walk through the list?"
  - "When you arrive at the TODO, try your own approach first."
- Image: none
- Notes: "Don't give the answer yet. Let them articulate it."

#### Slide D3-S038 — Where TODO #5a lives
- Format: G12 Screenshot + Caption
- Title: "Where #5a lives — inside `get_nearest_enemy_in_range()`"
- Body: "Inside the function body. `nearest = null` and `best_dist = tower_range + 1` are pre-given above your hole."
- Image: `D3C5a.png` — main.gd lines 362-403, showing function signature + pre-given vars + `#@todo`. No red overlay.
- Notes: —

#### Slide D3-S038a — Pre-TODO #5a: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # for each e in enemies:
  #     compute d = pos.distance_to(e.position)
  #     if d <= tower_range and d < best_dist:
  #         set nearest = e
  #         set best_dist = d
  ```
  - "**What:** Walk the enemies list; update `nearest` and `best_dist` when you find a closer in-range enemy."
  - "**Why:** Towers need to know WHO to shoot. This function finds the answer."
  - "**How:** `best_dist` starts just outside range — the first in-range enemy automatically beats it."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S039 — TODO #5a: find nearest enemy in range
- Format: G13 TODO
- Title: "**TODO #5a** — Find nearest enemy in range"
- Syntax: for_in, if, or, dot
- Body RHS:
  ```gdscript
  # for each e in enemies:
  #     compute d = pos.distance_to(e.position)
  #     if d <= tower_range and d < best_dist:
  #         set nearest = e
  #         set best_dist = d
  ```
- Image: `D3C5a.png` — main.gd lines 362-403, red overlay on `#@todo` gap.
- Notes: 5 lines. `nearest` and `best_dist` pre-given above; `return nearest` pre-given below.

---

### 10.10 Chunk #5b — `get_enemies_in_radius()` (slides S040–S046)

#### Slide D3-S040 — Bridge: collect ALL enemies in radius
- Format: G04 Headline / Divider
- Title: "Splash towers need ALL enemies in range"
- Body:
  - "Cannon/Sniper: one target. `get_nearest_enemy_in_range()` returns ONE enemy."
  - "Splash: hits everyone nearby. Need ALL enemies within radius."
  - "`get_enemies_in_radius()` — scans enemies, returns a **list** of all within radius."
- Image: none
- Notes: —

#### Slide D3-S041 — Pre-design prompt: #5b outcome
- Format: G04 Headline / Divider
- Title: "Before you write: what does this need to DO?"
- Body:
  - "**Goal:** return a new list containing every enemy within `radius` of `pos`."
  - "**Available:** `enemies` list, `pos`, `radius`, `pos.distance_to(e.position)`."
  - "**Pattern you know:** `var result := []` → loop → conditional `.append()` → `return result`."
- Image: none
- Notes: "This is the 'collect matching items' pattern. They've seen it in concept slides."

#### Slide D3-S042 — Where TODO #5b lives
- Format: G12 Screenshot + Caption
- Title: "Where #5b lives — inside `get_enemies_in_radius()`"
- Body: "The whole function body — you write it all. The function signature is pre-given."
- Image: `D3C5b.png` — main.gd lines 409-444, showing `func get_enemies_in_radius` signature + `#@todo`. No red overlay.
- Notes: —

#### Slide D3-S042a — Pre-TODO #5b: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # var result: Array = []
  # for each e in enemies:
  #     if pos.distance_to(e.position) <= radius:
  #         result.append(e)
  # return result
  ```
  - "**What:** Build and return a new list of every enemy within `radius`."
  - "**Why:** The Splash tower needs this list to fire at everyone in range."
  - "**How:** Start with an empty list, loop enemies, append those in range, return."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S043 — TODO #5b: collect enemies in radius
- Format: G13 TODO
- Title: "**TODO #5b** — Collect enemies in radius"
- Syntax: list_init, for_in, list_append, return, if
- Body RHS:
  ```gdscript
  # var result: Array = []
  # for each e in enemies:
  #     if pos.distance_to(e.position) <= radius:
  #         result.append(e)
  # return result
  ```
- Image: `D3C5b.png` — main.gd lines 409-444, red overlay on `#@todo` gap.
- Notes: 5 lines. `pos`, `radius`, `enemies` are all parameters or globals. `pos.distance_to(e.position)` is the distance check.

#### Slide D3-S044 — After-works: towers scan for targets
- Format: G04 Headline / Divider
- Title: "Towers can now find targets"
- Body: "Run the game. Enemies walk — towers don't fire yet (that's chunk #6). But the targeting logic is live."
- Image: none
- Notes: "Reassure kids that no visible change is expected yet. The next chunk wires the fire."

---

### 10.11 Chunk #6 — Tower targeting + fire (slides S045–S055)

#### Slide D3-S045 — Bridge: tower_tick picks a target and fires
- Format: G04 Headline / Divider
- Title: "Tower tick: pick a target and fire"
- Body:
  - "`tower_tick(t, delta)` runs once per tower per frame."
  - "Cooldown handling is pre-given. Your job: pick the right finder, call it, fire if something was found."
  - "Cannon + Sniper → single target. Splash → list of targets."
- Image: none
- Notes: —

#### Slide D3-S046 — Where TODO #6 lives (match branches)
- Format: G12 Screenshot + Caption
- Title: "Where #6 lives — inside a `match` statement"
- Body: "Inside `tower_tick()`, there's a `match t_type:` block. You fill the two branches: `\"cannon\", \"sniper\":` and `\"splash\":`."
- Image: `D3C6.png` — main.gd lines 465-501, showing the match statement with both `#@todo` holes. No red overlay.
- Notes: —

#### Slide D3-S047 — match statement explainer
- Format: G10 Code Shape
- Title: "`match` — like a multi-way `if`"
- Body:
  ```gdscript
  match tower_type:
      "cannon":
          fire_cannon()
      "sniper":
          fire_sniper()
      "splash":
          fire_splash()
  ```
- Image: none
- Notes: "Same idea as `if/elif/elif` — just cleaner for checking one variable against many values."

#### Slide D3-S047a — Pre-TODO #6a: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write — `\"cannon\", \"sniper\":` branch"
- Body:
  ```gdscript
  # var target = get_nearest_enemy_in_range(t.position, t_range)
  # if target != null:
  #     call fire_at(t, target, t_damage)
  #     reset cooldown: t.set_meta("cooldown", t_rate)
  ```
  - "**What:** Find one target; if found, fire and reset the cooldown."
  - "**Why:** Without this, Cannon and Sniper towers never shoot."
  - "**How:** `t.position`, `t_range`, `t_damage`, `t_rate` are already unpacked above your hole."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S048 — TODO #6a: Cannon + Sniper branch
- Format: G13 TODO
- Title: "**TODO #6a** — Cannon + Sniper: find target and fire"
- Syntax: func_return, if, func_call
- Body RHS:
  ```gdscript
  # var target = get_nearest_enemy_in_range(t.position, t_range)
  # if target != null:
  #     call fire_at(t, target, t_damage)
  #     reset cooldown: t.set_meta("cooldown", t_rate)
  ```
- Image: `D3C6.png` — main.gd lines 487-493, red overlay on `# TODO #6a` hole only.
- Notes: 4 lines. Inside the `"cannon", "sniper":` branch of the `match` block.

#### Slide D3-S048a — Pre-TODO #6b: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write — `\"splash\":` branch"
- Body:
  ```gdscript
  # var targets = get_enemies_in_radius(t.position, t_range)
  # if targets.size() > 0:
  #     call fire_at(t, targets, t_damage)
  #     reset cooldown: t.set_meta("cooldown", t_rate)
  ```
  - "**What:** Collect a list of targets in the splash radius; if any found, fire at all of them."
  - "**Why:** Without this, Splash towers never shoot."
  - "**How:** `fire_at` handles lists and single nodes — pass `targets` directly."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S049 — TODO #6b: Splash branch
- Format: G13 TODO
- Title: "**TODO #6b** — Splash: collect targets and fire"
- Syntax: func_return, list_size, if, func_call
- Body RHS:
  ```gdscript
  # var targets = get_enemies_in_radius(t.position, t_range)
  # if targets.size() > 0:
  #     call fire_at(t, targets, t_damage)
  #     reset cooldown: t.set_meta("cooldown", t_rate)
  ```
- Image: `D3C6.png` — main.gd lines 495-501, red overlay on `# TODO #6b` hole only.
- Notes: 4 lines. Inside the `"splash":` branch.

#### Slide D3-S050 — After-works: Towers fire!
- Format: G12 Screenshot + Caption
- Title: "Towers fire! Enemies die!"
- Body: "Run the game. Place a tower. Watch it shoot."
- Image: none
- Notes: Big payoff — enemies dying, bullets firing. "Your `#5a`, `#5b`, and `#6` are all running together right now."

---

### 10.12 Personalization #3 (slide S050a)

#### Slide D3-S050a — Personalization #3: tune tower stats
- Format: G04 Headline / Divider
- Title: "Personalization #3 — Tune your tower stats"
- Body:
  - "Find `const TOWER_STATS` near the top of `main.gd`."
  - "Change the `damage`, `range`, or `fire_rate` for any tower. Run it. Does it feel better?"
  - "Try making a super-slow cannon that one-shots everything. Or a tiny-range rapid-fire sniper."
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: open-ended. No screenshots needed.

---

### 10.13 Chunk #7 — Wave advance + win check (slides S051–S057)

#### Slide D3-S051 — Bridge: how does the game know a wave ended?
- Format: G04 Headline / Divider
- Title: "How does the game know a wave ended?"
- Body:
  - "A wave is over when: **no enemies are alive** AND **no enemies are queued to spawn**."
  - "Check: `enemies.size() == 0` and `enemies_to_spawn.size() == 0`."
  - "Then: advance `wave_index`. Check if more waves remain. Win or start the next."
- Image: none
- Notes: —

#### Slide D3-S052 — Pre-design prompt: #7 outcome
- Format: G04 Headline / Divider
- Title: "Before you write: what does this need to DO?"
- Body:
  - "**Goal:** when the wave is done, advance the wave counter. Call `you_win()` or `start_next_wave()`."
  - "**Available:** `wave_in_progress`, `enemies`, `enemies_to_spawn`, `wave_index`, `WAVES`, `you_win()`, `start_next_wave()`."
  - "**Condition:** `wave_in_progress` must be `true` AND both lists must be empty."
- Image: none
- Notes: "Give kids 30 seconds to plan it before showing the slide."

#### Slide D3-S053 — Where TODO #7 lives
- Format: G12 Screenshot + Caption
- Title: "Where #7 lives — in `_process()` after the spawn ticker"
- Body: "In `_process(delta)`, after the spawn ticker block. Runs every frame."
- Image: `D3C7.png` — main.gd lines 230-256, showing `# TODO #7` banner + `#@todo`. No red overlay.
- Notes: —

#### Slide D3-S053a — Pre-TODO #7: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # if wave_in_progress and enemies.size() == 0 and enemies_to_spawn.size() == 0:
  #     set wave_in_progress to false
  #     add 1 to wave_index
  #     if wave_index >= WAVES.size():
  #         call you_win()
  #     else:
  #         call start_next_wave()
  ```
  - "**What:** Detect when a wave ends, advance the counter, win or loop."
  - "**Why:** Without this, the game never advances past wave 1."
  - "**How:** `WAVES.size()` is the total number of waves. `wave_index >= WAVES.size()` means all waves done."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D3-S054 — TODO #7: wave advance + win check
- Format: G13 TODO
- Title: "**TODO #7** — Wave advance and win check"
- Syntax: if, list_size, plus_eq, func_call
- Body RHS:
  ```gdscript
  # if wave_in_progress and enemies.size() == 0 and enemies_to_spawn.size() == 0:
  #     set wave_in_progress to false
  #     add 1 to wave_index
  #     if wave_index >= WAVES.size():
  #         call you_win()
  #     else:
  #         call start_next_wave()
  ```
- Image: `D3C7.png` — main.gd lines 230-256, red overlay on `#@todo` gap.
- Notes: 6 lines. All variables and functions are named in the comments above.

#### Slide D3-S055 — After-works: Beat all 8 waves!
- Format: G12 Screenshot + Caption
- Title: "Beat all 8 waves — YOU WIN!"
- Body: "Run the game. Survive all 8 waves. The YOU WIN panel appears."
- Image: none
- Notes: End-of-morning celebration. "Every mechanic running right now came from code YOU wrote this morning."

---

### 10.14 Personalization #4 + Final Challenge (slides S056–S062)

#### Slide D3-S056 — Personalization #4: edit the wave list
- Format: G04 Headline / Divider
- Title: "Personalization #4 — Edit the wave list"
- Body:
  - "Find `const WAVES` near the top of `main.gd`. It's a list of lists."
  - "Each entry is `[count, type]` — e.g. `[5, \"grunt\"]` spawns 5 grunts."
  - "Add a wave. Change counts. Swap types. Make wave 1 send 50 grunts for chaos."
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: open-ended. This is personalization, not a walkthrough.

#### Slide D3-S057 — Section divider: Final Challenge
- Format: G04 Headline / Divider
- Title: "Final Challenge — Endless Mode"
- Body:
  - "Open `endless_mode.gd` — a separate script with `#@todo` holes."
  - "When all holes are filled: open `main.gd`, flip `ENDLESS_MODE` to `true`, and run."
  - "Enemies spawn forever, getting harder each wave."
  - "*Boss wave is an optional extra if you want a harder challenge.*"
- Image: none
- Notes: opt-in stretch. The enable toggle and wave logic are pre-given.

#### Slide D3-S058 — FC pointer: you already know how to do this
- Format: G04 Headline / Divider
- Title: "You already know how to do this."
- Body:
  - "Each TODO in `endless_mode.gd` mirrors a chunk you wrote this morning."
  - "**FC-1** ← Chunk **#3** (`for` loops — step enemies + towers)"
  - "**FC-2** ← Chunk **#4** (`move_all` — loop a parameter list)"
  - "**FC-3** ← Chunk **#5b** (collect list, return it)"
  - "**FC-4** ← Chunk **#7** (wave counter + win check pattern)"
- Image: none
- Notes: R3 requirement — read aloud. Let kids find the mirror chunks first.

#### Slide D3-S059 — FC compressed: all holes (R3.2)
- Format: G07 Table
- Title: "Final Challenge — all holes"
- Body:
  | FC | Mirrors | Syntax | Write this (comments) |
  |---|---|---|---|
  | **FC-1** `endless_tick(delta)` | Chunk #3 | `for_in` | `# for e in enemies: step_enemy(e, delta)` / `# for t in towers: tower_tick(t, delta)` |
  | **FC-2** `move_all_endless(list, delta)` | Chunk #4 | `for_in, func_param` | `# for e in enemy_list: step_enemy(e, delta)` |
  | **FC-3** `get_in_radius_endless(pos, r)` | Chunk #5b | `list_init, for_in, list_append, return` | `# var r := []` / `# for e in enemies: if dist <= radius: r.append(e)` / `# return r` |
  | **FC-4** `check_wave_end()` | Chunk #7 | `if, list_size, plus_eq, func_call` | `# if wave_in_progress and enemies.size()==0:` / `#     wave_in_progress=false / wave_index+=1` / `#     if wave_index>=WAVES.size(): you_win() / else: next_wave()` |
- Image: none
- Notes: Detailed instructions in `endless_mode.gd` right next to each `#@todo`.

---

### 10.15 Export to .exe (slides S099–S107)

> Reuses D1 export screenshots (`D1B6S1`–`D1B6S8`) — the Godot export flow is identical every day.

#### Slide D3-S099 — Section divider: Take it home
- Format: G04 Headline / Divider
- Title: "Take it home"
- Body: "Turn your Base Defense game into a real Windows `.exe` — no Godot needed."
- Image: none
- Notes: the day's takeaway artifact.

#### Slide D3-S100 — Export 1: Project → Export
- Format: G12 Screenshot + Caption
- Title: "Step 1 — Project → Export…"
- Body: "In the top menu bar, click **Project**, then **Export…**"
- Image: `D1B6S1.png` — the Project menu open, Export… visible.
- Notes: save first (Ctrl+S) so the latest code ships.

#### Slide D3-S101 — Export 2: the Export window
- Format: G12 Screenshot + Caption
- Title: "Step 2 — The Export window"
- Body: "The Export window opens. Click **Add…** at the top to add a target."
- Image: `D1B6S2.png` — empty Export window, Add… button.
- Notes: —

#### Slide D3-S102 — Export 3: pick Windows Desktop
- Format: G12 Screenshot + Caption
- Title: "Step 3 — Choose Windows Desktop"
- Body: "From the list, pick **Windows Desktop**."
- Image: `D1B6S3.png` — platform list, Windows Desktop.
- Notes: —

#### Slide D3-S103 — Export 4: preset is ready
- Format: G12 Screenshot + Caption
- Title: "Step 4 — Your Windows preset"
- Body: "Godot adds a Windows Desktop preset. Leave options as-is — **Runnable** on, Architecture **x86_64**."
- Image: `D1B6S4.png` — Windows Desktop preset, Options tab.
- Notes: —

#### Slide D3-S104 — Export 5: if a red error shows up
- Format: G12 Screenshot + Caption
- Title: "Step 5 — If a red error shows up"
- Body: "If you see **'No export template found'**, click **Manage Export Templates**."
- Image: `D1B6S5.png` — red error + Manage Export Templates link.
- Notes: One-time per-machine install.

#### Slide D3-S105 — Export 6: install the templates
- Format: G12 Screenshot + Caption
- Title: "Step 6 — Download the templates"
- Body: "Click **Download and Install**. Let it finish, then close."
- Image: `D1B6S6.png` — Export Template Manager, Download and Install button.
- Notes: —

#### Slide D3-S106 — Export 7: name it and save
- Format: G12 Screenshot + Caption
- Title: "Step 7 — Name it and Save"
- Body: "Click **Export Project**, type a name (e.g. `Day 3 - Base Defense`), pick your folder, and click **Save**."
- Image: `D1B6S7.png` — Save dialog with filename.
- Notes: —

#### Slide D3-S107 — Export 8: your game is a real program
- Format: G12 Screenshot + Caption
- Title: "Step 8 — Double-click and play"
- Body: "Godot writes your `.exe` plus a `.pck` data file. Double-click the `.exe` — your game runs with no Godot needed. Keep the two files together."
- Image: `D1B6S8.png` — File Explorer showing .exe + .pck.
- Notes: the .exe needs the .pck beside it — copy both if you move them.

---

### 10.16 Day closer (slide S108)

#### Slide D3-S108 — Tomorrow: build a fighter
- Format: G02 Timeline / Closer
- Title: "Tomorrow: build a fighter"
- Body: "Late 1990s. Street Fighter era. We go deep on **objects** — code that knows what it IS and what it can DO."
- Image: optional fighting-game teaser (placeholder OK).
- Notes: tease Day 4's genre and concepts.

> Status: structural draft for the python-pptx slide build. Per-section slide bullets + per-chunk action-slide specs live below. Slide counts are estimates; final counts settle in build-time pass. Hand this whole `SLIDE_SOURCE.md` to the build chat.

