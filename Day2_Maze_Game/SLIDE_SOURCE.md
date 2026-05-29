# Day 2 — Maze (Pac-Man) — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 2 slide deck.
> Verified against `Day2_Maze_Game/main.gd` + `ghost_personalities.gd` + `Main.tscn` +
> `PacmanTileSet.tres` on 2026-05-26. Instructor-facing companion is
> `Day2_Maze_Game/INSTRUCTOR_NOTES.md`. Reads top-to-bottom as the day's lesson flow.

## Table of contents

- **§1 Day narrative card** — year, iconic title, concepts introduced, GDScript-vs-Python card.
- **§2 Build narrative** — how the maze is built: scene tree, file manifest, TileSet/TileMapLayer pattern, asset pack, no-physics framing.
- **§3 Chunk table** — chunk ID → concept → file location → hole size, in BIBLE/lesson order.
- **§4 Pre-coding setup** — open project, open script, run, read errors. Day 1 walkthroughs apply (reused).
- **§5 Lesson chunks** — per-chunk slide source in BIBLE order. Concept → Goal → Board example → In-file location → As-typed code → Hint progression. Each chunk = one section of the lesson.
- **§6 Personalization layer** — "make it yours" end-of-day beat: repaint walls/dots, swap dot tile, move tunnel row, tweak timing consts, sprite swap.
- **§7 Stretch goals — Final Challenge (`ghost_personalities.gd`)** — replace the 3 generic ghosts with 4 authentic Pac-Man personalities (Blinky/Pinky/Inky/Clyde). Mirrors morning chunks #2/#4/#5/#6.
- **§8 Asset / atlas reference** — Kenney pack, atlas path, source IDs, tile-swap options.
- **§9 Verification checklist** — internal sanity; re-run if `main.gd` or `ghost_personalities.gd` changes.

---

## 1. Day narrative card

- **Year**: 1980
- **Iconic title**: **Pac-Man** (Namco) — chomp dots, dodge ghosts, find the tunnel.
- **Genre today**: top-down maze chase.
- **Concepts introduced**: **Loops** (`for`, `while`) + **Functions** (no params, with params, return values).
- **Why this game today**: every loop concept maps to something the kid can see — `for i in range(3)` spawns 3 ghosts, `for ghost in ghosts` moves each ghost, `while` scans a 28 × 31 grid counting dots, functions wrap up "what to do when player moves" so the same logic is re-used. The grid + ghost AI exercises every Day 2 idea visibly.

### GDScript vs Python (Day 2 slide — pull verbatim into deck)

```
Python:   for i in range(5):         GDScript:   for i in range(5):
              print(i)                               print(i)

Python:   for item in stuff:         GDScript:   for item in stuff:
              print(item)                            print(item)

Python:   while lives > 0:           GDScript:   while lives > 0:
              keep_playing()                         keep_playing()

Python:   def add(a, b):             GDScript:   func add(a, b):
              return a + b                           return a + b
```

**Takeaway line**: "Day 2 in GDScript is *identical* to Python except for one word: `def` becomes `func`."

---

## 2. Build narrative — how the maze was built

The maze is a **28-tile-wide × 31-tile-tall grid** (Pac-Man classic dimensions, each tile 16 × 16 pixels → 448 × 496 pixel playfield). Two **TileMapLayer** nodes share one **TileSet** resource. The `Walls` layer holds wall tiles; the `Dots` layer holds pellets. The player and ghosts are simple `Node2D` / `ColorRect` placeholders that **don't use Godot's physics** — wall collision is hand-checked by the kid's `hit_wall(cell)` function (TODO #6), and movement is grid-snapped (tile-to-tile tweens, 0.15 s per tile for player, 0.22 s for ghosts).

3 ghosts spawn in a pen near the centre. They wait `GHOST_RELEASE_DELAY = 2.0` seconds so the player has a head-start, then patrol via a 50% chase / 50% random rule (helper `step_ghost` is pre-given). Touching a ghost costs a life; chomping every dot wins.

The maze ships **pre-painted in the editor by the instructor** (BIBLE Q9=A revision — kid's *personalization* step is to repaint, not to build from blank, so day-2 launch isn't blocked by 30 minutes of painting before any code runs).

### TileSet / TileMapLayer — the big new Godot concept today

> Orientation slide. Walks the kid through what they're *seeing* when they look at the `Walls` and `Dots` nodes in the scene tree. The scaffold is wired already — this is read-only "what is this thing" content.

- **TileSet** = the **palette**. A `.tres` resource (`PacmanTileSet.tres`) that takes the Kenney atlas PNG and chops it into addressable 16×16 tiles. "Tile #5 is this region of the PNG; it's a wall."
- **TileMapLayer** = a **node in the scene** that paints tiles from a TileSet onto the 2D grid. One layer = one painted surface. Day 2 uses **two**: `Walls` (collision tiles) and `Dots` (the pellets to chomp).
- Both layers reference the **same** TileSet — the palette is shared, the painted surfaces are separate.
- Kid's chunk #6 (`hit_wall`) calls `wall_layer.get_cell_source_id(cell)` — returns the tile's source ID or `-1` if no tile is painted at that cell. That's the *entire* API surface kids touch.

Steps to open the TileSet panel for yourself (one-time orientation):

1. Click the `Walls` node in the scene tree.
2. In the Inspector, find the **Tile Set** property → click the resource name (`PacmanTileSet`) → **Edit**.
3. The TileSet panel pops up at the bottom of the editor.
4. The left side shows **Sources** — one source: the Kenney atlas (`tilemap_packed.png`).
5. Click the source row → the atlas image appears chopped into 16×16 tiles on the right.
6. Click the `2D` button up top to go back to scene view.

### Scene tree (Main.tscn)

```
Main (Node2D) — script: main.gd
├── Background (ColorRect)       448×496, dark-blue (0.04, 0.04, 0.08)
├── Walls      (TileMapLayer)    tile_set = PacmanTileSet.tres
├── Dots       (TileMapLayer)    tile_set = PacmanTileSet.tres (same)
├── Player     (Node2D)
│   └── Body   (ColorRect)       16×16, yellow (placeholder for sprite swap)
├── GhostPen   (Marker2D)        position (216, 232) — ghosts spawn around here
└── UI         (CanvasLayer)
    ├── LivesLabel    "Lives: 3"
    ├── DotsLabel     "Dots: 0"  (overwritten by `update_ui()`)
    └── GameOverPanel (Panel, hidden until game over)
        └── Label     "GAME OVER\nPress R to restart"
```

### File manifest

