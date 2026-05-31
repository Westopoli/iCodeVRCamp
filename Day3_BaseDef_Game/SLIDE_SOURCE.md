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
- [ ] Sprite picks confirmed correct on visual playtest — **PENDING**.
- [ ] Obstacles + tower physics: rework decision pending — refresh §8 once locked.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 3." Output should require no follow-up clarification on chunk content. Visual playtest screenshots are a separate user-driven pass.

---

## 10. Slide blueprint — Full draft (DRAFT — locked 2026-05-29)

> Status: structural draft for the python-pptx slide build. Per-section slide bullets + per-chunk action-slide specs live below. Slide counts are estimates; final counts settle in build-time pass. Hand this whole `SLIDE_SOURCE.md` to the build chat.

### 10.0 Decisions locked

#### Locked metaphors — two per day, one per umbrella concept

Following D2's convention: each day's two umbrella concepts get one locked metaphor each. Sub-chunks under each umbrella reuse that metaphor; no fresh metaphor invention per chunk.

- **Lists** → **PS5 game library**. The home screen showing every game you own, in order. You can add a new game (download → appears at the end), remove a game (delete → leaves the library), count how many games you have (size of the library), scroll through them one at a time (iterate), or pick out specific ones (filter — "show me only the racing games"). One concept root introduces this before chunk #1, then chunks #1 / #2 / #3 / #7 callback the PS5 framing without re-teaching.

- **Deeper Functions** (nested calls) → **Vending machine + backpack**. Type in a code → vending machine drops a snack (function 1: `vend(code)` returns a snack). You grab the snack and stuff it in your backpack (function 2: `add_to_backpack(snack)` takes that snack). Two clear actions, output of the first feeds straight into the second. Two ways to say it: long form (`var snack = vend("B4"); add_to_backpack(snack)`) or short/nested form (`add_to_backpack(vend("B4"))`). One concept root introduces this before chunks #5a/#5b/#6, which callback the framing without re-teaching.

