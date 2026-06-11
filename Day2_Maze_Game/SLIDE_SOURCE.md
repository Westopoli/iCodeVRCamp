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

### 10.1 SLIDE BUILDER REFERENCE — read this before generating slides (added 2026-05-30)

> **AI consuming this doc to generate slides: this section is the spec for how to render each Action slide. Read carefully — the LHS/RHS layout has a precise meaning.**
>
> *(Identical block also lives in D3 SLIDE_SOURCE.md §10.1. Retrofitted to D2 for consistency.)*

For every **side-by-side Action slide** in §10.4 onward (one per kid chunk):

| Slide region | What it contains | Source |
|---|---|---|
| **Top (title + body)** | R6 prose instruction — what the kid should produce, in input → output / observable-effect terms. Reads as a goal statement, not pseudo-code. | This doc's per-chunk "RHS top prose goal" field (§10.7 below for D2, baked into chunk arcs for D3). |
| **LHS pane** | Literal code shown as a code block (or rendered code image). The board example pattern the kid will adapt. | This doc's per-chunk "Board example" field. Verbatim from §5. |
| **RHS pane** | **A SCREENSHOT of the Godot script editor** zoomed in on the chunk's location in `main.gd`. The kid `#@todo` region has a **red 4px-stroke rectangular overlay** marking the area the kid will edit. **THIS IS NOT A CODE LISTING OF WHAT THE KID TYPES.** It's a visual locator — "here is the section of `main.gd` you'll be editing." | Per-chunk file location from §3 chunk table. |
| **Speaker notes** | The R6 prose + metaphor framing + any quiz answers. Populated into the PPTX speaker-notes pane, not visible to the kid on screen. | Per-chunk content from §5 / §10. |

**Why this matters**: the kid is meant to look at the RHS, switch to Godot, find that region, and type their solution into the real script. The slide is a wayfinder, not a transcription target. If the RHS shows finished code, kids will copy character-by-character and miss the lesson. Earlier drafts of this doc occasionally said "RHS: code" — that wording was loose. The locked spec is **RHS = screenshot with overlay**. The "as-typed code" listed in §5 of this doc is **REFERENCE for the Complete build verification**, not slide content.

Other render rules:

- **R5 partial-hole action slides** (D2 chunk #6 `hit_wall`): the RHS Godot screenshot uses a **two-tone overlay**. Pre-given lines (off-grid + tunnel guards) get a **gray semi-transparent overlay**. The kid hole (in-grid wall query) gets the standard red overlay. The slide caption explicitly says "gray = already written for you; red = your hole."
- **Walkthrough hint slides** (Walk A/B/C/D and Walk T): text + arrows only. No screenshots in the Hint slide of jog-memory packs.
- **Concept-root metaphor slides** (stairs to bedroom, pizza order): full-bleed metaphor imagery centered, body text under image. Not LHS/RHS layout — these are explanatory, not actionable.

---

### 10.2 Opener pack (slides S001–S007)

> **Insert note (2026-06-09):** Per-slide expansion complete for opener + pre-coding + chunks #1–#6 (D2-S001–D2-S086). §10.5 (personalization / FC / export / closer) deferred to Phase 2.5b. Guide-canonical image names used throughout (D2C1–D2C6, D2TileSet1–2, D2Pacman1–2). No ad-hoc `d2_*` names.

#### Slide D2-S001 — Day title
- Format: G01 Day Title
- Title: "VR Creator - Day 2"
- Body:
- Image: `D2Pacman1.png` — 1980 Pac-Man arcade cabinet (placeholder OK). No red overlay.
- Notes: Read the title aloud. Point to the year.

#### Slide D2-S002 — Today we're building Pac-Man
- Format: G12 Screenshot + Caption
- Title: "Today we're building Pac-Man"
- Body: "Dots to chomp. Ghosts to dodge. A tunnel that wraps. Every visible thing on screen is a tile painted on a grid — and the code you'll write moves the player and spawns the ghosts."
- Image: `D2Pacman2.png` — classic Pac-Man maze in-game screenshot. No red overlay.
- Notes: —

#### Slide D2-S003 — Why Pac-Man was revolutionary
- Format: G05 Concept Explanation
- Title: "Why Pac-Man changed everything (1980)"
- Body:
  - Pre-1980 arcades = almost all space shooters (Space Invaders, Asteroids). Pac-Man **invented the maze chase**.
  - First game with a **character that had personality** — Pac-Man + 4 named ghosts (Blinky, Pinky, Inky, Clyde), each its own AI brain.
  - First game with **cutscenes** (the intermissions between levels).
  - First arcade game marketed **beyond boys** — broke the "arcade = boys only" mold.
  - First giant **merchandising wave** — lunchboxes, a cartoon, a hit song ("Pac-Man Fever").
  - Bottom line: no Pac-Man → maybe no Mario, no Sonic, no character mascots at all.
- Image: none
- Notes: "No other game launched as many imitators as fast. When you write a loop to spawn 3 ghosts today — you're writing Pac-Man's DNA."

#### Slide D2-S004 — Yesterday → Today
- Format: G05 Concept Explanation
- Title: "Yesterday → Today"
- Body:
  - **Day 1** — Variables + Conditions. You named things and made choices.
  - **Day 2** — **Loops + Functions**. You repeat things and package code into reusable recipes.
  - Same `var`, same `if`. Two new tools on top.
- Image: none
- Notes: —

#### Slide D2-S005 — 5-day arc timeline
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body: horizontal 5-step strip, left-to-right, today's box highlighted in iCode red, Day 1 ticked:
  - Day 1 ✓ Pong — Vars + Conditions
  - **Day 2 ← Pac-Man — Loops + Functions**
  - Day 3 Tower Defense — Lists + Objects (preview)
  - Day 4 Fighter — Objects deep
  - Day 5 VR Escape Room — Showcase
- Image: rendered timeline strip (python-pptx draws as 5 rectangles; today = iCode red, others light grey).
- Notes: "Two new ideas today. Everything else builds on what you already know."

#### Slide D2-S006 — Today's concepts
- Format: G04 Headline / Divider
- Title: "Today's concepts: Loops + Functions"
- Body:
  - **Loops** — make the same code run again and again (spawn 3 ghosts, move every ghost, scan 868 tiles).
  - **Functions** — give a block of code a name, call it whenever you need it.
- Image: none
- Notes: Two umbrellas only. All 6 chunks today live under one of these two.

#### Slide D2-S007 — GDScript vs Python
- Format: G03 GDScript vs Python
- Title: "GDScript is Python — except one word"
- Body:
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
- Image: none
- Notes: "Day 2 GDScript is **identical** to Python except one word: `def` becomes `func`. If you ever write Python later, you already know today's code."

### 10.3 Pre-coding setup (slides S008–S020)

#### Slide D2-S008 — Section divider: Pre-coding setup
- Format: G04 Headline / Divider
- Title: "Pre-coding setup"
- Body:
- Image: none
- Notes: —

#### Slide D2-S009 — Walk A.1: Open the Day 2 project (Challenge)
- Format: G04 Headline / Divider
- Title: "Open the Day 2 Maze project"
- Body: "Open the Day 2 Maze project the same way you did yesterday."
- Image: none
- Notes: Let kids try from memory. ~30 seconds before hint.

#### Slide D2-S010 — Walk A.2: Open the Day 2 project (Hint)
- Format: G05 Concept Explanation
- Title: "Walk A — Hint"
- Body:
  - `Godot Launcher` → `Import` button
  - Navigate to `Day2_Maze_Game/project.godot`
  - Click **Import & Edit**
- Image: none
- Notes: Text + arrows only. No screenshot — kids are jogging Day 1 memory.

#### Slide D2-S011 — Walk B.1: Open main.gd (Challenge)
- Format: G04 Headline / Divider
- Title: "Open main.gd"
- Body: "Open `main.gd` and switch to the Script editor — same way as yesterday."
- Image: none
- Notes: Let kids try.

#### Slide D2-S012 — Walk B.2: Open main.gd (Hint)
- Format: G05 Concept Explanation
- Title: "Walk B — Hint"
- Body:
  - `FileSystem` panel (bottom-left) → find `main.gd`
  - Double-click → Script editor opens
- Image: none
- Notes: —

#### Slide D2-S013 — Walk T — TileMap concept 1/2: TileSet vs TileMapLayer
- Format: G05 Concept Explanation
- Title: "New today: TileSet and TileMapLayer"
- Body:
  - **TileSet** = the **palette**. A resource file that chops the Kenney atlas PNG into named 16×16 tiles.
  - **TileMapLayer** = a **node** in the scene that paints tiles from the TileSet onto a 2D grid.
  - Think: TileSet = the box of crayons. TileMapLayer = the coloring page.
- Image: none
- Notes: "You don't write TileSet code — it's already set up. Your code just asks the layer 'is there a wall here?'"

#### Slide D2-S014 — Walk T — TileMap concept 2/2: Two layers today
- Format: G05 Concept Explanation
- Title: "Two layers share one TileSet"
- Body:
  - `Walls` layer — collision tiles that block movement.
  - `Dots` layer — the pellets to chomp.
  - Both layers use the **same TileSet** palette. Two painted canvases, one box of crayons.
  - Your chunk #6 call: `wall_layer.get_cell_source_id(cell)` → returns tile ID or `-1` if empty.
- Image: none
- Notes: "That one call is the ONLY TileSet line the kid writes today."

#### Slide D2-S015 — Walk T.1: Click the Walls node
- Format: G12 Screenshot + Caption
- Title: "Step T.1 — Click the Walls node"
- Body: "In the **Scene** panel (top-left), find the `Walls` node and click it."
- Image: `D2TileSet1.png` — Godot TileSet editor open. No red overlay.
- Notes: —

#### Slide D2-S016 — Walk T.2: Inspector → Tile Set → Edit
- Format: G12 Screenshot + Caption
- Title: "Step T.2 — Tile Set property → Edit"
- Body: "In the **Inspector** (right panel), find the **Tile Set** property. Click the resource name → **Edit**."
- Image: `D2TileSet2.png` — Inspector showing TileMapLayer with layer dropdown. No red overlay.
- Notes: —

#### Slide D2-S017 — Walk T.3: TileSet panel opens
- Format: G05 Concept Explanation
- Title: "Step T.3 — TileSet panel at the bottom"
- Body:
  - TileSet panel appears at the **bottom** of the editor.
  - Left side = **Sources** — one source: the Kenney atlas (`tilemap_packed.png`).
- Image: none
- Notes: No screenshot for this step — point at projector live.

#### Slide D2-S018 — Walk T.4: Click source row → atlas chops
- Format: G05 Concept Explanation
- Title: "Step T.4 — Click the source row"
- Body:
  - Click the source row in the Sources list.
  - The atlas appears on the right, **chopped into 16×16 tiles**.
  - Each tile has an ID — that's what `get_cell_source_id()` returns.
- Image: none
- Notes: —

#### Slide D2-S019 — Walk T.5: Kid's API surface
- Format: G10 Code Shape
- Title: "`get_cell_source_id(cell)` — your one TileSet call"
- Body:
  ```gdscript
  # Returns the tile's source ID, or -1 if no tile is painted there.
  var id = wall_layer.get_cell_source_id(cell)
  if id == -1:
      print("open floor")
  ```
- Image: none
- Notes: "This is chunk #6's core. Kids don't need to understand TileSet internals — just this one call."

#### Slide D2-S020 — Walk T.6: Back to 2D view
- Format: G05 Concept Explanation
- Title: "Step T.6 — Back to the 2D view"
- Body:
  - Click the **2D** button at the top of the editor.
  - You've seen the full TileSet pipeline. Now you know what the grid is made of.
- Image: none
- Notes: —

### 10.4 Lesson chunks (slides S021–S086)

#### Slide D2-S021 — Section divider: Lesson chunks
- Format: G04 Headline / Divider
- Title: "Lesson chunks"
- Body:
- Image: none
- Notes: —

---

#### 10.4a Chunk #1 — `for i in range(N)` (slides S022–S032, FULL ARC)

#### Slide D2-S022 — Chunk #1 Concept 1/4: Title
- Format: G04 Headline / Divider
- Title: "Loop"
- Body:
- Image: none
- Notes: Say the word out loud. Pause. "What does *loop* mean to you? Roller coaster? Rope?"

#### Slide D2-S023 — Chunk #1 Concept 2/4: Meaning prompt
- Format: G05 Concept Explanation
- Title: "What does 'loop' mean?"
- Body:
  - Roller coaster loop — the track **comes back around**.
  - A rope tied in a loop — **no beginning, no end**.
  - In code: a **loop = code that repeats**.
- Image: none
- Notes: Take answers. Land on "repeating" as the core idea.

#### Slide D2-S024 — Chunk #1 Concept 3/4: Loop = repeating
- Format: G05 Concept Explanation
- Title: "A loop runs the same code again and again"
- Body:
  - You write the action **once**.
  - The loop runs it as many times as you say.
  - No copy-paste. No 50 lines of the same thing.
- Image: none
- Notes: —

#### Slide D2-S025 — Chunk #1 Concept 4/4: Code shape
- Format: G10 Code Shape
- Title: "`for i in range(3):` — the shape"
- Body:
  ```gdscript
  for i in range(3):
      print(i)
  # prints: 0  1  2
  ```
- Image: none
- Notes: "for i in range 3: print i. i starts at 0, goes to 2. The block runs 3 times."

#### Slide D2-S026 — Chunk #1 Example 1/3: Stairs to your bedroom
- Format: G05 Concept Explanation
- Title: "14 stairs to your bedroom"
- Body:
  - Every night: step, step, step — **14 times**. Same motion. Known count.
  - `for i in range(14):` → `    climb_one_stair()`
  - You know exactly how many stairs. The loop counts for you.
- Image: none
- Notes: "You don't say 'step step step...' 14 times. You say 'go up the stairs.' That's a loop."

#### Slide D2-S027 — Chunk #1 Example 2/3: Question slide
- Format: G04 Headline / Divider
- Title: "How many times does `range(5)` run?"
- Body:
- Image: none
- Notes: Kids answer: 5 times (i = 0, 1, 2, 3, 4). Follow-up: "What's the LAST value of i?" → 4.

#### Slide D2-S028 — Chunk #1 Example 3/3: Takeaway
- Format: G05 Concept Explanation
- Title: "`range(N)` = N runs"
- Body:
  - `range(3)` → runs 3 times (i = 0, 1, 2).
  - `range(10)` → runs 10 times.
  - `range(0)` → runs **zero times** — no stairs to climb.
  - Rule: **`range(N)` gives you N stairs**.
- Image: none
- Notes: range(0) is a fun edge case. "Zero stairs, zero runs. The loop just skips."

#### Slide D2-S029 — Chunk #1 How-it's-used 1/2: Games in general
- Format: G05 Concept Explanation
- Title: "Games loop all the time"
- Body:
  - Spawn **50 trees** in a forest level → `for i in range(50):`
  - Deal **4 cards** at game start → `for i in range(4):`
  - Create **12 enemies** in the first wave → `for i in range(12):`
  - Write the action **once**. The loop handles the rest.
- Image: none
- Notes: —

#### Slide D2-S030 — Chunk #1 How-it's-used 2/2: Pac-Man
- Format: G05 Concept Explanation
- Title: "In our game: spawn 3 ghosts"
- Body:
  - At startup, 3 ghosts need to appear in the pen.
  - Without a loop: write `spawn_ghost_at(...)` three times. Copy-paste.
  - With a loop: write it **once**. `for i in range(3):` handles 3.
- Image: none
- Notes: "If the designer says 'add a 4th ghost' — you change ONE number."

#### Slide D2-S031 — Chunk #1 Where-in-our-game
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — inside `_ready()`"
- Body: "At the `# TODO #1` marker inside `_ready()`. This runs once when the game starts."
- Image: `D2C1.png` — main.gd:69-72, showing `# TODO #1: SPAWN 3 GHOSTS` banner + empty `#@todo`. No red overlay.
- Notes: —

#### Slide D2-S032 — Chunk #1 Side-by-side MANDATORY
- Format: G09 Concept + Task
- Title: "Your task: chunk #1"
- Body LHS (board example):
  ```gdscript
  for i in range(3):
      print(i)
  ```
- Image: `D2C1.png` — main.gd:69-72, red overlay on `#@todo` gap.
- Caption: "Spawn three ghosts in the pen — but write the spawn call only once."
- Notes: Kids type `for i in range(3): spawn_ghost_at(ghost_spawn_pos(i))`. Pre-given helper `ghost_spawn_pos(i)` handles position math — kid line stays single-purpose.

---

#### 10.4b Walk C — Run the project (slides S033–S034, jog-memory)

#### Slide D2-S033 — Walk C.1: Run your game (Challenge)
- Format: G04 Headline / Divider
- Title: "Run your game"
- Body: "Press the same key you used yesterday to start the project."
- Image: none
- Notes: Kids try from memory. ~15 seconds.

#### Slide D2-S034 — Walk C.2: Run your game (Hint)
- Format: G05 Concept Explanation
- Title: "Walk C — Hint"
- Body:
  - Press **F5** → "Set Main Scene?" dialog → **Select Current** → game window opens.
  - Press **F8** to stop.
- Image: none
- Notes: Text only. After chunk #1 typing — first time game runs this session.

---

#### 10.4c Walk D — Reading an error (slides S035–S036, jog-memory)

#### Slide D2-S035 — Walk D.1: Find the error (Challenge)
- Format: G04 Headline / Divider
- Title: "Game didn't open? Find the error."
- Body:
- Image: none
- Notes: Only advance here if kids hit a parse error after typing.

#### Slide D2-S036 — Walk D.2: Find the error (Hint)
- Format: G05 Concept Explanation
- Title: "Walk D — Hint"
- Body:
  - Look at the **Output** panel at the bottom of the editor.
  - Find the error line → click the **blue line number** → editor jumps to it.
  - Fix the typo → **Ctrl+S** → **F5** again.
- Image: none
- Notes: —

---

#### 10.4d Chunk #2 — `for item in list` (slides S037–S039, PURE SLIM)

#### Slide D2-S037 — Chunk #2 Recap
- Format: G05 Concept Explanation
- Title: "Same `for`. New shape."
- Body:
  - Last chunk: `for i in range(3)` — you wrote a **number** after `range`. Known count.
  - This chunk: `for ghost in ghosts` — you write the **name of a list** you already have.
  - The loop visits every item in the list, one by one.
- Image: none
- Notes: "You already have a list called `ghosts`. The loop walks through it."

#### Slide D2-S038 — Chunk #2 Side-by-side MANDATORY
- Format: G09 Concept + Task
- Title: "Your task: chunk #2"
- Body LHS (board example):
  ```gdscript
  for colour in ["red", "green", "blue"]:
      print(colour)
  ```
- Image: `D2C2.png` — main.gd:123-126, red overlay on `#@todo` gap inside the `else` branch.
- Caption: "Each frame, walk through all the ghosts and move each one."
- Notes: Kids type `for ghost in ghosts: step_ghost(ghost)`. Pre-given helper `step_ghost(ghost)` handles movement math.

#### Slide D2-S039 — Chunk #2 After-works: Ghosts patrol!
- Format: G12 Screenshot + Caption
- Title: "Ghosts patrol!"
- Body: "Run the game. After 2 seconds, ghosts start moving."
- Image: none
- Notes: First big visible payoff of the day. Let kids celebrate. "Your loop is running 60 times per second — once per frame."

---

#### 10.4e Chunk #3 — `while` loop (slides S040–S053, SMALL-ARC + dual hole)

#### Slide D2-S040 — Chunk #3 Recap-bridge
- Format: G04 Headline / Divider
- Title: "Loops have a cousin: `while`"
- Body:
- Image: none
- Notes: —

#### Slide D2-S041 — Chunk #3 Concept 1/3: "while"
- Format: G04 Headline / Divider
- Title: "while"
- Body:
- Image: none
- Notes: Say the word. Pause. "What does 'while' mean in plain English?"

#### Slide D2-S042 — Chunk #3 Concept 2/3: Meaning
- Format: G05 Concept Explanation
- Title: "while = as long as"
- Body:
  - "**While** it's raining, stay inside."
  - "**While** there's food on the plate, keep eating."
  - In code: `while` runs the block again and again — **as long as the condition is true**.
- Image: none
- Notes: —

#### Slide D2-S043 — Chunk #3 Concept 3/3: Code shape
- Format: G10 Code Shape
- Title: "`while` — the shape"
- Body:
  ```gdscript
  var n := 0
  while n < 5:
      print(n)
      n += 1
  # prints: 0  1  2  3  4
  ```
- Image: none
- Notes: "n starts at 0. Each run: print n, add 1 to n. Stops when n reaches 5."

#### Slide D2-S044 — Chunk #3 For-vs-while disambiguator (LOAD-BEARING)
- Format: G05 Concept Explanation
- Title: "`for` vs `while` — same stairs, different light"
- Body:
  - **`for`** — you **KNOW** the count. (14 stairs to your bedroom — you've climbed them 1000 times.)
  - **`while`** — you **DON'T** know the count. (Stairs in the dark — step up, stop when your foot finds no stair.)
  - Same repeated motion. Different stopping rule.
- Image: none
- Notes: Load-bearing. Kids who conflate for and while will trip on chunk #3b and FC. Make sure they get the stopping-rule distinction.

#### Slide D2-S045 — Chunk #3 Example 1/3: Stairs in the dark
- Format: G05 Concept Explanation
- Title: "Stairs in the dark"
- Body:
  - Power's out. You're climbing stairs. You can't see the top.
  - Step. Step. Step. Each time: **is there another stair?** Yes → keep going. No → stop.
  - You don't know the count in advance. You stop when the condition is false.
- Image: none
- Notes: "Direct callback to the for-range stairs. Same motion, different stopping rule."

#### Slide D2-S046 — Chunk #3 Example 2/3: Question slide
- Format: G10 Code Shape
- Title: "How many times does this run?"
- Body:
  ```gdscript
  var n := 3
  while n > 0:
      print(n)
      n -= 1
  ```
- Image: none
- Notes: Kids answer: 3 times (n = 3, 2, 1). When n = 0, condition is false, loop stops.

#### Slide D2-S047 — Chunk #3 Example 3/3: Takeaway
- Format: G05 Concept Explanation
- Title: "`while` = keep going until the condition is false"
- Body:
  - `while n < 5:` → stop when n reaches 5.
  - `while lives > 0:` → stop when lives hit 0.
  - `while has_more_dots():` → stop when no dots remain.
- Image: none
- Notes: —

#### Slide D2-S048 — Chunk #3 How-it's-used 1/2: Games in general
- Format: G05 Concept Explanation
- Title: "`while` in games"
- Body:
  - Scan a grid for coins: `while x < map_width:`
  - Fall until you hit the floor: `while not on_ground:`
  - Keep playing until lives run out: `while lives > 0:`
  - Anything where you **don't know the count** in advance.
- Image: none
- Notes: —

#### Slide D2-S049 — Chunk #3 How-it's-used 2/2: Pac-Man dot scan
- Format: G05 Concept Explanation
- Title: "In our game: count every dot"
- Body:
  - The maze is 28 × 31 = **868 tiles**.
  - At startup, count how many tiles have a dot — that's the win target.
  - Scan every column (x) → every row (y) → count the dots.
  - Neither loop knows the tile count in advance → `while`.
- Image: none
- Notes: "When dots_remaining hits 0, the player wins. This setup makes that work."

#### Slide D2-S050 — Chunk #3 Where-in-our-game 1/2: Caller
- Format: G12 Screenshot + Caption
- Title: "Where 3a lives — the caller in `_ready()`"
- Body: "One line in `_ready()`: call `count_dots()` and store the result."
- Image: `D2C3a.png` — main.gd:77-79, showing `# TODO #3a: CALL count_dots()` banner. No red overlay.
- Notes: —

#### Slide D2-S051 — Chunk #3 Where-in-our-game 2/2: Body
- Format: G12 Screenshot + Caption
- Title: "Where 3b lives — the `count_dots()` function"
- Body: "The whole `count_dots()` function body. You'll write the nested `while` loops inside."
- Image: `D2C3b.png` — main.gd:213-225, showing `func count_dots()` signature + empty `#@todo` block. No red overlay.
- Notes: —

#### Slide D2-S052 — Chunk #3a Side-by-side: Caller
- Format: G09 Concept + Task
- Title: "Your task: chunk #3a — the caller"
- Body LHS (board example):
  ```gdscript
  dots_remaining = count_dots()
  ```
- Image: `D2C3a.png` — main.gd:77-79, red overlay on `#@todo` gap.
- Caption: "Get the dot total from `count_dots()` and store it in `dots_remaining`."
- Notes: One line. Kids type `dots_remaining = count_dots()`. This calls the function they'll write next.

#### Slide D2-S053 — Chunk #3b Side-by-side: Body
- Format: G09 Concept + Task
- Title: "Your task: chunk #3b — `count_dots()` body"
- Body LHS (board example):
  ```gdscript
  var n := 0
  while n < 5:
      print(n)
      n += 1
  ```
- Image: `D2C3b.png` — main.gd:213-225, red overlay on `#@todo` gap.
- Caption: "Scan the whole maze with a `while` loop. Count the dots. Return the count."
- Notes: Kids write nested while loops: scan x (0..MAZE_W), scan y (0..MAZE_H), call pre-given `cell_has_dot(x, y)`. Harder chunk — circulate actively.

---

#### 10.4f Chunk #4 — `func` no params (slides S054–S065, FULL ARC)

#### Slide D2-S054 — Chunk #4 Concept 1/4: Title
- Format: G04 Headline / Divider
- Title: "Function"
- Body:
- Image: none
- Notes: Say the word. Pause. "What's the *function* of a remote control?"

#### Slide D2-S055 — Chunk #4 Concept 2/4: Meaning prompt
- Format: G05 Concept Explanation
- Title: "What's the function of…?"
- Body:
  - A **remote control** → change the channel. That's its function.
  - A **calculator** → do math. That's its function.
  - A **door** → let you through (or keep you out). That's its function.
  - Function = **the thing it DOES**.
- Image: none
- Notes: "In code, a function is the same idea — a named block of code that DOES one thing."

#### Slide D2-S056 — Chunk #4 Concept 3/4: Named block of code
- Format: G05 Concept Explanation
- Title: "Function = a name for a block of code"
- Body:
  - `func say_hi():` → defines the function named `say_hi`.
  - `say_hi()` → *calls* it — runs the block.
  - Define the recipe once. Call it any number of times.
- Image: none
- Notes: —

#### Slide D2-S057 — Chunk #4 Concept 4/4: Code shape
- Format: G10 Code Shape
- Title: "`func say_hi():` — the shape"
- Body:
  ```gdscript
  func say_hi():
      print("hi!")

  say_hi()   # → "hi!"
  say_hi()   # → "hi!"
  ```
- Image: none
- Notes: "Two calls, two lines of output. The function body exists only once in the file."

#### Slide D2-S058 — Chunk #4 Example 1/3: Pizza order
- Format: G05 Concept Explanation
- Title: "The pizza order"
- Body:
  - You walk into a pizza shop. You say: **"Margherita."**
  - The kitchen makes dough → adds tomato → adds cheese → bakes → cuts → boxes.
  - You didn't say any of that. You just said the **name**. The recipe ran.
- Image: none
- Notes: "That's a function. You define the recipe once. You call it by name. The kitchen does the work."

#### Slide D2-S059 — Chunk #4 Example 2/3: Question slide
- Format: G04 Headline / Divider
- Title: "How many times does `say_hi()` print if you call it 3 times?"
- Body:
- Image: none
- Notes: Kids answer: 3 times. "The function *definition* doesn't print anything. *Calling* it does."

#### Slide D2-S060 — Chunk #4 Example 3/3: Takeaway
- Format: G05 Concept Explanation
- Title: "Define once. Call anywhere."
- Body:
  - Without functions: copy-paste the same 5 lines every time you need them.
  - With functions: **write once**, call by name from anywhere in the file.
  - Change the recipe once → every call gets the update automatically.
- Image: none
- Notes: —

#### Slide D2-S061 — Chunk #4 How-it's-used 1/2: Games in general
- Format: G05 Concept Explanation
- Title: "Functions are everywhere in games"
- Body:
  - `jump()` — called whenever player presses space.
  - `die()` — called when health hits 0.
  - `spawn_enemy()` — called at the start of each wave.
  - Define once. Call from many places. No copy-paste.
- Image: none
- Notes: —

#### Slide D2-S062 — Chunk #4 How-it's-used 2/2: Pac-Man
- Format: G05 Concept Explanation
- Title: "In our game: `reset_player()`"
- Body:
  - When a ghost catches the player, we need to: send them home, clear movement, wipe direction.
  - That's 5 lines. We wrap them in a function called `reset_player()`.
  - The game calls `reset_player()` every time a ghost catches the player.
- Image: none
- Notes: "One function, many call sites — ghost AI, test resets, future respawn logic."

#### Slide D2-S063 — Chunk #4 Where-in-our-game
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `reset_player()`"
- Body: "The function body is at main.gd:153-160. You'll write the contents."
- Image: `D2C4.png` — main.gd:153-160, showing `func reset_player()` signature + empty `#@todo`. No red overlay.
- Notes: —

#### Slide D2-S064 — Chunk #4 Side-by-side MANDATORY
- Format: G09 Concept + Task
- Title: "Your task: chunk #4"
- Body LHS (board example):
  ```gdscript
  func say_hi():
      print("hi!")
  ```
- Image: `D2C4.png` — main.gd:153-160, red overlay on `#@todo` gap.
- Caption: "Send the player back to the starting tile."
- Notes: Kids write `reset_player()` body: set player_cell, position, player_moving, current_dir, queued_dir. See §5 for exact code.

#### Slide D2-S065 — Chunk #4 After-works: Ghost catches you → respawn!
- Format: G12 Screenshot + Caption
- Title: "Ghost catches you → you respawn!"
- Body: "Run the game. Walk into a ghost. You pop back to the start."
- Image: none
- Notes: "Your function just ran — called from deep inside the ghost collision code."

---

#### 10.4g Chunk #5 — `func` with parameter (slides S066–S075, SMALL-ARC)

#### Slide D2-S066 — Chunk #5 Recap-bridge
- Format: G05 Concept Explanation
- Title: "Functions can take INPUTS"
- Body:
  - Last chunk: `func reset_player()` — no inputs. Same thing every time.
  - This chunk: `func move_player(direction)` — something **between the parentheses**.
  - That thing is called a **parameter** — an input you hand to the function.
- Image: none
- Notes: —

#### Slide D2-S067 — Chunk #5 Concept 1/3: "parameter"
- Format: G04 Headline / Divider
- Title: "Parameter"
- Body:
- Image: none
- Notes: Say the word. "Info you hand to the function when you call it."

#### Slide D2-S068 — Chunk #5 Concept 2/3: Info you hand in
- Format: G05 Concept Explanation
- Title: "A parameter is info you hand to the function"
- Body:
  - `func add_points(amount):` — `amount` is the parameter.
  - Call `add_points(10)` → `amount` is `10` inside the function.
  - Call `add_points(50)` → `amount` is `50`.
  - Same function. Different input each time.
- Image: none
- Notes: —

#### Slide D2-S069 — Chunk #5 Concept 3/3: Code shape
- Format: G10 Code Shape
- Title: "`func add_points(amount):` — the shape"
- Body:
  ```gdscript
  func add_points(amount):
      score += amount

  add_points(10)   # score goes up 10
  add_points(50)   # score goes up 50
  ```
- Image: none
- Notes: "One function definition. Two calls with different amounts."

#### Slide D2-S070 — Chunk #5 Example 1/2: Pizza extends
- Format: G05 Concept Explanation
- Title: "Margherita — large or small?"
- Body:
  - You say: **"Margherita large."** Kitchen runs the same recipe. Big ball of dough.
  - You say: **"Margherita small."** Same recipe. Small ball of dough.
  - The **size** is the parameter. One recipe, different inputs.
- Image: none
- Notes: "Same function. Same steps. The input changes what it does."

#### Slide D2-S071 — Chunk #5 Example 2/2: Takeaway
- Format: G05 Concept Explanation
- Title: "One function. Different inputs each time."
- Body:
  - `move_player(Vector2i.UP)` → moves up.
  - `move_player(Vector2i.DOWN)` → moves down.
  - Same function, called 4 times a second with whatever key is pressed.
- Image: none
- Notes: —

#### Slide D2-S072 — Chunk #5 How-it's-used: Pac-Man
- Format: G05 Concept Explanation
- Title: "In our game: `move_player(direction)`"
- Body:
  - `direction` is the parameter — a `Vector2i` for up, down, left, or right.
  - Arrow key pressed → `direction` is set → `move_player(direction)` is called.
  - The function moves the player one tile in that direction (if no wall is in the way).
- Image: none
- Notes: "The input determines *which* direction. The function decides *whether* to actually move."

#### Slide D2-S073 — Chunk #5 Where-in-our-game
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `move_player(direction)`"
- Body: "Inside `move_player(direction)` at main.gd:171-178. The `direction: Vector2i` in the signature is today's lesson — that's the parameter."
- Image: `D2C5.png` — main.gd:171-178, showing `direction: Vector2i` parameter in the signature. No red overlay.
- Notes: —

#### Slide D2-S074 — Chunk #5 Side-by-side MANDATORY
- Format: G09 Concept + Task
- Title: "Your task: chunk #5"
- Body LHS (board example):
  ```gdscript
  func add_points(amount):
      score += amount
  ```
- Image: `D2C5.png` — main.gd:171-178, red overlay on `#@todo` gap.
- Caption: "Move the player one tile in the direction they pressed — but only if a wall isn't in the way."
- Notes: Kids write `move_player(direction)` body. Pattern: compute next_cell, check `hit_wall`, wrap via `wrap_cell`, move via pre-given `step_player_to`. See §5 for exact code.

#### Slide D2-S075 — Chunk #5 After-works: Arrow keys move!
- Format: G12 Screenshot + Caption
- Title: "Arrow keys move the player!"
- Body: "Run the game. Press arrow keys. Player slides one tile at a time."
- Image: none
- Notes: "Your function is called every time an arrow key is held. The parameter carries the direction."

---

#### 10.4h Chunk #6 — `func` returning a bool (slides S076–S086, SMALL-ARC + boolean refresher)

#### Slide D2-S076 — Chunk #6 Recap-bridge
- Format: G05 Concept Explanation
- Title: "Functions can HAND BACK an answer"
- Body:
  - So far: functions **do** something. `reset_player()` moves the player. `move_player(dir)` slides them.
  - New idea: a function can also **return a value** — hand an answer back to the caller.
  - That answer has a name: the **return value**.
- Image: none
- Notes: —

#### Slide D2-S077 — Chunk #6 Concept 1/3: "return"
- Format: G04 Headline / Divider
- Title: "return"
- Body:
- Image: none
- Notes: Say the word. "Functions can send something back."

#### Slide D2-S078 — Chunk #6 Concept 2/3: Hands back to caller
- Format: G05 Concept Explanation
- Title: "`return` hands a value back to the caller"
- Body:
  - `return` = "here's your answer."
  - The caller gets the value and can use it.
  - `var y = double(5)` → `double` returns 10 → `y` is 10.
- Image: none
- Notes: —

#### Slide D2-S079 — Chunk #6 Concept 3/3: Code shape
- Format: G10 Code Shape
- Title: "`func double(n) -> int:` — the shape"
- Body:
  ```gdscript
  func double(n) -> int:
      return n * 2

  var y = double(5)   # y = 10
  var z = double(3)   # z = 6
  ```
- Image: none
- Notes: "`-> int` means 'this function hands back an int.' `return` is what actually sends it."

#### Slide D2-S080 — Chunk #6 Boolean refresher (D1 callback)
- Format: G05 Concept Explanation
- Title: "Remember booleans from Day 1?"
- Body:
  - A **boolean** is a true/false value — the light switch.
  - `true` = on. `false` = off.
  - Today: our function hands back a **boolean** — "yes this is a wall" or "no it isn't."
- Image: none
- Notes: "One-slide callback. If kids don't remember, don't reteach — just move forward. Context makes it click."

#### Slide D2-S081 — Chunk #6 Example 1/2: Pizza hands back
- Format: G05 Concept Explanation
- Title: "The kitchen hands the pizza BACK"
- Body:
  - Old version: you say "margherita", kitchen makes it. No pizza in your hands.
  - New version: `var dinner = margherita("large")` — kitchen makes it AND **hands it to you**.
  - `dinner` IS the pizza. That's the return value.
- Image: none
- Notes: "Extension of the pizza metaphor. Now the function produces something you can hold."

#### Slide D2-S082 — Chunk #6 Example 2/2: Takeaway
- Format: G05 Concept Explanation
- Title: "`-> bool` = this function answers yes or no"
- Body:
  - `hit_wall(cell) -> bool` — "is there a wall at this cell?"
  - `is_alive() -> bool` — "is the player still alive?"
  - `in_range(target) -> bool` — "is the enemy close enough to shoot?"
  - Every yes/no check in a game is a bool-returning function.
- Image: none
- Notes: —

#### Slide D2-S083 — Chunk #6 How-it's-used: Pac-Man
- Format: G05 Concept Explanation
- Title: "In our game: `hit_wall(cell)`"
- Body:
  - `move_player(direction)` needs to know: "is the next tile a wall?"
  - It calls `hit_wall(next_cell)` → gets back `true` or `false`.
  - If `true` → don't move. If `false` → move.
  - One question. One yes/no answer.
- Image: none
- Notes: "Kids already wrote `move_player`. They used `hit_wall` without knowing it. Now they write it."

#### Slide D2-S084 — Chunk #6 Where-in-our-game
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `hit_wall(cell)` (R5 partial hole)"
- Body: "Inside `hit_wall(cell)` at main.gd:201-204. Off-grid + tunnel guards are pre-given. You write only the in-grid wall query."
- Image: `D2C6.png` — main.gd:201-204, showing the R5 partial-section hole. No red overlay.
- Notes: —

#### Slide D2-S085 — Chunk #6 Side-by-side MANDATORY (R5 partial hole)
- Format: G09 Concept + Task
- Title: "Your task: chunk #6"
- Body LHS (board example):
  ```gdscript
  func is_even(n) -> bool:
      return n % 2 == 0
  ```
- Image: `D2C6.png` — main.gd:201-204. Two-tone overlay: gray = pre-given off-grid + tunnel guards; red = your hole.
- Caption: "Given a cell, hand back `true` if it's blocked, `false` if it's open. *(off-grid + tunnel pre-given)*"
- Notes: R5 partial hole. Kid types only: `var source_id := wall_layer.get_cell_source_id(cell)` + `return source_id != -1`. Gray overlay marks pre-given lines; red marks the hole. Caption flags what's pre-given.

#### Slide D2-S086 — Chunk #6 After-works: The maze is alive!
- Format: G12 Screenshot + Caption
- Title: "The maze is alive!"
- Body: "Run the game. Walls block. Tunnel wraps. Ghosts patrol. Dots are chompable."
- Image: none
- Notes: End-of-morning celebration. All 6 chunks working together. "Every mechanic running right now came from code YOU wrote this morning."

### 10.5 Remaining sections — STUB (deferred to Phase 2.5b)

Mirror D1 §10.17 sub-sectioning when authored:

- **§10.5a** Section divider — Personalization. 7 beats from §6. Estimated ~25-30 slides.
- **§10.5b** Final Challenge (`ghost_personalities.gd`) — **expanded below (slides S087–S098, 12 slides)**.

#### 10.5b Final Challenge (slides S087–S098)

#### Slide D2-S087 — Section divider: Final Challenge
- Format: G04 Headline / Divider
- Title: "Final Challenge"
- Body:
- Image: none
- Notes: —

#### Slide D2-S088 — FC pointer slide (R3 REQUIRED)
- Format: G05 Concept Explanation
- Title: "You already know how to do this."
- Body:
  - Each TODO in `ghost_personalities.gd` mirrors a chunk you wrote this morning. If you get stuck, scroll up to that chunk in `main.gd` and copy the **shape** (not the words).
  - **FC-1** ← Chunk **#1** (`for i in range(N)`)
  - **FC-2** ← Chunk **#2** (`for item in list`)
  - **FC-3** ← Chunk **#3** (`while` loop + count + return)
  - **FC-4** ← Chunk **#4** (`func` no params)
  - **FC-5** ← Chunk **#5** (`func` with a parameter)
  - **FC-6** ← Chunk **#6** (`func` returning a bool)
- Image: none
- Notes: R3 requirement — this slide must appear before any FC hole. Read aloud. Let kids find the mirror chunks in their file before starting.

#### Slide D2-S089 — What you're unlocking
- Format: G12 Screenshot + Caption
- Title: "What you're unlocking"
- Body: "Replace 3 identical ghosts with 4 authentic Pac-Man personalities — Blinky, Pinky, Inky, Clyde. Each one targets the player differently."
- Image: `D2FC3.png` — game running with multiple personality ghosts visible. No red overlay.
- Notes: Show this before the personalities table so kids know the payoff before reading the specs.

#### Slide D2-S090 — The 4 personalities
- Format: G06 Table
- Title: "The 4 personalities"
- Body:
  | Ghost | Colour | What it does |
  |---|---|---|
  | **Blinky** | Red | Heads straight for the player. Most aggressive. |
  | **Pinky** | Pink | Aims 4 tiles ahead of the player to ambush. |
  | **Inky** | Cyan | Uses Blinky's position to flank from the opposite side. |
  | **Clyde** | Orange | Chases when far. Scatters to the corner when close. |
- Image: none
- Notes: "The targeting math is pre-given — you're wiring the personalities together, not computing vectors."

#### Slide D2-S091 — Enable FC step 1: open final_challenge.gd
- Format: G12 Screenshot + Caption
- Title: "Step 1 — Open `final_challenge.gd`"
- Body: "Open `final_challenge.gd`. Find `const FC_ENABLED := false` near the top."
- Image: `D2FC1.png` — `final_challenge.gd` open, showing `const FC_ENABLED := false`. No red overlay.
- Notes: —

#### Slide D2-S092 — Enable FC step 2: flip to true
- Format: G12 Screenshot + Caption
- Title: "Step 2 — Change `false` to `true`"
- Body: "Edit the line to `const FC_ENABLED := true`. Save with Ctrl+S. The personality mode is now live."
- Image: `D2FC2.png` — same line edited to `const FC_ENABLED := true`. No red overlay.
- Notes: "This flips the flag in main.gd's if-branches. All pre-given wiring activates. Now fill the 6 holes."

#### Slide D2-S093 — FC-1 hole: `spawn_personality_ghosts()`
- Format: G09 Concept + Task
- Title: "FC-1 — mirrors Chunk #1"
- Body LHS (board example — morning chunk #1 shape):
  ```gdscript
  for i in range(3):
      print(i)
  ```
- Image: none
- Caption: "Spawn one ghost per personality — use `range(PERSONALITY_COUNT)` and call `spawn_one_personality(i)` each time."
- Notes: Identical shape to morning chunk #1. `spawn_one_personality(i)` is pre-given. Kid writes 2 lines.

#### Slide D2-S094 — FC-2 hole: `step_all_personality_ghosts()`
- Format: G09 Concept + Task
- Title: "FC-2 — mirrors Chunk #2"
- Body LHS (board example — morning chunk #2 shape):
  ```gdscript
  for colour in ["red", "green", "blue"]:
      print(colour)
  ```
- Image: none
- Caption: "Every frame, give every personality ghost one step — loop over `ghosts` and call `step_personality(ghost)`."
- Notes: Literally same shape as morning chunk #2. Kid writes 2 lines.

#### Slide D2-S095 — FC-3 hole: `count_ghosts_of(personality) -> int`
- Format: G09 Concept + Task
- Title: "FC-3 — mirrors Chunk #3"
- Body LHS (board example — morning chunk #3 counter shape):
  ```gdscript
  var n := 0
  while n < 5:
      print(n)
      n += 1
  ```
- Image: none
- Caption: "Count how many ghosts in `ghosts` have the given personality tag. Return the count."
- Notes: Counter pattern from morning #3. For-each or while both accepted (R6 note in §7). `ghost.get_meta("personality")` reads the tag. Kid writes ~5 lines.

#### Slide D2-S096 — FC-4 hole: `reset_personality_ghosts()`
- Format: G09 Concept + Task
- Title: "FC-4 — mirrors Chunk #4"
- Body LHS (board example — morning chunk #4 shape):
  ```gdscript
  func say_hi():
      print("hi!")
  ```
- Image: none
- Caption: "Send every personality ghost back to the pen. Loop over `ghosts` with an index counter and call `respawn_personality_ghost(ghost, i)`."
- Notes: Reset pattern from morning #4. Pre-given `respawn_personality_ghost(ghost, i)` handles one ghost. Kid writes ~4 lines (for-each + index counter).

#### Slide D2-S097 — FC-5 hole: `target_for(ghost) -> Vector2i`
- Format: G09 Concept + Task
- Title: "FC-5 — mirrors Chunk #5"
- Body LHS (board example — morning chunk #5 shape):
  ```gdscript
  func add_points(amount):
      score += amount
  ```
- Image: none
- Caption: "Given a ghost, return its target tile. Read its personality, then return the right pre-given target helper."
- Notes: func-with-param + return. Pre-given helpers: `blinky_target`, `pinky_target`, `inky_target`, `clyde_target`. Kid reads the personality meta and routes to the right helper. ~9 lines (4 if-branches).

#### Slide D2-S098 — FC-6 hole: `is_clyde_close(ghost) -> bool`
- Format: G09 Concept + Task
- Title: "FC-6 — mirrors Chunk #6"
- Body LHS (board example — morning chunk #6 shape):
  ```gdscript
  func is_even(n) -> bool:
      return n % 2 == 0
  ```
- Image: none
- Caption: "Return `true` if the ghost is closer than 8 tiles to the player — call `distance_to_player(ghost)` and compare."
- Notes: Mirrors `is_even` shape exactly. Pre-given `distance_to_player(ghost)` does the math. Kid writes 2 lines.
- **§10.5c** Asset recap — Kenney Tiny Dungeon atlas card (G08). Estimated ~3-5 slides.
- **§10.5d** Export-to-exe walkthrough (Beat 6 of §6). Estimated ~6-8 slides.
- **§10.5e** Day closer — "Tomorrow: Tower Defense." Estimated ~1-2 slides.

### 10.6 Build-time notes for python-pptx chat (placeholder)

- **Master frame**: black bar; iCode logo top-left, red **"DAY 2"** label top-right, page-number bottom-right per `SLIDES_FORMATS.md` master frame spec. Brand = red/black/grey minimalist (LOCKED 2026-06-08, `SLIDES_PLAN.md` § Brand). No per-day color tab.
- **Walkthrough step badges**: G12 slides with step IDs (e.g. "T.1") render the badge as a small filled circle top-right of the screenshot.
- **Red highlight overlays**: described per-slide in `Image:` field, default 4px-stroke red rectangle.
- **Speaker notes**: `Notes:` field per slide populated into the PPTX speaker-notes pane.
- **Lesson-portion slide count (draft estimate)**: ~85-90 slides. Locked once per-slide expansion pass is done.
- **Verification before build**: re-run §9 checklist. If `main.gd` line numbers shift, screenshots + line-reference body text must update.

### 10.7 RHS prose-goal options (pending user pick)

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

### 10.8 Pending decisions (blocking per-slide expansion)

- [x] **As-typed code re-verification** — done 2026-05-29 afternoon under R1-R6 triage. `main.gd` rewritten; pre-given helpers added; chunk #6 converted to R5 partial-section hole; FC redesigned to ship with pre-given personality math. §5 + §10.7 RHS code columns refreshed to match.
- [x] **RHS prose pick (per chunk)** — LOCKED 2026-06-08. See §10.9.
- [x] **Historical-context slide content** — Pac-Man 1980. LOCKED 2026-06-08, 1 slide. See §10.9.
- [x] **Day tab color for D2** — RESOLVED 2026-06-08. Brand overridden to red/black/grey minimalist; NO per-day color. D2 carries the standard red "DAY 2" label. Palette locked in `SLIDES_PLAN.md` § Brand; `slides/theme.py` + `master.py` + `templates.py` updated to match.
- [x] **D1 retrofit** — DONE 2026-06-08 (same session): S002a (Pong history), S003a (VR history), S003b (escape-room tease) authored in D1 SLIDE_SOURCE.md §10. Checkbox was stale.
- [x] **FC pointer slide content authored** — DONE 2026-06-09. §10.5b fully expanded (S087–S098, 12 slides).

### 10.9 LOCKED picks (2026-06-08)

**RHS prose-goal picks** (final text for the side-by-side Action slide, RHS top):

| Chunk | Pick | Final RHS-top prose |
|---|---|---|
| #1 | A | Spawn three ghosts in the pen — but write the spawn call only once. |
| #2 | B | Each frame, walk through all the ghosts and move each one. |
| #3a | C | Get the dot total from `count_dots()` and store it in `dots_remaining`. |
| #3b | C+ | Scan the whole maze with a `while` loop. Count the dots. Return the count. |
| #4 | B− | Send the player back to the starting tile. |
| #5 | A | Move the player one tile in the direction they pressed — but only if a wall isn't in the way. |
| #6 | B | Given a cell, hand back `true` if it's blocked, `false` if it's open. *(off-grid + tunnel pre-given)* |

- #3b: appended "with a `while` loop" to make the construct requirement explicit (kid must understand a while loop is required, not optional).
- #4: truncated after "starting tile" (dropped "and clear any movement they had going") — keeps the goal statement tight; the movement-clearing detail lives in the speaker note, not on-slide.

**Pac-Man historical slide** — LOCKED: **1 slide** (opener pack slide 3, §10.2). Content:
- Pre-1980 arcades = almost all space shooters (Space Invaders, Asteroids). Pac-Man invented the **maze chase**.
- First game with a **character that had personality** — Pac-Man + 4 named ghosts, each its own AI brain (Blinky/Pinky/Inky/Clyde).
- First game with **cutscenes** (the intermissions between levels).
- First arcade game marketed **beyond boys** — broke the "arcade = boys only" mold.
- First giant **merchandising** wave — lunchboxes, a cartoon, even a hit song ("Pac-Man Fever").
- Bottom line: no Pac-Man → maybe no Mario, no Sonic, no mascots at all.

**D1 retrofit (do-now, 2026-06-08 user call)** — two additions to D1 `SLIDE_SOURCE.md`:
1. **Pong historical slide** — equivalent "why revolutionary" slide for the D1 opener pack (mirrors this D2 slide's shape).
2. **VR history + Day-5 foreshadow section** — NEW D1 section: brief history of VR, then what the camp does with VR on Day 5 (Steam **Escape Simulator** workshop — kids build their own escape room). Placement + depth pending pick (§10.9 open items below).

**Resolved 2026-06-08:**
- Brand → red/black/grey minimalist, no per-day color (theme/master/templates updated).
- D1 VR section placement → **opener mini-section**, inserted after the 5-day arc slide (D1-S003), before "Today's concepts" (D1-S004). Content depth = brief VR history slide + Day-5 escape-room tease slide (Steam Escape Simulator → kids build own escape room).