| File | Role | Kid edits? |
|---|---|---|
| `project.godot` | Window, main scene = `Main.tscn` | No |
| `Main.tscn` | Scene tree above; walls + dots already painted by instructor | No (kid repaints in §6) |
| `PacmanTileSet.tres` | TileSet resource that maps tile IDs to atlas regions of `tilemap_packed.png` | No |
| `assets/Tilemap/tilemap_packed.png` | The Kenney Tiny Dungeon atlas (one big PNG of 16×16 tiles) | No |
| `assets/Tiles/tile_NNNN.png` | Same Kenney pack, exploded into one-PNG-per-tile (kept for reference / swaps) | No |
| `main.gd` | All Day 2 chunks (#1, #2, #3, #4, #5, #6) | **Yes — main scaffold** |
| `ghost_personalities.gd` | Final Challenge — Blinky / Pinky / Inky / Clyde | **Yes — FC opt-in** |
| `INSTRUCTOR_NOTES.md` | Instructor-only doc (TileSet wiring, stuck-point cheat sheet) | No — instructor reference |

### Asset pack

- **Pack**: Kenney **Tiny Dungeon** (kenney.nl) — CC0, no attribution required.
- **Atlas**: `assets/Tilemap/tilemap_packed.png`, 16 × 16 tile size, no margin, no separation.
- **TileSet resource**: `PacmanTileSet.tres` — auto-created tiles from every non-empty 16×16 region.
- **Active sources in the painted scene** (decoded from `Main.tscn` `tile_map_data`):
  - **Walls layer**: source_id `4`, atlas coord `(0, 3)` — the stone-block tile.
  - **Dots layer**: source_id `8`, atlas coord `(0, 9)` — the chosen pellet substitute (coin/gem/heart — see §8).
- **Free-form / kid-personalization swaps**: any tile in the atlas can be substituted. The code only cares whether `get_cell_source_id(cell) != -1`, not which tile.

### Sim / tuning story

No Python sim for Day 2. Numeric tunings live as constants at the top of `main.gd`:

| Const | Value | What it does |
|---|---|---|
| `TILE` | 16 | Pixels per tile (matches Kenney atlas tile size). |
| `MAZE_W`, `MAZE_H` | 28, 31 | Classic Pac-Man dimensions. |
| `STEP_TIME` | 0.15 s | Player slide time per tile (~6.6 tiles/sec). |
| `GHOST_STEP_TIME` | 0.22 s | Ghost slide time per tile (slower than player). |
| `GHOST_RELEASE_DELAY` | 2.0 s | Grace period at start before ghosts move. |
| `TUNNEL_ROWS` | `[13]` | Row(s) where stepping off-edge wraps to the other side. |
| `PLAYER_START` | `Vector2i(14, 12)` | Classic Pac-Man spawn cell. |

---

## 3. Chunk table — verified against `main.gd` (refreshed 2026-05-29 under R1-R6)

In lesson order (also BIBLE §4 order and `main.gd` file order):

| # | Concept | File location | Kid LoC | Hole size |
|---|---|---|---|---|
| #1 | `for i in range(N)` | `main.gd:69-72` (in `_ready`) | 2 | tiny |
| #2 | `for item in list` | `main.gd:123-126` (in `_process`, inside `else` branch) | 2 | tiny |
| #3a (caller) | calling `count_dots()` | `main.gd:77-79` (in `_ready`) | 1 | tiny |
| #3b (body) | `while` loop scan | `main.gd:213-225` (whole `count_dots()` func) | 10 | medium |
| #4 | `func` no params | `main.gd:153-160` (whole `reset_player()`) | 5 | medium |
| #5 | `func` with param | `main.gd:171-178` (whole `move_player(direction)`) | 5 | medium |
| #6 | `func` returning bool (R5 partial-section hole) | `main.gd:201-204` (kid hole only — the in-grid wall query inside `hit_wall(cell)`; off-grid + tunnel guards pre-given above) | 2 | tiny |

**Total**: 7 `#@todo`/`#@end` blocks across **6 conceptual chunks**.

**Notes (R1-R6 compliance):**
- No mid-day stretch tags (R1).
- Every kid line is single-purpose, no nested calls, no chained methods (R2 D1-D2 ceiling).
- Pre-given helpers `ghost_spawn_pos`, `cell_has_dot`, `step_player_to` hide the over-ceiling expressions (e.g. `Vector2i(x, y)` nested in `get_cell_source_id`) so each kid line stays at ceiling.
- No predicate-chain composition; each helper stands alone (R4).
- Chunk #6 is a partial-function hole: kid writes only the in-grid wall query (the part that mirrors morning board ex `return n % 2 == 0`); off-grid + tunnel guards are pre-given (R5).
- TODO comments state goal in outcome terms; no pseudo-code patterns (R6).

---

## 4. Pre-coding setup

> Identical to Day 1's pre-coding setup — kids already know how to open a project, open a script, run, and read errors. Reuse Day 1 walkthroughs A/B/C/D for the Day 2 deck (re-target the project path to `Day2_Maze_Game/`).
> The one Day-2-specific orientation step (browse the TileSet to see the atlas) is already covered in §2 Build narrative above. Show that slide here as part of "what's new in this project" before chunk #1.

---

## 5. Lesson chunks (BIBLE order)

### Chunk #1 — `for i in range(N)` (spawn 3 ghosts)

- **Concept**: `for i in range(3):` runs the indented block 3 times, with `i` = 0, 1, 2.
- **Goal**: Spawn 3 ghosts side by side in the ghost pen. Use a `for` loop so we write the spawn call once instead of three times. When you run the game, you should see 3 red squares lined up inside the pen.
- **Board example**:
  ```gdscript
  for i in range(3):
      print(i)
  ```
- **In-file location**: `main.gd:65-72`, inside `_ready()`, under `# TODO #1: there should be 3 ghosts lined up in the pen ...`
- **Pre-given helper used**: `ghost_spawn_pos(index) -> Vector2` — returns world position for the index-th ghost (hides the `pen_marker.position + Vector2(i * TILE, 0)` math so the kid line stays single-purpose, no nesting).
- **As-typed code**:
  ```gdscript
  for i in range(3):
      spawn_ghost_at(ghost_spawn_pos(i))
  ```
---

### Chunk #2 — `for item in list` (move every ghost each frame)

- **Concept**: `for x in some_list:` runs the block once per item in the list. Inside the block, `x` is the current item.
- **Goal**: Each frame, walk through every ghost in the `ghosts` list and tell it to take one step. After this chunk (and the 2-second release delay), the ghosts start patrolling instead of standing still in the pen.
- **Board example**:
  ```gdscript
  for colour in ["red", "green", "blue"]:
      print(colour)
  ```
- **In-file location**: `main.gd:121-126`, inside `_process()`, inside the pre-given `else` branch (the `if PERSONALITY_MODE_ENABLED:` branch routes to the FC file).
- **As-typed code**:
  ```gdscript
  for ghost in ghosts:
      step_ghost(ghost)
  ```
---

### Chunk #3 — `while` loop (count dots in the maze)

This chunk has **two parts**: a one-line caller in `_ready()`, and the body of `count_dots()`. Slides should present them together — the body without the caller is dead code, the caller without the body won't compile.

#### 3a — Caller (in `_ready()`)

- **Goal**: Call the `count_dots()` function you'll write below (3b) and remember the answer in `dots_remaining`. This number is what the win check counts down to zero.
- **In-file location**: `main.gd:74-79`, immediately under chunk #1.
- **As-typed code**:
  ```gdscript
  dots_remaining = count_dots()
  ```

#### 3b — Body (the `count_dots()` function itself)

- **Concept**: `while <condition>:` keeps running until the condition is false. Use it here to walk every tile of the grid with two nested loops.
- **Goal**: Write a function that scans every tile in the maze, counts how many have a dot painted on them, and returns that total. This is the number the player has to chomp down to zero to win.
- **Board example**:
  ```gdscript
  var n := 0
  while n < 5:
      print(n)
      n += 1
  ```
- **In-file location**: `main.gd:207-225`, under `# TODO #3b: write func count_dots() -> int`.
- **Pre-given helper used**: `cell_has_dot(x, y) -> bool` — wraps `Vector2i(x, y)` + `get_cell_source_id(cell)` + `!= -1`, so the kid's loop body uses a single function call instead of a nested-call + chained-method expression.
- **As-typed code**:
  ```gdscript
  func count_dots() -> int:
      var count := 0
      var x := 0
      while x < MAZE_W:
          var y := 0
          while y < MAZE_H:
              if cell_has_dot(x, y):
                  count += 1
              y += 1
          x += 1
      return count
  ```
---

### Chunk #4 — `func` with no parameters (`reset_player()`)

- **Concept**: A function is a name we give to a block of code. `func name():` defines one; calling `name()` runs it.
- **Goal**: Write a function called `reset_player()` that sends the player back to the starting tile and clears any leftover movement. The game calls this when a ghost catches the player.
- **Board example**:
  ```gdscript
  func say_hi():
      print("hi!")
  ```
- **In-file location**: `main.gd:148-160`, under `# TODO #4: write func reset_player() — no inputs, returns nothing.`
- **As-typed code**:
  ```gdscript
  func reset_player() -> void:
      player_cell = PLAYER_START
      player.position = cell_to_world(player_cell)
      player_moving = false
      current_dir = Vector2i.ZERO
      queued_dir = Vector2i.ZERO
  ```
---

### Chunk #5 — `func` with a parameter (`move_player(direction)`)

- **Concept**: A function can take **inputs** (parameters). Inside the function, the parameter is a regular variable.
- **Goal**: Write the function that actually moves the player one tile in a given direction — but only if that direction isn't blocked by a wall. After this chunk, the arrow keys move the player around the maze.
- **Board example**:
  ```gdscript
  func add_points(amount):
      score += amount
  ```
- **In-file location**: `main.gd:163-178`, under `# TODO #5: write func move_player(direction)`.
- **Pre-given helper used**: `step_player_to(cell)` — updates `player_cell` and slides the sprite via `cell_to_world`, so the kid's last line is a single function call instead of nested `tween_player_to(cell_to_world(player_cell))`.
- **As-typed code**:
  ```gdscript
  func move_player(direction: Vector2i) -> void:
      var next_cell := player_cell + direction
      if hit_wall(next_cell):
          return
      next_cell = wrap_cell(next_cell)
      step_player_to(next_cell)
  ```
---

### Chunk #6 — `func` that returns a bool (`hit_wall(cell)`)

- **Concept**: A function can **return** a value. `func name() -> bool: return true_or_false` is the shape.
- **Goal**: Write a function that looks at a tile position and reports back `true` if it's a wall, `false` if it's open floor. Both the player and the ghosts use this to know what they can walk through.
- **Board example**:
  ```gdscript
  func is_even(n) -> bool:
      return n % 2 == 0
  ```
- **In-file location**: `main.gd:181-204`, under `# TODO #6: finish func hit_wall(cell) -> bool`.
- **Hole type**: **R5 partial-function hole.** The off-grid + tunnel guards (which use `or`, `in`, `not` — D2 hasn't taught those) are pre-given inside the function body and marked `# Pre-given:`. The kid's `#@todo` block holds only the in-grid wall query — the part that mirrors morning board ex `return n % 2 == 0`. Kid LoC = 2.
- **Full function (pre-given parts + kid hole), as it lives in the Complete ZIP**:
  ```gdscript
  func hit_wall(cell: Vector2i) -> bool:
      # Pre-given: cells above or below the maze are always walls.
      if cell.y < 0 or cell.y >= MAZE_H:
          return true
      # Pre-given: cells off the left/right edge are walls EXCEPT on
      # tunnel rows (where the player wraps to the other side).
      if cell.x < 0 or cell.x >= MAZE_W:
          if cell.y in TUNNEL_ROWS:
              return false
          return true
      # TODO #6: cell is inside the maze. Return whether wall_layer
      # has a wall tile at this cell.
      var source_id := wall_layer.get_cell_source_id(cell)
      return source_id != -1
  ```
- **Kid types (between `#@todo`/`#@end` only)**:
  ```gdscript
  var source_id := wall_layer.get_cell_source_id(cell)
  return source_id != -1
  ```
---

## 6. Personalization layer ("make it yours")

End-of-day beat after all morning chunks. Each beat = one walkthrough or one code edit. Order suggested.

### Beat 1 — Repaint the walls in your own shape

1. Click the `Walls` node in the scene tree.
2. Click anywhere in the **2D viewport** (the grey area showing the maze).
3. At the bottom of the editor, the **TileMap** panel appears with the tile palette on the right.
4. Click the **wall tile** in the palette (the stone-block tile, atlas coord `(0, 3)`).
5. The cursor is now a paint cursor.
6. Click-and-drag in the viewport to paint walls. Each click paints one cell.
7. To erase: hold **Shift** while clicking (eraser mode).
8. To paint in a straight line: hold **Shift** + click-drag (line tool).
9. To paint a rectangle: hold **Ctrl** + drag (rectangle tool).
10. Press **Ctrl+S** to save the scene when done.

### Beat 2 — Switch to the `Dots` layer and paint dots

> Identical workflow to Beat 1, different layer + different tile.

1. Click the `Dots` node in the scene tree (it sits **below** `Walls` in the tree).
2. Click in the 2D viewport — the TileMap panel switches to paint mode for this layer.
3. In the palette, pick the dot tile (atlas coord `(0, 9)` — the small coin/gem the scaffold ships with).
4. Paint a dot tile into every floor cell of your maze (every cell that *isn't* a wall).
5. Press **Ctrl+S** to save.

### Beat 3 — Toggle layer visibility while painting

> Useful trick: hide the walls so you can see exactly where the dots are landing.

1. Click the `Walls` node.
2. In the Inspector, scroll to **Visibility → Visible** (top of the property list, before Tile Set).
3. Uncheck it — walls disappear from the viewport.
4. Re-check it when done.
5. Same applies to the `Dots` layer.

### Beat 4 — Pick a different dot tile from the atlas

> The code only checks "is there any tile here", so any tile in the atlas works as a dot.

1. Click the `Dots` node.
2. Open the TileMap paint panel (click in the 2D viewport).
3. In the palette, click the new tile you want — try heart, gem, fruit, anything.
4. Erase the existing dots: Shift-click each one, or paint over them with the empty tile.
5. Paint the new tile in every floor cell.
6. Save with Ctrl+S.
7. Run with F5 — the `count_dots()` function counts whatever you painted; the win condition still works.

### Beat 5 — Repaint the tunnel row

> The scaffold paints row `y = 13` as the tunnel: walls have a gap on both edges of this row. Moving the tunnel requires two changes.

1. **In the maze**: erase the wall on the two edge cells of the new tunnel row (Shift-click the wall on column 0 and column 27 of the row you pick).
2. **In `main.gd`**: change `const TUNNEL_ROWS := [13]` to `[<your-row>]` (or add more rows: `[6, 13, 22]`).
3. Save and run.

### Beat 6 — Tweak the timing constants

1. Open `main.gd`, lines 18-31.
2. Change `STEP_TIME` (0.15) for player slide speed — lower = faster.
3. Change `GHOST_STEP_TIME` (0.22) for ghost speed.
4. Change `GHOST_RELEASE_DELAY` (2.0) for grace period before ghosts move.
5. Change `PLAYER_START` for spawn point.
6. Save, run.

### Beat 7 — Stretch: swap the player's yellow ColorRect for a Kenney sprite

1. In `Main.tscn`, click the `Player` node → expand to see its child `Body` (ColorRect).
2. Delete `Body`.
3. Right-click `Player` → **Add Child Node** → search **Sprite2D** → Create.
4. In the FileSystem panel, navigate to `assets/Tiles/`.
5. Drag any `tile_NNNN.png` onto the new Sprite2D's **Texture** property in the Inspector.
6. Save, run.

---

## 7. Final Challenge — `ghost_personalities.gd` (R3-compliant, redesigned 2026-05-29)

> **What "Final Challenge" means**: every day ends with one FC file. The FC tasks are **reskins of the morning chunks** — same constructs, new context. The pointer slide (below) tells the kid exactly which morning chunk each FC hole mirrors. No new concepts. The payoff is the part that's new; the *code* is reused-shape.

**File**: `ghost_personalities.gd`.
**Payoff**: replace the 3 generic 50/50 ghosts with the **4 authentic Pac-Man personalities** — Blinky (direct chaser), Pinky (ambusher 4 tiles ahead), Inky (uses Blinky to flank), Clyde (chase when far, scatter when close).
**How the difficulty drop works**: the personality math (Pinky vector ahead, Inky Blinky-mirror, Clyde scatter rule) lives entirely in **pre-given helper functions** at the top of the file. The kid never writes Vector2i arithmetic. The kid wires the personalities together using only D2-taught constructs: for-range, for-each, while, func no-params, func with param, func returning bool/int.
**Hook into main.gd**: also pre-given. `const PERSONALITY_MODE_ENABLED := false` lives at the top of `main.gd`; flipping it to `true` runs the FC code path. All boot-up, routing, and reset wiring is pre-given as gated `if PERSONALITY_MODE_ENABLED:` branches.

### Pointer slide (REQUIRED in the deck per BIBLE §4 R3)

> **You already know how to do this.** Each TODO in `ghost_personalities.gd` is a near-mirror of a chunk you wrote this morning. If you get stuck, scroll up to that morning chunk in `main.gd` and copy the *shape* (not the words).
>
> - **FC-1** ← Chunk **#1** (`for i in range(N)`)
> - **FC-2** ← Chunk **#2** (`for x in list`)
> - **FC-3** ← Chunk **#3** (`while`-loop scan + count)
> - **FC-4** ← Chunk **#4** (`func` no params)
> - **FC-5** ← Chunk **#5** (`func` with a parameter)
> - **FC-6** ← Chunk **#6** (`func` returning a value)

### Mirror map (full)

| FC hole | Mirrors | What the kid writes | Kid LoC | New concept? |
|---|---|---|---|---|
| **FC-1** `spawn_personality_ghosts()` | #1 for-range | for-range loop calling pre-given `spawn_one_personality(i)` | 2 | None — same shape as morning #1 |
| **FC-2** `step_all_personality_ghosts()` | #2 for-each | for-each over `ghosts`, calling pre-given `step_personality(ghost)` | 2 | None — literally same shape as morning #2 |
| **FC-3** `count_ghosts_of(personality) -> int` | #3 loop + count | loop over `ghosts`, increment counter when meta matches, return int | 5 | None — counter pattern from morning #3 |
| **FC-4** `reset_personality_ghosts()` | #4 func no params | for-each + index counter, call pre-given `respawn_personality_ghost(ghost, i)` | 4 | None — reset pattern from morning #4 |
| **FC-5** `target_for(ghost) -> Vector2i` | #5 func with param | read meta, four `if p == X: return X_target(ghost)` branches | 9 | None — func-with-param + return-of-call |
| **FC-6** `is_clyde_close(ghost) -> bool` | #6 func returning bool | call pre-given `distance_to_player(ghost)`, return comparison | 2 | None — mirrors `is_even(n) -> bool` shape exactly |

**Total FC kid LoC ≈ 24** (vs morning ~25). Every kid line at-or-below D2 ceiling. No `or`/`in`/`not`/nested-calls/chained-methods in any kid hole.

### Pre-given (kid never modifies — visible scaffold at top of file)

- Constants: `BLINKY`, `PINKY`, `INKY`, `CLYDE`, `PERSONALITIES`, `PERSONALITY_COUNT`, `SCATTER_CORNER`, `GHOST_COLORS`.
- Per-personality target helpers: `blinky_target / pinky_target / inky_target / clyde_target` — all Vector2i math lives here.
- `distance_to_player(ghost) -> float`, `find_blinky() -> Node`.
- `step_ghost_toward(ghost, target_cell)` — direction-picking + tween + meta updates.
- `step_personality(ghost)` — calls kid's `target_for`, then `step_ghost_toward`.
- `make_personality_ghost(world_pos, personality)`, `spawn_one_personality(index)`.
- `respawn_personality_ghost(ghost, index)`, `clear_base_ghosts()`.
- Fields `main: Node` and `ghosts: Array` — set by main.gd at boot-up.

### Per-hole detail

#### FC-1 — `spawn_personality_ghosts()`
- **Mirrors**: morning chunk #1 (`for i in range(N)`).
- **Goal**: after it runs, one ghost exists per personality (`PERSONALITY_COUNT` total).
- **Pre-given helper**: `spawn_one_personality(index)` handles one ghost at a time.
- **As-typed code**:
  ```gdscript
  func spawn_personality_ghosts() -> void:
      for i in range(PERSONALITY_COUNT):
          spawn_one_personality(i)
  ```

#### FC-2 — `step_all_personality_ghosts()`
- **Mirrors**: morning chunk #2 (`for x in list`) — same shape.
- **Goal**: every frame, every ghost takes one step.
- **Pre-given helper**: `step_personality(ghost)` moves one ghost using its personality.
- **As-typed code**:
  ```gdscript
  func step_all_personality_ghosts() -> void:
      for ghost in ghosts:
          step_personality(ghost)
  ```

#### FC-3 — `count_ghosts_of(personality) -> int`
- **Mirrors**: morning chunk #3 (loop + counter + return int).
- **Goal**: return how many ghosts in `ghosts` have the given personality tag.
- **R6 note**: TODO comment says "use any loop" — a `while`-loop solution is equally accepted.
- **As-typed code** (for-each form):
  ```gdscript
  func count_ghosts_of(personality: String) -> int:
      var count := 0
      for ghost in ghosts:
          if ghost.get_meta("personality") == personality:
              count += 1
      return count
  ```

#### FC-4 — `reset_personality_ghosts()`
- **Mirrors**: morning chunk #4 (`func` no params).
- **Goal**: after it runs, every ghost is back in the pen.
- **Pre-given helper**: `respawn_personality_ghost(ghost, index)` resets one ghost.
- **As-typed code**:
  ```gdscript
  func reset_personality_ghosts() -> void:
      var i := 0
      for ghost in ghosts:
          respawn_personality_ghost(ghost, i)
          i += 1
  ```

#### FC-5 — `target_for(ghost) -> Vector2i`
- **Mirrors**: morning chunk #5 (`func` with parameter) + return-a-value from chunk #6.
- **Goal**: return the tile this ghost is aiming for, based on its personality.
- **Pre-given helpers**: `blinky_target / pinky_target / inky_target / clyde_target` each do the targeting math.
- **As-typed code**:
  ```gdscript
  func target_for(ghost) -> Vector2i:
      var p = ghost.get_meta("personality")
      if p == BLINKY:
          return blinky_target(ghost)
      if p == PINKY:
          return pinky_target(ghost)
      if p == INKY:
          return inky_target(ghost)
      return clyde_target(ghost)
  ```

#### FC-6 — `is_clyde_close(ghost) -> bool`
- **Mirrors**: morning chunk #6 (`func` returning bool — `is_even(n)` shape).
- **Goal**: return `true` when the ghost is closer than 8 tiles to the player.
- **Pre-given helper**: `distance_to_player(ghost)` does the distance math.
- **As-typed code**:
  ```gdscript
  func is_clyde_close(ghost) -> bool:
      var d := distance_to_player(ghost)
      return d < 8.0
  ```

### The 4 personalities (for kid-facing slides — context only, NOT code spec)

Used on the FC payoff slide to explain *what* the kid is unlocking. The targeting math is pre-given; these descriptions are for the kid to know *why* the ghosts behave differently. No code prescription.

| Ghost | Colour | What it does in-game |
|---|---|---|
| **Blinky** | Red | Heads straight for the player. Most aggressive. |
| **Pinky** | Pink | Aims ahead of the player to ambush. |
| **Inky** | Cyan | Uses Blinky's position to flank from the opposite side. |
| **Clyde** | Orange | Chases when far. Scatters to the bottom-left corner when close. |

---

## 8. Asset / atlas reference

- **Pack**: Kenney **Tiny Dungeon** — kenney.nl, CC0 (no attribution required).
- **Atlas**: `assets/Tilemap/tilemap_packed.png`, 16 × 16 per tile, no margin / separation.
- **Exploded tiles**: `assets/Tiles/tile_NNNN.png` (per-tile PNGs) — present for swap/reference but the TileSet uses the atlas form.
- **TileSet resource**: `PacmanTileSet.tres` — every non-empty 16×16 region in the atlas is registered as a tile.
- **Painted in the scaffold**:
  - **Walls**: source_id `4`, atlas coord `(0, 3)` — stone-block / brick tile.
  - **Dots**: source_id `8`, atlas coord `(0, 9)` — pellet substitute (coin/gem variant from the atlas).
- **Acceptable dot substitutes** (kid-personalization — slides should show these 3 atlas locations as a row):
  - **Coin** — small round yellow tile.
  - **Gem** — small blue/green diamond.
  - **Heart** — small red heart tile.
  - (Any tile works — `count_dots()` only checks for tile presence, not which tile.)
- **Resolution**: 448 × 496 px playfield (28 × 31 tiles × 16 px), plus UI overlay.

---

## 9. Verification checklist (re-run if code changes)

- [x] All 7 `#@todo` blocks in `main.gd` mapped to chunk rows in §3 (TODO #1, #2, #3a, #3b, #4, #5, #6).
- [x] All 6 `#@todo` blocks in `ghost_personalities.gd` documented in §7 (FC-1 through FC-6).
- [x] As-typed code blocks byte-identical to source between `#@todo`/`#@end` markers.
- [x] Scene tree in §2 matches `Main.tscn` node names + types.
- [x] Asset reference (§8) atlas path matches `PacmanTileSet.tres` (`res://assets/Tilemap/tilemap_packed.png`).
- [x] Constants table (§2) matches `main.gd` lines 18-34 (includes `PERSONALITY_MODE_ENABLED`).
- [x] Narrative arc card (§1) matches BIBLE §15 universal narrative arc memory (Pac-Man = 1980 = Namco).
- [x] Chunk order in §3 + §5 matches BIBLE §4 D2 order.
- [x] No "stretch" tag on any morning chunk (R1 — locked 2026-05-29).
- [x] No nested function calls, no chained method calls in any kid TODO line (R2 D1-D2 ceiling).
- [x] No predicate-chain composition in pre-given helpers or kid scaffolding (R4).
- [x] Chunk #6 ships as R5 partial-section hole (off-grid + tunnel pre-given, kid writes only in-grid query).
- [x] TODO comments state outcome, not pattern (R6) — multiple valid implementations should pass.
- [x] §7 Final Challenge ships the R3 pointer slide content (FC TODO → morning chunk mirror map).
- [x] Each walkthrough (Pre-coding setup + Personalization + FC) appears exactly once at its lesson position.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 2." Output should require no follow-up clarification.

---

## 10. Slide blueprint (DRAFT — summary level, Phase 2.5 in progress, 2026-05-29)

> **Status**: structural draft. Order + content topics + metaphors are locked at this level. Per-slide expansion (matching D1 §10 schema verbatim — title / body / image / notes per slide) is the next pass, gated on:
> (a) Per-chunk RHS prose goal statement options (pending user pick — options to follow in chat).
> (b) Historical-context slide content sourcing for Pac-Man (1980 revolutionary background).
> (c) Day tab color for D2 (pending brand pack).
>
> The python-pptx build chat should NOT consume this draft. Per-slide expansion pass must land first.

### 10.0 Decisions locked for D2

Carried forward from BIBLE §TODO (locked 2026-05-26 / -27) plus user picks 2026-05-28 / -29:

- **Two new concepts today** per BIBLE §4 Concept Map: **Loops** + **Functions**. Chunks #2 / #3 / #5 / #6 are variants of these two umbrellas, not separate new concepts. Boolean is a D1 refresher only.
- **Source of truth for board examples + in-file code + as-typed code**: §3 chunk table + §5 lesson chunks of THIS file. Slides reference §5 verbatim — no new code invented at slide-author time.
- **Side-by-side slide composition for every chunk**:
  - **LHS**: board example (verbatim from §5).
  - **RHS top**: prose goal statement, plain English — "what we want to happen" (not algorithmic, not step-by-step; goal-level). Options pending user pick.
  - **RHS bottom**: Godot screenshot of `#@todo` block with red overlay.
- **Locked metaphors**:
  - for-range → **climbing stairs to your bedroom** (known count, 14 stairs, one repeated motion).
  - while → **climbing stairs in the dark** (unknown count, same motion, stop when foot doesn't find another stair). Direct callback to for-range stairs for max contrast.
  - function → **pizza order** (say `margherita`, kitchen makes margherita; define recipe once, call name many times).
  - parameter → **pizza extends** (`margherita("large")` vs `margherita("small")` — same recipe, different input).
  - return → **pizza extends** (kitchen hands the pizza BACK; `var dinner = margherita("large")` — dinner IS the pizza).
  - boolean → **D1 light-switch callback only** (1-slide refresher in chunk #6, not a fresh teach).
- **Walkthroughs A / B / C / D for already-taught Day 1 flows** = **2-slide jog-memory pack each** (8 slides total across all four). Pattern per pack:
  1. **Challenge slide**: "Do this the same way you did yesterday." Kid struggles for a moment, tries to remember.
  2. **Hint slide**: text + arrows only, no screenshots — e.g. `FileSystem → main.gd → double-click`. Memory jog for kids who blanked.
- **Walkthrough T (TileMap)** is NEW today — full walkthrough with screenshots (8 slides: 2 concept + 6 click steps).
- **Historical-context slide added to opener pack** — Pac-Man's revolutionary status (1980, invented maze chase, first character-with-personality, first cutscenes, first arcade game marketed beyond young men, etc.). Equivalent slide retrofitted to D1 Pong opener in a later pass (D1 SLIDE_SOURCE.md edit, deferred).

### 10.1 Opener pack (~7 slides)

1. Welcome / day title — "Day 2 — Pac-Man · 1980 · Namco"
2. Today we'll build — finished Pac-Man screenshot + 1-line pitch
3. **Why Pac-Man was revolutionary** (NEW) — historical context: pre-Pac-Man arcade was almost all space shooters. Pac-Man invented the maze chase, the character-with-personality, the cutscene, the merchandising tie-in. First arcade game massively marketed beyond young men. Without it: no Mario, no Sonic, no character mascots.
4. Yesterday → Today — Pong recap (vars + conditions) → today adds Loops + Functions
5. 5-day arc timeline — Day 2 highlighted, Day 1 ticked
6. Today's concepts — **Loops** + **Functions** (the two)
7. GDScript vs Python — 4-pattern side-by-side (for-range, for-each, while, `def` → `func`)

### 10.2 Pre-coding setup (~12 slides)

- Section divider — "Pre-coding setup"
- **Walk A — Open the Day 2 project (jog-memory, 2 slides)**:
  1. Challenge: "Open the Day 2 Maze project the same way you did yesterday."
  2. Hint (text + arrows, no screenshots): `Godot launcher → Import → Day2_Maze_Game/project.godot → Import & Edit`
- **Walk B — Open main.gd (jog-memory, 2 slides)**:
  1. Challenge: "Open `main.gd` and switch to the Script editor."
  2. Hint: `FileSystem panel → main.gd → double-click → Script editor`
- **Walkthrough T — TileMap orientation (NEW, full ~8 slides)**:
  - 2 concept slides — TileSet (palette) vs TileMapLayer (canvas); today's two layers Walls + Dots share the same TileSet; kid's API surface is `wall_layer.get_cell_source_id(cell)`
  - 6 click-step slides — click Walls → Inspector Tile Set → Edit → TileSet panel opens → click source row → atlas chops appear → back to 2D button

### 10.3 Lesson chunks

- Section divider — "Lesson chunks"

#### Chunk #1 — `for i in range(N)` (FULL ARC, ~11 slides)
- **Concept root (4 slides)**: word "loop" + meaning prompt ("what does *loop* mean? roller coaster, rope") + root ("loop = repeating") + shape (G10 board ex `for i in range(3): print(i)`)
- **Example/metaphor (3-4 slides)**: **stairs to your bedroom** — 14 stairs, you know the count, one motion repeated; question slide ("how many runs for `range(5)`?"); trick slide ("`range(0)`?"); takeaway
- **How-it's-used (2 slides)**: games general (spawn 50 trees / 12 enemies / 4 ghost eyes) + Pac-Man (spawn 3 ghosts in pen)
- **Where-in-our-game (1 slide)**: screenshot main.gd:63-66 with red overlay on the `#@todo` gap inside `_ready()`
- **Side-by-side (1, MANDATORY)**:
  - **LHS**: `for i in range(3):` / `    print(i)` (verbatim §5 board ex)
  - **RHS top**: PROSE GOAL — *pending pick (options to follow)*
  - **RHS bottom**: `d2_chunk1_todo.png` — main.gd:63-66 red overlay
- **No after-works** (payoff deferred to chunk #2)

#### Walk C — Run the project (jog-memory, 2 slides)
1. Challenge: "Run your game."
2. Hint: `F5 → Set Main Scene? → Select Current → game window opens → F8 to stop`

#### Walk D — Reading an error (jog-memory, 2 slides)
1. Challenge: "Game didn't open? Find the error."
2. Hint: `Output panel → click blue line number → fix → Ctrl+S → F5 again`

#### Chunk #2 — `for item in list` (PURE SLIM, 3 slides)
- **Recap (1 slide)**: "Same `for` keyword. New shape. Last time you wrote a number after `range`. This time you write the name of a thing you already have."
- **Side-by-side (1, MANDATORY)**:
  - **LHS**: `for colour in ["red", "green", "blue"]:` / `    print(colour)` (verbatim §5)
  - **RHS top**: PROSE GOAL — *pending pick*
  - **RHS bottom**: `d2_chunk2_todo.png` — main.gd:102-105 red overlay
- **After-works (1 slide)**: "Ghosts patrol!" — running screenshot post 2-sec release. First big visible payoff of the day.

#### Chunk #3 — `while` (SMALL-ARC + dual hole, ~13 slides)
- **Recap-bridge (1 slide)**: "Loops have a cousin: `while`."
- **Concept root (3 slides)**: word "while" = "as long as" + plain-English meaning + shape (G10 board ex `var n := 0; while n < 5: print(n); n += 1`)
- **For-vs-while disambiguator (1 slide, LOAD-BEARING)**: `for` = you KNOW the count (yesterday, 14 stairs to your bedroom). `while` = you DON'T know (tonight, stairs in the dark). Same motion. Different stopping rule.
- **Example/metaphor (2-3 slides)**: **stairs in the dark** — step up, step up, stop when foot doesn't find another stair; question slide (how many runs for `n := 3; while n > 0: print(n); n -= 1`?); takeaway
- **How-it's-used (2 slides)**: games general (scan grid / count coins / fall until ground) + Pac-Man (scan all 28 × 31 = 868 tiles, count dots, that's the win target)
- **Where-in-our-game (2 slides)**: caller location (main.gd:70-72) + body location (main.gd:202-214)
- **Side-by-side TWO holes (2 slides, paired)**:
  - **3a (caller)**: LHS `dots_remaining = count_dots()`. RHS top = PROSE GOAL — *pending pick*. RHS bottom = `d2_chunk3a_todo.png` main.gd:70-72.
  - **3b (body)**: LHS `var n := 0; while n < 5: print(n); n += 1` (verbatim §5). RHS top = PROSE GOAL — *pending pick*. RHS bottom = `d2_chunk3b_todo.png` main.gd:202-214.
- **No after-works** (count_dots produces invisible number; payoff is implicit in win-condition existence)

#### Chunk #4 — `func` no params (FULL ARC, ~12 slides)
- **Concept root (4 slides)**: word "function" — "what's the FUNCTION of a remote? a calculator? a door?" → "the thing it DOES." Function = a NAMED block of code. Shape (G10 `func say_hi(): print("hi!")` + 2 calls)
- **Example/metaphor (3 slides)**: **pizza order** — say `margherita`, kitchen makes margherita pizza; recipe (cheese + tomato + basil + bake) defined behind counter once, called by name many times. Question slide ("how many `hi!`s if we call `say_hi()` three times?"). Takeaway.
- **How-it's-used (2 slides)**: games general (`jump()` / `die()` / `spawn_enemy()` — define once, call from many places, no copy-paste) + Pac-Man (ghost catches player → recipe is `reset_player()`)
- **Where-in-our-game (1 slide)**: screenshot main.gd:132-139 with red overlay on the gap
- **Side-by-side (1, MANDATORY)**:
  - **LHS**: `func say_hi():` / `    print("hi!")` (verbatim §5 board ex)
  - **RHS top**: PROSE GOAL — *pending pick*
  - **RHS bottom**: `d2_chunk4_todo.png` — main.gd:132-139 red overlay
- **After-works (1 slide)**: "Ghost catches you → respawn!" — before/after screenshot pair

#### Chunk #5 — `func` with a parameter (SMALL-ARC, ~9 slides)
- **Recap-bridge (1 slide)**: "Functions can take INPUTS. Same `func`. Now there's something between the parentheses."
- **Concept root (3 slides)**: word "parameter" — info you HAND TO the function when you call it. Shape (G10 board ex `func add_points(amount): score += amount`).
- **Example/metaphor (2 slides)**: **pizza extends** — `margherita("large")` vs `margherita("small")`. Same recipe, different input → different output. Takeaway.
- **How-it's-used (1 slide, Pac-Man)**: `move_player(direction)` — direction is the parameter; player moves wherever the arrow key points.
- **Where-in-our-game (1 slide)**: screenshot main.gd:154-162, highlight `direction: Vector2i` in the signature
- **Side-by-side (1, MANDATORY)**:
  - **LHS**: `func add_points(amount):` / `    score += amount` (verbatim §5)
  - **RHS top**: PROSE GOAL — *pending pick*
  - **RHS bottom**: `d2_chunk5_todo.png` — main.gd:154-162 red overlay
- **After-works (1 slide)**: "Arrow keys move the player!" — player mid-tile slide screenshot

#### Chunk #6 — `func` returning a bool (SMALL-ARC + boolean refresher, ~10 slides)
- **Recap-bridge (1 slide)**: "Functions can HAND BACK an answer. That answer has a name: the **return value**."
- **Concept root (3 slides)**: word "`return`" — function hands X back to the caller. Shape (G10 board ex `func double(n): return n * 2` + `var y = double(5)` → y is 10).
- **Boolean refresher (1 slide, D1 CALLBACK)**: "Remember booleans from yesterday? Light switch — true or false. Today our function hands back a true/false answer."
- **Example/metaphor (2 slides)**: **pizza extends** — kitchen doesn't just MAKE the pizza, it HANDS IT BACK. The pizza IS the return value. `var dinner = margherita("large")` → dinner IS the pizza. Takeaway.
- **How-it's-used (1 slide, games)**: yes/no checks everywhere — `hit_wall(cell)` / `is_alive()` / `in_range(target)`. Every check returns bool.
- **How-it's-used (1 slide, Pac-Man)**: `hit_wall(cell)` — the player asks the Walls layer: "is there a wall here?" Walls answers true or false.
- **Where-in-our-game (1 slide)**: screenshot main.gd:172-180, highlight `-> bool` in the signature
- **Side-by-side (1, MANDATORY)**:
  - **LHS**: `func is_even(n) -> bool:` / `    return n % 2 == 0` (verbatim §5)
  - **RHS top**: PROSE GOAL — *pending pick*
  - **RHS bottom**: `d2_chunk6_todo.png` — main.gd:172-180 red overlay
- **After-works (1 slide)**: "The maze is alive!" — full-play screenshot. Walls block, tunnel wraps, ghosts patrol, dots chompable. End-of-morning celebration moment.

### 10.4 Remaining sections — STUB (deferred to Phase 2.5b)

Mirror D1 §10.17 sub-sectioning when authored:

- **§10.4a** Section divider — Personalization. 7 beats from §6. Estimated ~25-30 slides.
- **§10.4b** Section divider — Final Challenge (`ghost_personalities.gd`). Required first slide: **R3 pointer slide** (FC TODO → morning chunk mirror map, exact text in §7 above). Then: 4 personality flavor cards (Blinky / Pinky / Inky / Clyde) framed as *what each ghost does in-game* — not as targeting math. Then: 6 hole packs (FC-1 through FC-6) each pointing back to its mirrored morning chunk before showing the new context. The math is pre-given so the slide pack is leaner than v1. Estimated ~25-30 slides.
- **§10.4c** Asset recap — Kenney Tiny Dungeon atlas card (G08). Estimated ~3-5 slides.
- **§10.4d** Export-to-exe walkthrough (Beat 6 of §6). Estimated ~6-8 slides.
- **§10.4e** Day closer — "Tomorrow: Tower Defense." Estimated ~1-2 slides.

### 10.5 Build-time notes for python-pptx chat (placeholder)

- **Master frame**: iCode logo top-left, day tab top-right (D2 = TBD color, awaiting brand pack), page-number bottom-right per `SLIDES_FORMATS.md` master frame spec.
- **Walkthrough step badges**: G12 slides with step IDs (e.g. "T.1") render the badge as a small filled circle top-right of the screenshot.
- **Red highlight overlays**: described per-slide in `Image:` field, default 4px-stroke red rectangle.
- **Speaker notes**: `Notes:` field per slide populated into the PPTX speaker-notes pane.
- **Lesson-portion slide count (draft estimate)**: ~85-90 slides. Locked once per-slide expansion pass is done.
- **Verification before build**: re-run §9 checklist. If `main.gd` line numbers shift, screenshots + line-reference body text must update.

### 10.6 RHS prose-goal options (pending user pick)

Per chunk, three options for the plain-English goal statement that sits ABOVE the Godot `#@todo` screenshot on the side-by-side slide. Goal-statement tone — what you'd tell a person if you wanted them to make this happen. Not algorithmic. Not step-by-step.

**Note (2026-05-29)**: re-verification + R1-R6 remediation done 2026-05-29 afternoon. RHS code columns below have been refreshed to match the rewritten `main.gd`. Chunks #1, #3b, #5 now route through pre-given helpers (`ghost_spawn_pos`, `cell_has_dot`, `step_player_to`) so each kid line is single-purpose. Chunk #6 is now an R5 partial-section hole — RHS table shows only what the kid types between `#@todo`/`#@end`. Prose options A/B/C are unchanged; pick at slide-build time.

#### Chunk #1 — `for i in range(N)` — spawn 3 ghosts

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| `for i in range(3):`<br>`    print(i)` | `for i in range(3):`<br>`    spawn_ghost_at(ghost_spawn_pos(i))` | **A.** Spawn three ghosts in the pen — but write the spawn call only once.<br><br>**B.** Make three ghosts appear in the pen when the game starts.<br><br>**C.** Get three ghosts into the pen at startup, lined up side by side, without copy-pasting. |

#### Chunk #2 — `for item in list` — move every ghost each frame

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| `for colour in ["red", "green", "blue"]:`<br>`    print(colour)` | `for ghost in ghosts:`<br>`    step_ghost(ghost)` | **A.** Every frame, give every ghost a chance to take one step.<br><br>**B.** Each frame, walk through all the ghosts and move each one.<br><br>**C.** Move all the ghosts — not just one — every frame. |

#### Chunk #3a — caller (one-liner)

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| *(paired with 3b — uses the while board ex from 3b)* | `dots_remaining = count_dots()` | **A.** Find out how many dots the maze has, and remember the number.<br><br>**B.** Count the dots so we know what the player has to chomp.<br><br>**C.** Get the dot total from `count_dots()` and store it in `dots_remaining`. |

#### Chunk #3b — body of `count_dots()` (while loop)

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| `var n := 0`<br>`while n < 5:`<br>`    print(n)`<br>`    n += 1` | `func count_dots() -> int:`<br>`    var count := 0`<br>`    var x := 0`<br>`    while x < MAZE_W:`<br>`        var y := 0`<br>`        while y < MAZE_H:`<br>`            if cell_has_dot(x, y):`<br>`                count += 1`<br>`            y += 1`<br>`        x += 1`<br>`    return count` | **A.** Walk every single tile in the maze and count up the ones with a dot on them.<br><br>**B.** Look at every cell in the 28 × 31 grid. Count the dots. Hand the total back.<br><br>**C.** Scan the whole maze. Count the dots. Return the count. |

#### Chunk #4 — `func` no params — `reset_player()`

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| `func say_hi():`<br>`    print("hi!")` | `func reset_player() -> void:`<br>`    player_cell = PLAYER_START`<br>`    player.position = cell_to_world(player_cell)`<br>`    player_moving = false`<br>`    current_dir = Vector2i.ZERO`<br>`    queued_dir = Vector2i.ZERO` | **A.** When a ghost catches the player, this is the recipe for un-doing the damage: send them home with a clean slate.<br><br>**B.** Send the player back to the starting tile and clear any movement they had going.<br><br>**C.** Reset the player. Position back to start. Movement cleared. Direction wiped. |

#### Chunk #5 — `func` with parameter — `move_player(direction)`

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| `func add_points(amount):`<br>`    score += amount` | `func move_player(direction: Vector2i) -> void:`<br>`    var next_cell := player_cell + direction`<br>`    if hit_wall(next_cell):`<br>`        return`<br>`    next_cell = wrap_cell(next_cell)`<br>`    step_player_to(next_cell)` | **A.** Move the player one tile in the direction they pressed — but only if a wall isn't in the way.<br><br>**B.** Take one step in the given direction. Wall in front? Don't move. Tunnel edge? Wrap to the other side.<br><br>**C.** Given a direction, try to slide the player there. Bounce off walls. Wrap through tunnels. |

#### Chunk #6 — `func` returning bool — `hit_wall(cell)`

| LHS board (pattern) | RHS code (kid types) | Prose goal options (RHS top) |
|---|---|---|
| `func is_even(n) -> bool:`<br>`    return n % 2 == 0` | *(R5 partial-section hole — kid only types between `#@todo`/`#@end`)*<br>`var source_id := wall_layer.get_cell_source_id(cell)`<br>`return source_id != -1` | **A.** Answer the question: is this tile a wall, or can we walk through it?<br><br>**B.** Given a cell, hand back `true` if it's blocked, `false` if it's open. *(The off-grid + tunnel cases are pre-given for you.)*<br><br>**C.** Decide whether a tile blocks movement. Walls block. Open floor doesn't. *(Pre-given guards handle off-grid + tunnel rows.)* |

### 10.7 Pending decisions (blocking per-slide expansion)

- [x] **As-typed code re-verification** — done 2026-05-29 afternoon under R1-R6 triage. `main.gd` rewritten; pre-given helpers added; chunk #6 converted to R5 partial-section hole; FC redesigned to ship with pre-given personality math. §5 + §10.6 RHS code columns refreshed to match.
- [ ] **RHS prose pick (per chunk)** — A / B / C / remix for each of #1, #2, #3a, #3b, #4, #5, #6. No longer blocked.
- [ ] **Historical-context slide content** — Pac-Man 1980 revolutionary background. Sourcing pending.
- [ ] **Day tab color for D2** — brand pack pending.
- [ ] **D1 retrofit** — add equivalent historical-context slide to D1 Pong opener pack (currently 5-slide pack per D1 §10.1; would become 6).
- [ ] **FC pointer slide content authored** — first slide of §10.4b. Text locked in §7 above; per-slide expansion still pending Phase 2.5b.