Other chunks (#4 function-takes-a-list, #5a return-one, #5b return-list) sit between the two umbrellas and lean on D2 callbacks rather than new metaphors:

- **Function** = pizza order (D2 lock — call by name, kitchen handles it).
- **Parameter / return value** = pizza extends (D2 lock — `margherita("large")` same recipe, different input, kitchen hands the pizza back).
- **for-each iteration** = no D2 metaphor was locked; D3 leans on the PS5-library framing directly (scroll the library) without a separate anchor.

#### Other locks

- **Side-by-side action-slide composition** (every chunk's payoff slide): top = R6 prose instruction. LHS = board example (literal code shown on slide). RHS = Godot screenshot of the `#@todo` region with red overlay. See §10.1 for builder-AI rules.
- **Walkthroughs reused from D1/D2**: Walk A (open project), Walk B (open script), Walk C (run F5), Walk D (read errors). Each ships as a 2-slide jog-memory pack per D2 §10 convention.
- **Walk DK (NEW for D3)**: Difficulty Knob demo — instructor-driven pre-coding setup. ~4 slides.
- **Historical context slide added to opener pack**: tower defense lineage (Rampart 1990 → WC3 maps 2002-2007 → Plants vs Zombies 2009 → Bloons / Kingdom Rush). One opener slide, ~equivalent to D2's Pac-Man revolutionary slide.
- **No payoff after every chunk**: only `#3` (enemies walk), `#6` (towers fire — big moment), and `#7` (YOU WIN) get after-works payoff slides. Chunks #1, #2a, #2b, #4, #5a, #5b have no payoff slide because their effect is invisible in isolation.

---

### 10.1 SLIDE BUILDER REFERENCE — read this before generating slides

> **AI consuming this doc to generate slides: this section is the spec for how to render each Action slide. Read carefully — the LHS/RHS layout has a precise meaning.**

For every **Action slide** in §10.4 onward (one per kid chunk):

| Slide region | What it contains | Source |
|---|---|---|
| **Top (title + body)** | R6 prose instruction — what the kid should produce, in input → output / observable-effect terms. Reads as a goal statement, not pseudo-code. | This doc's per-chunk "Prose instruction" field. |
| **LHS pane** | Literal code shown as a code block (or rendered code image). The board example pattern the kid will adapt. | This doc's per-chunk "LHS board example" field. Verbatim from §5. |
| **RHS pane** | **A SCREENSHOT of the Godot script editor** zoomed in on the chunk's location in `main.gd`. The kid `#@todo` region has a **red 4px-stroke rectangular overlay** marking the area the kid will edit. **THIS IS NOT A CODE LISTING OF WHAT THE KID TYPES.** It's a visual locator — "here is the section of `main.gd` you'll be editing." | Per-chunk "RHS screenshot" field below + the corresponding file location from §3. |
| **Speaker notes** | The R6 prose + metaphor framing + any quiz answers. Populated into the PPTX speaker-notes pane, not visible to the kid on screen. | Per-chunk "Speaker notes" field below. |

**Why this matters**: the kid is meant to look at the RHS, switch to Godot, find that region, and type their solution into the real script. The slide is a wayfinder, not a transcription target. If the RHS shows finished code, kids will copy character-by-character and miss the lesson. Earlier drafts of this doc occasionally said "RHS: code" — that wording was loose. The locked spec is **RHS = screenshot with overlay**. The "kid types" code listed in §5 of this doc is **REFERENCE for the Complete build verification**, not slide content.

Other render rules:

- **R5 partial-hole action slides** (chunks #5a and #6 — see §10.10 and §10.12): the RHS Godot screenshot uses a **two-tone overlay**. Pre-given lines (inside the function body but OUTSIDE the `#@todo`/`#@end` markers) get a **gray semi-transparent overlay**. The kid hole gets the standard red overlay. The slide caption explicitly says "gray = already written for you; red = your hole."
- **Multi-site chunks** (chunk #2 has 3 sites, chunk #6 has 2 sub-branches): one Action slide per site. Same chunk concept, separate Action slide per `#@todo` block.
- **Walkthrough hint slides** (Walk A/B/C/D and Walk DK): text + arrows only. No screenshots in the Hint slide of jog-memory packs.
- **Concept-root metaphor slides** (PS5 library, vending machine + backpack): full-bleed metaphor imagery centered, body text under image. Not LHS/RHS layout — these are explanatory, not actionable.

---

### 10.2 Opener pack (~7 slides)

1. **Day title** — "Day 3 — Base Defense · 1990 → 2009 · Tower Defense Era". Subtitle: "Rampart, WC3 TD maps, Plants vs Zombies, Bloons, Kingdom Rush." Background: composite of TD game key art.
2. **Today we'll build** — finished Base Defense screenshot + 1-line pitch: "Enemies pour in from the edges. You spend coins on towers. Survive 8 waves."
3. **Why tower defense matters** — historical context. Bullets: Rampart 1990 = hybrid first attempt. Warcraft III custom maps 2002-2007 = whole genre invented by modders. Plants vs Zombies 2009 = mainstream breakout. Bloons + Kingdom Rush = mobile-era boom. Takeaway: an entire genre came out of *modders* tweaking another game.
4. **Yesterday → Today** — D2 Pac-Man recap (Loops + intro Functions) → D3 adds **Lists + Deeper Functions**. Same `for`-loop shape, new things to loop over.
5. **5-day arc timeline** — D3 highlighted in red, D1/D2 ticked in green, D4/D5 dim.
6. **Today's two concepts** — full slide: **Lists** + **Deeper Functions**. One-line each: "Lists hold collections of things. Deeper Functions scan lists, return things, and call each other."
7. **GDScript vs Python — list ops** — 4-row side-by-side card, verbatim from §1: `enemies = []` identical, `.append` identical, `.remove` → `.erase`, `len()` → `.size()`, `def total(numbers):` → `func total(numbers):`. Takeaway line: "Lists work the same. Functions look the same. Two two-word changes total."

---

### 10.3 Pre-coding setup (~10 slides)

- **Section divider** — "Pre-coding setup."
- **Walk A — Open the Day 3 project** (jog-memory, 2 slides):
  1. Challenge: "Open the Day 3 Base Defense project the same way you did yesterday."
  2. Hint (text + arrows, no screenshots): `Godot launcher → Import → Day3_BaseDef_Game/project.godot → Import & Edit`.
- **Walk B — Open `main.gd`** (jog-memory, 2 slides):
  1. Challenge: "Open `main.gd` in the script editor."
  2. Hint: `FileSystem panel → main.gd → double-click → Script editor`.
- **Walk DK — Difficulty Knob Demo** (NEW for D3, instructor-driven, 4 slides):
  1. **Concept setup**: "One number changes the whole game. Find it." Screenshot main.gd:43 highlighting `const DIFFICULTY := 2`.
  2. **Click step 1**: change `2` → `0`, save (Ctrl+S). Diff screenshot.
  3. **Click step 2**: F5 to run. In-game screenshot with "EASY" wave label visible; enemies clearly weak. Caption: "Same code. Different feel."
  4. **Takeaway**: change back to `2`. Body: "That's a *list indexed by state* — you'll learn how lists work in a minute. `DIFF_HP_MULT[DIFFICULTY]` picks the multiplier from the list at index 0, 1, or 2."

---

### 10.4 Chunk #1 — Game state lists + counters (FULL ARC, ~12 slides)

> First chunk of the day. Carries the **LISTS** concept root as a full-arc prefix (per D2 chunk #1 pattern — concept root + metaphor + chunk action). Sets up everything chunks #2, #3, #4, #7 will lean on.

#### Concept root — LISTS (4 slides)

1. **Word slide** — "**List**." Prompt: "What does *list* mean to you?" Examples bank: grocery list, top-10 list, attendance list.
2. **Things in order** — diagram: a row of numbered boxes (0, 1, 2, 3, 4). Caption: "A list is *things in a line*. Each thing has a position."
3. **Things you do to a list** — bullets:
   - **add** something to the end
   - **remove** something
   - **count** how many there are
   - **walk through** them one at a time
   - **filter** for only the ones you care about
   Caption: "Each of these has a code word. You'll meet them today."
4. **Shape** — board example:
   ```gdscript
   var games := []                      # empty list
   var fruits := ["apple", "banana"]    # list with two items
   var score := 0                       # not a list — just a counter
   ```
   Caption: "Square brackets = list. Empty brackets = empty list. Lists hold *any number* of things."

#### Metaphor — PS5 game library (3 slides)

5. **PS5 game library** (metaphor anchor) — full-bleed mockup of a PS5 home-screen tile row. Caption: "Your game library is a list. Order matters. Each tile is one game."
6. **Quiz** — "Your PS5 library is empty. You download Hogwarts Legacy. What's `library.size()` now?" Answer reveal: 1.
7. **Trick slide** — "What if you download Hogwarts Legacy TWICE?" Answer: the library has 1 entry (PS5 won't let you download the same game twice — but in code, lists *can* hold duplicates). Caption: "Lists allow duplicates. The store won't, but the list itself doesn't care."

#### How-it's-used (2 slides)

8. **Games general** — every game uses lists: inventory in Minecraft, party in Pokémon, friends list on Xbox, queued matches in Fortnite. Caption: "Every game has a 'whose alive', 'what you own', 'what's coming next' list."
9. **Base Defense** — Diagram: two separate library rows, one labeled "Enemies (changes every frame)", one labeled "Towers (you place them)". Caption: "The whole game = scan one list, scan the other list, do something to each. Today: TWO lists."

#### Where-in-game (1 slide)

10. **`main.gd:117-122` screenshot** with red overlay on the `#@todo` block (4-line region).

#### ACTION SLIDE — #1 (1 slide, MANDATORY)

11. **Action slide**:
    - **Prose instruction (top)**: *"Declare the four things the game needs to remember between frames: an empty list of enemies, an empty list of towers, a coin counter starting at `START_COINS` (90), and a base-HP counter starting at `START_BASE_HP` (22)."*
    - **LHS board example**:
      ```gdscript
      var games := []
      var coins := 100
      ```
    - **RHS screenshot**: `main.gd:114-122` (banner + `#@todo` block), red overlay on lines 117-122.
    - **Speaker notes**: PS5 callback — "two empty libraries, one for enemies, one for towers. Plus two counters." Mention difficulty knob if not already covered in Walk DK.

#### After-works (skipped)

12. *No after-works payoff slide.* Game runs F5 without "identifier not declared" errors, but nothing visible changes yet. Payoff deferred to #3 ("Movement is alive!").

---

### 10.5 Walks C/D — Run + Read errors (jog-memory, 4 slides)

> D2 precedent: kids run early after first chunk to catch typos before piling on more logic. Even though Chunk #1 has no visible payoff, hitting F5 here confirms the variable declarations compile cleanly.

- **Walk C — Run the project** (jog-memory, 2 slides):
  1. Challenge: "Run the game and confirm it opens without errors."
  2. Hint (text + arrows, no screenshots): `F5 → Set Main Scene? → Select Current → game window opens → F8 to stop`.
- **Walk D — Reading an error** (jog-memory, 2 slides):
  1. Challenge: "Game didn't open? Find the error."
  2. Hint: `Output panel → click blue line number → fix → Ctrl+S → F5 again`.

---

### 10.6 Chunk #2 — `.append()` and `.erase()` (SMALL-ARC, ~5 slides for 3 sites)

> Chunk #2 has **three `#@todo` sites** in `main.gd` (one append + two erases). One combined Action slide handles all three — same lesson concept, three places to apply it.

- **Recap-bridge** (1 slide) — "You've got two empty libraries (`enemies` + `towers`). Time to fill and drain them."
- **Concept slide — `.append()` + `.erase()`** (1 slide) — PS5 callback, two side-by-side mini-diagrams:
  - **Left**: row of 4 tiles, 5th tile slides in from right. Caption: "`library.append('Hogwarts Legacy')` — adds to the end."
  - **Right**: row of 5 tiles, one fades out, others shift left. Caption: "`library.erase('Old Game')` — takes it out."
- **Quiz** (1 slide) — "Library has Spider-Man, FIFA, Minecraft, Stardew. You delete Minecraft. What's at position 2 now?" Answer: Stardew. Caption: "Erasing shifts everything after it forward by one."
- **How-used (Base Defense)** (1 slide) — bullets:
  - Every enemy that spawns → `.append` to `enemies`.
  - Every kill → `.erase` from `enemies` + add `reward` coins.
  - Every enemy that reaches the base → `.erase` from `enemies` (no kill bounty — the enemy got through).
- **Where-in-game** (1 slide) — three thumbnails side-by-side: `main.gd:310` (#2a inside `spawn_enemy`), `main.gd:337` (#2b reward branch inside `kill_enemy`), `main.gd:343` (#2b no-reward branch). Red overlay on each thumbnail.

#### ACTION SLIDE — #2 combined (1 slide, MANDATORY)

> Single instruction slide covering all three `#2` sites. Kids do three small things in three places — same lesson, three applications.

- **Prose instruction (top — three numbered bullets)**:
  *Three small holes, same lesson:*
  1. *In `spawn_enemy` (line 310): a brand-new enemy `e` just spawned — add it to the `enemies` list.*
  2. *In `kill_enemy`'s reward branch (line 337): a tower killed this enemy — take it off the list and pay `reward` coins.*
  3. *In `kill_enemy`'s no-reward branch (line 343): this enemy reached the base — take it off the list (no bounty, the enemy got through).*

- **LHS board examples (stacked, one per site)**:
  ```gdscript
  # #2a — append:
  library.append("Hogwarts Legacy")

  # #2b reward — erase + pay:
  library.erase("Old Game")
  coins += 50

  # #2b no-reward — erase only:
  library.erase("Game I Never Played")
  ```

- **RHS screenshot (triptych)**: three vertically-stacked thumbnails of the Godot script editor, one per site. Each thumbnail shows ~5-line window around the `#@todo` block, red overlay on the kid hole region:
  - Top thumbnail: `main.gd:298-312`, red overlay on lines 310-312.
  - Middle thumbnail: `main.gd:324-340`, red overlay on lines 337-340.
  - Bottom thumbnail: `main.gd:341-345`, red overlay on lines 343-345.
  Caption above the triptych: "Three holes. Same idea."

- **Speaker notes**: All three are list grow/shrink. Without #2a, every enemy that spawns is invisible to the game. Without #2b, dead enemies stay in the list and towers keep shooting at them. The no-reward branch is the same code minus the coin line — the kill just wasn't a kill, the enemy made it through.

- **No after-works** — payoff deferred to chunk #3 ("Movement is alive!"), where enemies actually start walking.

---

### 10.7 Chunk #3 — Iterate two lists each frame (~5 slides)

- **Recap-bridge** (1 slide) — "Yesterday you wrote `for x in list:`. Today you write it twice — one for enemies, one for towers."
- **D2 callback** (1 slide) — board example: `for colour in ["red", "green", "blue"]: print(colour)`. Caption: "Same shape you wrote yesterday."
- **How-used (Base Defense)** — bullets: "Every frame: walk every enemy → step it forward by `delta`. Every frame: walk every tower → tick its cooldown + try to fire."
- **Where-in-game** — `main.gd:217-234` screenshot, red overlay on lines 229-234.
- **ACTION SLIDE — #3**:
  - **Prose**: *"Every frame, give every enemy a step forward and every tower a tick. Without this, nothing moves and nothing shoots."*
  - **LHS**:
    ```gdscript
    for game in library:
        print(game)
    ```
  - **RHS screenshot**: `main.gd:217-234`, red overlay on lines 229-234.
  - **Speaker notes**: two for-loops, back to back. Each is a clean PS5 "scroll through every game" pattern.
- **After-works** (PAYOFF) — F5 → wave 1 auto-starts → enemies walk toward base. Towers still don't fire (that's #6). Caption: "Movement is alive!"

---

### 10.8 Chunk #4 — Function takes a list as parameter (~5 slides, no new metaphor)

- **Recap-bridge** — "Yesterday: pizza order took ONE input (`margherita('large')`). Today: a function can take a WHOLE LIST as input."
- **D2 pizza callback** (1 slide) — board example: `func add_points(amount): score += amount`. Caption: "Yesterday: amount was a number. Today: it can be a list."
- **PS5 callback to lists** — "Imagine a function `import_library(games)` — you hand it your whole PS5 library at once. The function does something to every game inside." Caption: "The list is the *input*. The function decides what to do."
- **How-used (Base Defense)** — `move_all(enemy_list, delta)` is just chunk #3's enemy loop, repackaged so the list comes in through the *door* instead of from the file's `enemies` variable. The instructor mentions: "Nothing calls `move_all()` yet. It's a tool sitting in the toolbox. You CAN later refactor your #3 enemy loop to `move_all(enemies, delta)` — same result."
- **Where-in-game** — `main.gd:362-379` screenshot, red overlay on lines 376-379.
- **ACTION SLIDE — #4**:
  - **Prose**: *"Write the body of `move_all`. Walk every enemy in the `enemy_list` parameter and step it forward by `delta`. Same shape as #3, just using the list that was handed in."*
  - **LHS**:
    ```gdscript
    func total(numbers):
        var s = 0
        for n in numbers:
            s += n
        return s
    ```
  - **RHS screenshot**: `main.gd:362-379`, red overlay on lines 376-379.
  - **Speaker notes**: parameter is a list. Inside the function, use `enemy_list` (not `enemies`). No after-works payoff because nothing calls move_all() by default.

---

### 10.9 Chunk #5a — Function returns ONE from a list (FULL ARC, ~12 slides)

> First chunk of the day's **second** concept, **Deeper Functions**. Carries the DEEPER FUNCTIONS concept root as a full-arc prefix (per D2 chunk #4 pattern — concept root + pizza metaphor + chunk action). Sets up everything chunks #5b + #6 will lean on.

#### Concept root — DEEPER FUNCTIONS (3 slides)

1. **Section divider** — "Functions go deeper."
2. **Bridge from D2** — recap: "Yesterday you learned what a function is — pizza order: call by name, kitchen handles it. Today functions get three new tricks." Bullets:
   - Scan a list and **pick ONE** thing (this chunk)
   - Scan a list and **collect MANY** things (next chunk)
   - **Plug one function into another** — output of one becomes input of the next (chunk after that)
3. **Today's three new tricks, mapped to chunks** — table:
   | Trick | Chunk | Vending analogy |
   |---|---|---|
   | Scan + pick ONE | #5a | Vending machine drops the closest snack |
   | Scan + collect MANY | #5b | Combo button — vending drops every snack in a radius |
   | Plug into another | #6 | Whatever vending returns goes straight into backpack |

#### Metaphor — Vending machine + backpack (4 slides)

4. **Vending machine** (metaphor anchor) — full-bleed image: vending machine with B4 keypad lit. Caption: "Type in B4. Machine drops Doritos. The machine is a *function*: input = the code, output = a snack."
5. **Backpack** — full-bleed image: kid stuffing snack into backpack. Caption: "You grab the snack. You put it in your backpack. `add_to_backpack(snack)`. Another function. Input = snack, output = nothing (your backpack just changed)."
6. **Output of one feeds input of next** — diagram with arrow: `vend("B4")` → returns snack → `add_to_backpack(snack)`. Caption: "The first function's *answer* is the second function's *question*."
7. **Two ways to say it** — side-by-side code:
   ```gdscript
   # Long form (two lines):
   var snack = vend("B4")
   add_to_backpack(snack)

   # Short / nested form (one line):
   add_to_backpack(vend("B4"))
   ```
   Caption: "Same exact result. The inside function runs first." (Vending + backpack lesson lands fully here; chunks #5b + #6 will lean on this without re-teaching.)

#### Best-so-far tracker — the shape of #5a (1 slide)

8. **Concept slide — best-so-far tracker** — diagram: row of 5 enemies, tower in center. Show a "current winner" arrow that swings to each new closer enemy as the walk progresses. Caption: "Walk the list. Keep the winner so far. Swap if you find a better one. Hand the winner back at the end."

#### How-it's-used (1 slide)

9. **Base Defense** — "Cannon and Sniper both ask: which enemy is closest AND in range? The function that answers is `get_nearest_enemy_in_range`. The vending machine drops *that* enemy. The backpack will be `fire_at` — but that's chunk #6's job."

#### Where-in-game (1 slide)

10. **`main.gd:389-419` screenshot** with two-tone overlay: **gray overlay** on pre-given init lines (392-395) + return line (418), **red overlay** on kid hole (409-415). Slide caption: "Gray = already written for you. Red = your hole."

#### ACTION SLIDE — #5a (1 slide, MANDATORY)

11. **Action slide**:
    - **Prose instruction (top)**: *"Walk every enemy in `enemies`. For each one, measure its distance from `pos`. If it's inside `tower_range` AND closer than `best_dist`, it's the new winner — update `nearest` and `best_dist`."*
    - **LHS board example**:
      ```gdscript
      for kid in line:
          var h = kid.height
          if h > best_height:
              tallest = kid
              best_height = h
      ```
    - **RHS screenshot**: `main.gd:389-419` with two-tone overlay (gray on pre-given init + return; red on lines 409-415 kid hole).
    - **Speaker notes**: compound `if` (`d <= tower_range and d < best_dist`) — that's `and` from D1's conditions lesson. Two checks at once. Init + return are pre-given so the kid only writes the loop body.

#### After-works (skipped)

12. *No after-works payoff slide.* Cannon and Sniper still don't actually fire until chunk #6 wires them up. Payoff deferred to chunk #6 ("TOWERS FIRE!").

---

### 10.10 Chunk #5b — Function returns LIST from list (~4 slides)

- **Recap-bridge** — "Same scan shape as #5a. But instead of stopping at one winner, collect *every* match into a new list."
- **How-used (Base Defense)** — "Splash towers hit *everyone* in their blast radius — not just the closest. So they need a *list* of victims, not a single one."
- **Where-in-game** — `main.gd:429-450` screenshot, red overlay on lines 444-450.
- **ACTION SLIDE — #5b**:
  - **Prose**: *"Build a brand-new empty list. Walk every enemy in `enemies`. If its distance to `pos` is within `radius`, add it to the new list. Return the list at the end."*
  - **LHS**:
    ```gdscript
    func filter_in_radius(list, pos, r):
        var result = []
        for item in list:
            if pos.distance_to(item.position) <= r:
                result.append(item)
        return result
    ```
  - **RHS screenshot**: `main.gd:429-450`, red overlay on lines 444-450.
  - **Speaker notes**: returning an empty list is fine — the caller (Splash tower) checks `targets.size() > 0` before firing.

---

### 10.11 Chunk #6 — `match` + nested function calls (~6 slides)

- **Recap-bridge** — "You've written three functions today: `move_all`, `get_nearest_enemy_in_range`, `get_enemies_in_radius`. Time to plug them in."
- **Match pre-given note** — "The `match` keyword routes by tower type. It's a *Day 4* concept, so it's already written for you. You fill in what each branch does." Diagram: tower type arrow → match → two branches (Cannon/Sniper / Splash).
- **How-used (Base Defense)** — table:
  | Tower | Targeting | Function called |
  |---|---|---|
  | Cannon, Sniper | Single enemy | `get_nearest_enemy_in_range` (#5a) |
  | Splash | List of enemies | `get_enemies_in_radius` (#5b) |
- **Where-in-game** — `main.gd:467-512` screenshot with two-tone overlay: **gray** on lines 493-497 + 504-505 (match skeleton + branch labels — pre-given), **red** on lines 498-503 (#6a) + 506-511 (#6b — kid sub-holes). Slide caption: "Gray = already written for you (the `match` dispatcher). Red = your two holes — one per branch."
- **ACTION SLIDE — #6a (Cannon + Sniper branch)**:
  - **Prose**: *"For single-target towers: use `get_nearest_enemy_in_range` to find a victim. If there is one, call `fire_at` on it for `t_damage`, then reset the tower's cooldown to `t_rate`."*
  - **LHS** (vending + backpack pattern with null guard):
    ```gdscript
    var snack = vend("B4")
    if snack != null:
        add_to_backpack(snack)
    ```
  - **RHS screenshot**: `main.gd:495-503`, red overlay on lines 498-503.
  - **Speaker notes**: "`get_nearest_enemy_in_range` is the vending machine; `fire_at` is the backpack. Null guard is the 'machine ate your money' case."
- **ACTION SLIDE — #6b (Splash branch)**:
  - **Prose**: *"For Splash towers: use `get_enemies_in_radius` to grab everyone in range. If at least one enemy is there, call `fire_at` on the whole list for `t_damage`, then reset cooldown to `t_rate`."*
  - **LHS**:
    ```gdscript
    var snacks = vend_combo("B4")
    if snacks.size() > 0:
        add_to_backpack(snacks)
    ```
  - **RHS screenshot**: `main.gd:504-511`, red overlay on lines 506-511.
  - **Speaker notes**: "`size() > 0` mirrors the null guard from #6a — same idea, different return type (list vs single)."
- **After-works (BIG PAYOFF MOMENT)** — full-game screenshot. Yellow line flashes mid-fire. Wave 1 visibly clearing. Caption: "TOWERS FIRE!" Body: "Place a tower, watch enemies fall. This is the moment the game becomes a *game*."

---

### 10.12 Chunk #7 — Size check + wave trigger (~5 slides)

- **Recap-bridge** — "How does the game know a wave is done?"
- **`.size()` + PS5 callback** — "`enemies.size()` = how many enemies are alive. Like `library.size()` = how many games you own."
- **Quiz** — "`enemies.size() == 0` — is the wave done? Trick question. Answer: maybe. There could still be enemies waiting to spawn (`enemies_to_spawn.size() > 0`). Both lists must be empty."
- **How-used (Base Defense)** — "Wave done → bump `wave_index` → if past the last wave, `you_win()`. Otherwise `start_next_wave()`."
- **Where-in-game** — `main.gd:237-262` screenshot, red overlay on lines 254-262.
- **ACTION SLIDE — #7**:
  - **Prose**: *"When the field is empty AND the spawn queue is empty AND a wave is in progress, the wave is done. Flip `wave_in_progress` off, bump `wave_index`, and either call `you_win()` (if no waves left) or `start_next_wave()`."*
  - **LHS**:
    ```gdscript
    if library.size() == 0:
        print("buy a game!")
    ```
  - **RHS screenshot**: `main.gd:237-262`, red overlay on lines 254-262.
  - **Speaker notes**: triple-condition `if` with `and`. `wave_in_progress` guard stops this from firing repeatedly between waves.
- **After-works (HUGE PAYOFF)** — wave 1 ends → wave 2 starts → ... → after wave 8, **YOU WIN** panel appears. Caption: "Beat all 8 waves. End-of-day celebration moment."

---

### 10.13 Personalization layer (~22 slides)

> Section divider — "Make it yours."

- **Beat 1 — Tune tower stats** (3 slides): open dictionary → change a number → run. Example: cannon damage 3 → 30.
- **Beat 2 — Re-tint with Modulate** (3 slides): same dictionary, `Color(R, G, B)` field. Example: orange cannon → blue cannon.
- **Beat 3 — Swap a tower sprite** (4 slides): browse `assets/kenney_td/` → pick a tile → edit the `"tile"` number → run.
- **Beat 4 — Drag a Kenney scenery prop into the scene** (4 slides): editor walkthrough — click Scenery node, drag from FileSystem panel, position, scale, save.
- **Beat 5 — Flip the difficulty knob** (2 slides — callback to Walk DK from §10.3).
- **Beat 6 (stretch) — Edit the wave list** (3 slides): add waves, change counts, change types.
- **Beat 7 (stretch) — Add a new wave entry** (3 slides): append a `[20, "runner"]` final boss wave.

---

### 10.14 Final Challenge — `endless_mode.gd` (~22 slides — close to D2's 25-30 envelope)

> User-locked envelope: D2 FC pack was ~25-30 slides for 6 holes. D3 has 9 holes — aim for ~22 by collapsing per-hole packs to one Action slide each (no per-hole mirror pointer, since the global R3 pointer slide already shows the map).

- **Section divider** — "Final Challenge — Endless Mode."
- **FC payoff card** (1 slide) — what endless mode looks like in motion. Body: "Rip out the 8 waves. Spawn forever. Everything ramps. No win screen. The game ends only when the base falls."
- **R3 POINTER SLIDE** (1 slide, REQUIRED per BIBLE §4 R3) — global mirror map. Exact text from §7's "Pointer slide" block. Core message: "You've already learned how to do every one of these. Each FC hole is a *reword* of a chunk you wrote this morning."
- **FC enable walkthrough** (3 slides):
  1. Open `main.gd`, scroll to line 76.
  2. Change `const ENDLESS_MODE := false` → `true`.
  3. Save (Ctrl+S), run (F5). Endless mode banner appears in the HUD.
- **Per-hole Action slides** — one slide each (no separate mirror-pointer slide per hole; the R3 pointer above covers it). Each Action slide:
  - **Top prose** = the FC hole's outcome statement (verbatim from §7's "Goal" field).
  - **LHS** = the morning chunk's board ex (reused — kids already saw it).
  - **RHS screenshot** = the FC file's `#@todo` region in `endless_mode.gd`, red overlay.
  - **Banner caption** = "FC-X ← chunk #Y" — small mirror-pointer banner at the top of the slide, not a dedicated slide.

  Slide list:
  - **FC-1** — state vars (`spawn_timer`, `difficulty`, `spawn_interval`, `spawn_queue`, `clear_streak`)
  - **FC-2a** — `queue_spawn(t)` body
  - **FC-2b** — `take_next_spawn()` body
  - **FC-3** — per-frame buff sweep inline in `endless_tick`
  - **FC-4** — `buff_all(enemy_list, delta)` body
  - **FC-5a** — `get_fastest_enemy()` R5 partial (gray/red two-tone like #5a)
  - **FC-5b** — `get_wounded_enemies()` body
  - **FC-6** — `escalate()` four-band match. One slide showing all four branches together (compact — each branch is 2 lines, fits on one slide). Banner: "FC-6 ← chunk #6 (same shape, four times)."
  - **FC-7** — `check_for_screen_clear()` body
- **FC payoff (1 slide)** — endless mode in motion screenshot. Caption: "Survive as long as you can."

Total: 1 divider + 1 payoff card + 1 R3 pointer + 3 enable walk + 9 hole action slides + 1 final payoff = **16 slides** (well within ~22 envelope). Slack for any per-hole that needs an extra recap.

---

### 10.15 Day closer (~3 slides)

1. **Recap** — "Today: Lists + Deeper Functions. Two ideas. Whole game."
2. **Tomorrow teaser** — "Day 4: 2-Player Fighter. Objects + State. Your code starts to feel like a *blueprint* instead of a script."
3. **Build-time / export walkthrough** — handed to instructor in a separate pack. Slide here just points: "Ask your instructor for the export pack to ship your Windows .exe."

---

### 10.16 Build-time notes for python-pptx chat

- **Master frame**: iCode logo top-left, D3 day tab top-right (color TBD — pending brand pack), page number bottom-right per `SLIDES_FORMATS.md` master frame spec.
- **Walkthrough step badges**: jog-memory Challenge/Hint slides use small step badges (A.1, A.2, B.1, B.2, DK.1-4, C.1, C.2, D.1, D.2) top-right.
- **Red overlay** on RHS Godot screenshots: 4px stroke, fully transparent fill, drawn over the kid `#@todo` region.
- **Gray overlay** for R5 partial holes (#5a, #6, FC-5a): semi-transparent fill (alpha ~0.3), no stroke, over pre-given lines.
- **Speaker notes**: every Action slide populates its "Speaker notes" field per §10.5+ above.
- **Estimated total slide count**: 105-120 slides. Final count locks in build-time pass.
- **Verification before build**: re-run §9 checklist. If `main.gd` line numbers shift, all RHS screenshots + line refs must update.

---

### 10.17 Pending decisions (blocking final build)

- [ ] **Day tab color for D3** — brand pack pending.
- [ ] **Historical context slide content** — Tower defense lineage sourcing pending (Rampart 1990, WC3 maps 2002-2007, PvZ 2009, Bloons/Kingdom Rush).
- [ ] **D1 retrofit** — add equivalent historical-context slide to D1 Pong opener per D2 precedent.
- [ ] **Sprite picks confirmed on visual playtest** — pending; flag any swaps that affect §8.
- [x] **R5 framing slide deduplication** — resolved 2026-05-30: matched D2 precedent. R5 framing is now folded into each chunk's Where-in-game slide caption ("Gray = pre-given. Red = your hole"), no standalone R5 framing slide.

---

## Rework log

- **2026-05-26** — Initial drafting. Chunks #3/#5a/#5b/#6 tagged `(STRETCH)`. 4-hole `endless_mode.gd` shipped (FC-1/FC-2/FC-3/FC-4 only).
- **2026-05-29 (R1-R6 + R3.1 pass)** — Stripped `(STRETCH)` from morning chunks. Rewrote TODO comments to outcome-based framing (R6). Split #5a into R5 partial hole (init + return pre-given). Split #6 into R5 partial dispatcher (kid fills #6a + #6b branches inside pre-given `match`). Wired FC hook in `main.gd` (`fc_node` field, `_ready` gating, `_process` routing, `update_hud` endless label). Rewrote `endless_mode.gd` from 4 holes to 12 `#@todo` sub-holes mirroring all 8 morning chunks (FC-1, FC-2 with sub-holes 2a + 2b, FC-3, FC-4, FC-5a, FC-5b, FC-6 ×4 branches, FC-7) to satisfy BIBLE §4 R3.1 (FC mirror completeness). FC kid LoC: 36 vs morning 39 (−8%).
- **2026-05-29 PM (§10 slide blueprint pass)** — Locked PS5 game library (Lists concept) + vending machine + backpack (Deeper Functions concept) as the two D3 metaphors per D2 convention (one metaphor per umbrella concept, all chunks under that umbrella reuse without re-teaching). Expanded §10 into full slide blueprint with per-section bullets (opener pack, pre-coding, two concept roots, all 8 chunks with R6 action-slide specs, personalization, FC). Added §10.1 SLIDE BUILDER REFERENCE clarifying RHS = Godot screenshot with red overlay (NOT a code listing) so the python-pptx build chat doesn't misinterpret per-chunk RHS fields. FC pack collapsed to ~16 slides (one Action slide per FC mirror hole + R3 pointer + payoff + enable walk) per user's "close to D2's 25-30" cap. R5 partial-hole slides use two-tone overlay (gray on pre-given, red on kid hole) for #5a, #6, FC-5a.
- **2026-05-30 (§10 restructure pass)** — User feedback on §10 draft. Adopted BIBLE Lingo lock (concept = umbrella idea; chunk = §4 table row; sub-hole = `#@todo` block). Re-nested standalone LISTS + DEEPER FUNCTIONS concept roots into their first-use chunk arcs (Chunk #1 + Chunk #5a respectively) per D2 precedent. Moved Walks C/D from after Chunk #3 to after Chunk #1 per D2 precedent (run early, catch typos). Consolidated Chunk #2 from three Action slides into one combined instruction slide. Removed dedicated R5 framing slides from Chunk #5a + Chunk #6 (rely on action-slide caption + two-tone overlay only, matching D2 #6 precedent). Propagated lingo fix throughout §3 chunk table, §9 checklist, INSTRUCTOR_NOTES.
