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

## 10. Slide blueprint (Phase 2.5 — REVISED 2026-06-20)

> Per-slide build manifest for Day 2. Walk top to bottom; one slide per entry, in order.
> All D2_FEEDBACK.md items incorporated. All TODO slides use G13/G14 format (R7).

### 10.0 Schema

```
#### Slide D2-S### — <short label>
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

#### Slide D2-S001 — Day title
- Format: G01 Day Title
- Title: "VR Creator - Day 2"
- Body:
  - "Pac-Man · 1980 · Namco"
  - "The game that invented the maze chase."
- Image: `D2Pacman1.png` — 1980 Pac-Man arcade cabinet (placeholder OK). No red overlay.
- Notes: Read the title aloud. Point to the year.

#### Slide D2-S002 — Today we're building Pac-Man
- Format: G12 Screenshot + Caption
- Title: "Today we're building Pac-Man"
- Body: "Dots to chomp. Ghosts to dodge. A tunnel that wraps. Every visible thing on screen is a tile painted on a grid — and the code you'll write moves the player and spawns the ghosts."
- Image: `D2Pacman2.png` — classic Pac-Man maze in-game screenshot. No red overlay.
- Notes: —

#### Slide D2-S003 — Why Pac-Man was revolutionary
- Format: G04 Headline / Divider
- Title: "Why Pac-Man changed everything (1980)"
- Body:
  - "Pre-1980 arcades = almost all space shooters. Pac-Man **invented the maze chase**."
  - "First game with a **character with personality** — Pac-Man + 4 named ghosts (Blinky, Pinky, Inky, Clyde), each with its own AI."
  - "First game with **cutscenes** between levels."
  - "First arcade game marketed **beyond boys** — broke the 'arcade = boys only' mold."
  - "First giant **merchandising** wave — lunchboxes, a cartoon, a hit song."
  - "No Pac-Man → maybe no Mario, no Sonic, no character mascots at all."
- Image: none
- Notes: "When you write a loop to spawn 3 ghosts today — you're writing Pac-Man's DNA."

#### Slide D2-S004 — Yesterday → Today
- Format: G04 Headline / Divider
- Title: "Yesterday → Today"
- Body:
  - "**Day 1** — Variables + Conditions. You named things and made choices."
  - "**Day 2** — **Loops + Functions**. You repeat things and package code into reusable recipes."
  - "Same `var`, same `if`. Two new tools on top."
- Image: none
- Notes: —

#### Slide D2-S005 — 5-day arc timeline
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body: horizontal 5-step strip, left-to-right, today's box highlighted in iCode red, Day 1 ticked:
  - Day 1 ✓ Pong — Vars + Conditions
  - **Day 2 ← Pac-Man — Loops + Functions**
  - Day 3 Tower Defense — Lists + Functions deep
  - Day 4 Fighter — Objects
  - Day 5 VR Escape Room — Showcase
- Image: rendered timeline strip (python-pptx draws as 5 rectangles; today = iCode red, others light grey).
- Notes: "Two new ideas today. Everything else builds on what you already know."

#### Slide D2-S006 — Today's concepts
- Format: G04 Headline / Divider
- Title: "Today's concepts: Loops + Functions"
- Body:
  - "**Loops** — make the same code run again and again."
  - "**Functions** — give a block of code a name, call it whenever you need it."
- Image: none
- Notes: Two umbrellas only. All 6 chunks today live under one of these two.

#### Slide D2-S007 — GDScript vs Python (Day 2)
- Format: G03 GDScript vs Python
- Title: "GDScript is Python — one word changes"
- Body LHS:
  ```
  def update():
      pass
  ```
- Body RHS:
  ```gdscript
  func update():
      pass
  ```
- Image: none
- Notes: "Loops (`for`, `while`) are **identical** to Python. Only `def` → `func`. If you write Python later, you already know today's code."

---

### 10.2 Pre-coding setup (slides S008–S014)

#### Slide D2-S008 — Section divider: Pre-coding setup
- Format: G04 Headline / Divider
- Title: "Pre-coding setup"
- Body:
- Image: none
- Notes: —

#### Slide D2-S009 — Walk A: Open the Day 2 project (Challenge)
- Format: G04 Headline / Divider
- Title: "Open the Day 2 Maze project"
- Body: "Open the Day 2 Maze project the same way you did yesterday."
- Image: none
- Notes: Let kids try from memory. ~30 seconds before hint.

#### Slide D2-S010 — Walk A: Open the Day 2 project (Hint)
- Format: G04 Headline / Divider
- Title: "Walk A — Hint"
- Body:
  - "`Godot Launcher` → `Import` button"
  - "Navigate to `Day2_Maze_Game/project.godot`"
  - "Click **Import & Edit**"
- Image: none
- Notes: Text only, no screenshot — kids jog Day 1 memory.

#### Slide D2-S011 — Walk B: Open main.gd (Challenge)
- Format: G04 Headline / Divider
- Title: "Open `main.gd`"
- Body: "Open `main.gd` and switch to the Script editor — same way as yesterday."
- Image: none
- Notes: Let kids try.

#### Slide D2-S012 — Walk B: Open main.gd (Hint)
- Format: G04 Headline / Divider
- Title: "Walk B — Hint"
- Body:
  - "`FileSystem` panel (bottom-left) → find `main.gd`"
  - "Double-click → Script editor opens"
- Image: none
- Notes: —

#### Slide D2-S013 — TileSet / TileMapLayer concept
- Format: G04 Headline / Divider
- Title: "New today: TileSet and TileMapLayer"
- Body:
  - "**TileSet** = the **palette**. A resource that chops the Kenney atlas into named 16×16 tiles."
  - "**TileMapLayer** = a **node** that paints tiles from the TileSet onto a 2D grid."
  - "TileSet = box of crayons. TileMapLayer = the coloring page."
  - "Your code just asks the layer: 'is there a wall here?' You don't touch the TileSet panel."
- Image: none
- Notes: "The one TileSet call you write today: `wall_layer.get_cell_source_id(cell)` — introduced at chunk #6."

#### Slide D2-S014 — Two layers share one TileSet
- Format: G04 Headline / Divider
- Title: "Two layers share one TileSet"
- Body:
  - "`Walls` layer — collision tiles that block movement."
  - "`Dots` layer — the pellets to chomp."
  - "Both use the same TileSet palette. Two painted canvases, one box of crayons."
- Image: none
- Notes: —

---

### 10.3 Lesson section divider + "many right answers" (slides S021–S021a)

#### Slide D2-S021 — Section divider: Lesson chunks
- Format: G04 Headline / Divider
- Title: "Lesson chunks"
- Body:
- Image: none
- Notes: —

#### Slide D2-S021a — There are thousands of right answers
- Format: G04 Headline / Divider
- Title: "There are thousands of right answers"
- Body:
  - "Any piece of code has millions of valid ways to write it."
  - "The examples on the LEFT side of TODO slides are **one way**."
  - "Your way works if it runs. Seriously."
- Image: none
- Notes: Say this once, mean it. "If your code runs and does the thing — it's correct."

---

### 10.4a Chunk #1 — `for i in range(N)` (slides S022–S032)

#### Slide D2-S022 — Concept 1/4: Loop
- Format: G04 Headline / Divider
- Title: "Loop"
- Body:
- Image: none
- Notes: Say the word out loud. Pause. "What does *loop* mean to you?"

#### Slide D2-S023 — Concept 2/4: Meaning prompt
- Format: G04 Headline / Divider
- Title: "What does 'loop' mean?"
- Body:
  - "Roller coaster loop — the track **comes back around**."
  - "A rope tied in a loop — **no beginning, no end**."
  - "In code: a **loop = code that repeats**."
- Image: none
- Notes: Take answers. Land on "repeating" as the core idea.

#### Slide D2-S024 — Concept 3/4: Loop = repeating
- Format: G04 Headline / Divider
- Title: "A loop runs the same code again and again"
- Body:
  - "You write the action **once**."
  - "The loop runs it as many times as you say."
  - "No copy-paste. No 50 lines of the same thing."
- Image: none
- Notes: —

#### Slide D2-S025 — Code shape: `for i in range(3)`
- Format: G10 Code Shape
- Title: "`for i in range(3):` — the shape"
- Body:
  ```gdscript
  for i in range(3):
      print(i)
  # prints: 0  1  2
  ```
- Image: none
- Notes: "`i` starts at 0, goes to 2. Block runs 3 times total."

#### Slide D2-S026 — Stairs to your bedroom
- Format: G04 Headline / Divider
- Title: "14 stairs to your bedroom"
- Body:
  - "Every night: step, step, step — **14 times**. Same motion. Known count."
  - "`for i in range(14):` → `    climb_one_stair()`"
  - "You know exactly how many stairs. The loop counts for you."
- Image: none
- Notes: "You don't say 'step step step' 14 times. You say 'go up the stairs.' That's a loop."

#### Slide D2-S027 — Question: range(5) runs how many times?
- Format: G04 Headline / Divider
- Title: "How many times does `range(5)` run?"
- Body:
- Image: none
- Notes: Kids answer: 5 times (i = 0, 1, 2, 3, 4). Follow-up: "What's the LAST value of i?" → 4.

#### Slide D2-S028 — range(N) takeaway
- Format: G04 Headline / Divider
- Title: "`range(N)` = N runs"
- Body:
  - "`range(3)` → runs 3 times (i = 0, 1, 2)."
  - "`range(10)` → runs 10 times."
  - "`range(0)` → runs **zero** times."
- Image: none
- Notes: "'range(0) — zero stairs, zero runs. The loop just skips.'"

#### Slide D2-S028a — For-loop step-through: i = 0
- Format: G04 Headline / Divider
- Title: "Watch the loop run — step 1"
- Body:
  - "**→ `for i in range(3):`** — `i = 0`"
  - "`    print(i)` → prints `0`"
  - "↑ **Back to the top** of the loop"
- Image: none
- Notes: Point physically to each line as you read. The key beat: control returns to the `for` line.

#### Slide D2-S028b — For-loop step-through: i = 1
- Format: G04 Headline / Divider
- Title: "Watch the loop run — step 2"
- Body:
  - "**→ `for i in range(3):`** — `i = 1`"
  - "`    print(i)` → prints `1`"
  - "↑ **Back to the top** of the loop"
- Image: none
- Notes: —

#### Slide D2-S028c — For-loop step-through: i = 2 → exit
- Format: G04 Headline / Divider
- Title: "Watch the loop run — step 3 → done"
- Body:
  - "**→ `for i in range(3):`** — `i = 2`"
  - "`    print(i)` → prints `2`"
  - "↑ Back to top — `range(3)` exhausted → **loop exits**"
- Image: none
- Notes: "The algorithm goes back to the `for` line every single time. That's what makes it a loop."

#### Slide D2-S029 — Games loop all the time
- Format: G04 Headline / Divider
- Title: "Games loop all the time"
- Body:
  - "Spawn **50 trees** in a forest level → `for i in range(50):`"
  - "Deal **4 cards** at game start → `for i in range(4):`"
  - "Create **12 enemies** in the first wave → `for i in range(12):`"
- Image: none
- Notes: "Write the action once. The loop handles the rest."

#### Slide D2-S030 — In our game: spawn 3 ghosts
- Format: G04 Headline / Divider
- Title: "In our game: spawn 3 ghosts"
- Body:
  - "At startup, 3 ghosts need to appear in the pen."
  - "Without a loop: write `spawn_ghost_at(...)` three times."
  - "With a loop: write it **once**. `for i in range(3):` handles 3."
  - "If the designer adds a 4th ghost — you change **one number**."
- Image: none
- Notes: —

#### Slide D2-S031 — Where in game (TODO #1 location)
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — inside `_ready()`"
- Body: "At the `# TODO #1` marker inside `_ready()`. This runs once when the game starts."
- Image: `D2C1.png` — main.gd lines 65-78, showing `# TODO #1` banner + `#@todo` gap. No red overlay.
- Notes: —

#### Slide D2-S031b — Pre-TODO #1: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Use a for loop to repeat 3 times (i = 0, 1, 2):
  #     Spawn one ghost at the position for slot i
  ```
  - "**What:** A `for` loop that spawns 3 ghosts at startup — one per iteration."
  - "**Why:** Without this loop, no ghosts appear. The maze is empty."
  - "**How:** `for i in range(3):` runs 3 times. Each run, call the pre-given `spawn_ghost_at(ghost_spawn_pos(i))`."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S032 — TODO #1: spawn 3 ghosts
- Format: G13 TODO
- Title: "**TODO #1** — Spawn 3 ghosts"
- Syntax: for_range
- Body RHS:
  ```gdscript
  # Use a for loop to repeat 3 times (i = 0, 1, 2):
  #     Spawn one ghost at the position for slot i
  ```
- Image: `D2C1.png` — main.gd lines 65-78, red overlay on `#@todo` gap.
- Notes: 2 lines. `spawn_ghost_at` and `ghost_spawn_pos(i)` are pre-given helpers. Celebrate their first loop.

---

### 10.4b Walk C + Walk D + Personalization #1 (slides S033–S036a)

#### Slide D2-S033 — Walk C: Run your game (Challenge)
- Format: G04 Headline / Divider
- Title: "Run your game"
- Body: "Press the same key you used yesterday to start the project."
- Image: none
- Notes: Kids try from memory. ~15 seconds.

#### Slide D2-S034 — Walk C: Run your game (Hint)
- Format: G04 Headline / Divider
- Title: "Walk C — Hint"
- Body:
  - "Press **F5** → 'Set Main Scene?' → **Select Current** → game window opens."
  - "Press **F8** to stop."
- Image: none
- Notes: Text only. First run this session.

#### Slide D2-S035 — Walk D: Find the error (Challenge)
- Format: G04 Headline / Divider
- Title: "Game didn't open? Find the error."
- Body:
- Image: none
- Notes: Only advance here if kids hit a parse error.

#### Slide D2-S036 — Walk D: Find the error (Hint)
- Format: G04 Headline / Divider
- Title: "Walk D — Hint"
- Body:
  - "Look at the **Output** panel (bottom of editor)."
  - "Find the error line → click the **blue line number** → editor jumps there."
  - "Fix the typo → **Ctrl+S** → **F5** again."
- Image: none
- Notes: —

#### Slide D2-S036a — Personalization #1: tune your ghost count
- Format: G04 Headline / Divider
- Title: "Personalization #1"
- Body:
  - "3 ghosts feel right — but try 4, or even 1."
  - "Find `for i in range(3)` in your `_ready()`. Change the number. Run it."
  - "What happens with 10 ghosts?"
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: open-ended. No screenshots needed.

---

### 10.4c Chunk #2 — `for item in list` (slides S037–S039)

#### Slide D2-S037 — Same `for`, new shape
- Format: G04 Headline / Divider
- Title: "Same `for`. New shape."
- Body:
  - "Last chunk: `for i in range(3)` — a **number** after `range`. Known count."
  - "This chunk: `for ghost in ghosts` — the **name of a list** you already have."
  - "The loop visits every item in the list, one by one."
- Image: none
- Notes: "You already have a list called `ghosts`. The loop walks through it."

#### Slide D2-S037a — Pre-TODO #2: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Use a for loop to visit each ghost in the ghosts list:
  #     Tell that ghost to take one step
  ```
  - "**What:** A `for` loop that moves every ghost by one step, every frame."
  - "**Why:** Without this, ghosts spawn but never move."
  - "**How:** `for ghost in ghosts:` visits each ghost. `step_ghost(ghost)` is the pre-given helper that moves one ghost."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S038 — TODO #2: step every ghost each frame
- Format: G13 TODO
- Title: "**TODO #2** — Step every ghost each frame"
- Syntax: for_in
- Body RHS:
  ```gdscript
  # Use a for loop to visit each ghost in the ghosts list:
  #     Tell that ghost to take one step
  ```
- Image: `D2C2.png` — main.gd lines 130-142, red overlay on `#@todo` gap inside the `else` branch.
- Notes: 2 lines. `step_ghost(ghost)` is pre-given. This loop runs 60 times per second.

#### Slide D2-S039 — After-works: Ghosts patrol!
- Format: G12 Screenshot + Caption
- Title: "Ghosts patrol!"
- Body: "Run the game. After 2 seconds, ghosts start moving."
- Image: none
- Notes: First big visible payoff of the day. "Your loop is running 60 times per second — once per frame."

---

### 10.4d Chunk #3 — `while` loop (slides S040–S053)

#### Slide D2-S040 — Bridge: while is a loop cousin
- Format: G04 Headline / Divider
- Title: "Loops have a cousin: `while`"
- Body:
- Image: none
- Notes: —

#### Slide D2-S041 — Concept 1/3: "while"
- Format: G04 Headline / Divider
- Title: "while"
- Body:
- Image: none
- Notes: Say the word. "What does 'while' mean in plain English?"

#### Slide D2-S042 — Concept 2/3: while = as long as
- Format: G04 Headline / Divider
- Title: "while = as long as"
- Body:
  - "**While** it's raining, stay inside."
  - "**While** there's food on the plate, keep eating."
  - "In code: `while` runs the block again and again — **as long as the condition is true**."
- Image: none
- Notes: —

#### Slide D2-S043 — Code shape: while loop
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
- Notes: "`n` starts at 0. Each run: print n, add 1. Stops when n reaches 5."

#### Slide D2-S044 — for vs while: same stairs, different light
- Format: G04 Headline / Divider
- Title: "`for` vs `while` — same stairs, different light"
- Body:
  - "**`for`** — you **KNOW** the count. (14 stairs to your bedroom — you've climbed them 1000 times.)"
  - "**`while`** — you **DON'T** know the count. (Stairs in the dark — step up, stop when your foot finds no stair.)"
  - "Same repeated motion. Different stopping rule."
- Image: none
- Notes: Load-bearing. Kids who confuse for and while will trip on chunk #3b.

#### Slide D2-S045 — Stairs in the dark
- Format: G04 Headline / Divider
- Title: "Stairs in the dark"
- Body:
  - "Power's out. You're climbing stairs. You can't see the top."
  - "Step. Step. Step. Each time: **is there another stair?** Yes → keep going. No → stop."
  - "You don't know the count in advance. You stop when the condition is false."
- Image: none
- Notes: "Direct callback to the for-range stairs. Same motion, different stopping rule."

#### Slide D2-S046 — Question: how many times does this run?
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

#### Slide D2-S047 — while takeaway
- Format: G04 Headline / Divider
- Title: "`while` = keep going until the condition is false"
- Body:
  - "`while n < 5:` → stop when n reaches 5."
  - "`while lives > 0:` → stop when lives hit 0."
  - "`while has_more_dots():` → stop when no dots remain."
- Image: none
- Notes: —

#### Slide D2-S048 — while in games
- Format: G04 Headline / Divider
- Title: "`while` in games"
- Body:
  - "Scan a grid for coins: `while x < map_width:`"
  - "Fall until you hit the floor: `while not on_ground:`"
  - "Keep playing until lives run out: `while lives > 0:`"
- Image: none
- Notes: "Anything where you don't know the count in advance."

#### Slide D2-S049 — In our game: count every dot
- Format: G04 Headline / Divider
- Title: "In our game: count every dot"
- Body:
  - "The maze is 28 × 31 = **868 tiles**."
  - "At startup, count how many tiles have a dot — that's the win target."
  - "Scan every column (x) → every row (y) → count the dots."
- Image: none
- Notes: "When `dots_remaining` hits 0, the player wins. This setup makes that work."

#### Slide D2-S050 — Where chunk #3a lives (caller)
- Format: G12 Screenshot + Caption
- Title: "Where #3a lives — the caller in `_ready()`"
- Body: "One line in `_ready()`: call `count_dots()` and store the result."
- Image: `D2C3a.png` — main.gd lines 80-88, showing `# TODO #3a` banner. No red overlay.
- Notes: —

#### Slide D2-S051 — Where chunk #3b lives (function body)
- Format: G12 Screenshot + Caption
- Title: "Where #3b lives — the `count_dots()` body"
- Body: "The whole `count_dots()` function body. You'll write the nested `while` loops inside."
- Image: `D2C3b.png` — main.gd lines 207-225, showing `func count_dots()` signature + empty `#@todo`. No red overlay.
- Notes: —

#### Slide D2-S051a — Pre-TODO #3a: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Call count_dots() and store the result as the number of dots to collect
  ```
  - "**What:** One line — call `count_dots()` and store the answer."
  - "**Why:** `dots_remaining` is the win counter. Without this, it stays 0 forever."
  - "**How:** `dots_remaining = count_dots()` — assign the return value to the variable."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S052 — TODO #3a: store the dot count
- Format: G13 TODO
- Title: "**TODO #3a** — Store the dot count"
- Syntax: func_return, var
- Body RHS:
  ```gdscript
  # Call count_dots() and store the result as the number of dots to collect
  ```
- Image: `D2C3a.png` — main.gd lines 80-88, red overlay on `#@todo` gap.
- Notes: 1 line. `count_dots()` is the function they write next in #3b.

#### Slide D2-S052a — Nested loop: what does it do?
- Format: G04 Headline / Divider
- Title: "What does a nested loop do?"
- Body:
  - "A nested loop = a loop **inside** another loop."
  - "The **inner loop runs completely** before the outer loop takes one step."
  - "Scanning a grid needs exactly this."
- Image: none
- Notes: "You're about to scan 28 columns × 31 rows = 868 tiles. Let's watch it happen."

#### Slide D2-S052b — Nested loop step-through: outer x = 0
- Format: G04 Headline / Divider
- Title: "Nested loop — outer x = 0"
- Body:
  - "**→ outer loop:** `x = 0`"
  - "**→ inner loop:** `y = 0` → check (0,0) → `y = 1` → check (0,1) → … → `y = 30` → check (0,30)"
  - "Inner loop exhausted (31 rows scanned). ↑ Back to **outer** loop."
- Image: none
- Notes: "Inner loop runs ALL the way through before x moves."

#### Slide D2-S052c — Nested loop step-through: outer x = 1
- Format: G04 Headline / Divider
- Title: "Nested loop — outer x = 1"
- Body:
  - "**→ outer loop:** `x = 1`"
  - "**→ inner loop restarts:** `y = 0` → check (1,0) → … → `y = 30` → check (1,30)"
  - "Inner loop exhausted. ↑ Back to outer. Repeats until `x = 27`."
- Image: none
- Notes: "28 outer steps × 31 inner steps = 868 total tile checks."

#### Slide D2-S052d — Nested loop takeaway
- Format: G04 Headline / Divider
- Title: "Inner finishes before outer steps"
- Body:
  - "Rule: **inner loop always runs to completion** before the outer loop increments."
  - "Outer = columns (x). Inner = rows (y). Together they visit every cell."
  - "This pattern = the standard 2D grid scan."
- Image: none
- Notes: —

#### Slide D2-S052e — Pre-TODO #3b: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Start with zero dots counted
  # Start at the first row (x = 0)
  # Use a while loop to walk through every row (x) in the maze, one at a time:
  #     Start at the first column (y = 0) in this row
  #     Use a while loop to walk through every column (y) in this row, one at a time:
  #         If this tile has a dot on it, add one to the count
  #         Move to the next column (y = y + 1)
  #     Move to the next row (x = x + 1)
  # Return the total dot count
  ```
  - "**What:** Nested while loops that scan every tile and count dots."
  - "**Why:** `count_dots()` is called by #3a. Without it, the win counter never starts."
  - "**How:** Outer loop scans columns (x), inner loop scans rows (y). `cell_has_dot(x, y)` is pre-given."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S053 — TODO #3b: count_dots() body
- Format: G13 TODO
- Title: "**TODO #3b** — Write `count_dots()` body"
- Syntax: while_loop, var, return, if
- Body RHS:
  ```gdscript
  # Start with zero dots counted
  # Start at the first row (x = 0)
  # Use a while loop to walk through every row (x) in the maze, one at a time:
  #     Start at the first column (y = 0) in this row
  #     Use a while loop to walk through every column (y) in this row, one at a time:
  #         If this tile has a dot on it, add one to the count
  #         Move to the next column (y = y + 1)
  #     Move to the next row (x = x + 1)
  # Return the total dot count
  ```
- Image: `D2C3b.png` — main.gd lines 207-225, red overlay on `#@todo` gap.
- Notes: Harder chunk — circulate actively. `MAZE_W`, `MAZE_H`, `cell_has_dot(x, y)` all pre-given.

---

### 10.4e Chunk #4 — `func` no params (slides S054–S065)

#### Slide D2-S054 — Concept 1/4: Function
- Format: G04 Headline / Divider
- Title: "Function"
- Body:
- Image: none
- Notes: Say the word. "What's the *function* of a remote control?"

#### Slide D2-S055 — Concept 2/4: Meaning
- Format: G04 Headline / Divider
- Title: "What's the function of…?"
- Body:
  - "A **remote control** → change the channel. That's its function."
  - "A **calculator** → do math. That's its function."
  - "Function = **the thing it DOES**."
- Image: none
- Notes: "In code, a function is a named block of code that DOES one thing."

#### Slide D2-S056 — Concept 3/4: define once, call anywhere
- Format: G04 Headline / Divider
- Title: "Function = a name for a block of code"
- Body:
  - "`func say_hi():` → defines the function named `say_hi`."
  - "`say_hi()` → *calls* it — runs the block."
  - "Define the recipe once. Call it any number of times."
- Image: none
- Notes: —

#### Slide D2-S057 — Code shape: defined once, two distinct call sites
- Format: G10 Code Shape
- Title: "Defined once — called from two different places"
- Body:
  ```gdscript
  func reset_player():
      player_cell = PLAYER_START
      player_moving = false

  # called when a ghost catches you:
  func on_ghost_collision():
      reset_player()

  # called when a new game starts:
  func start_game():
      reset_player()
  ```
- Image: none
- Notes: "Two completely different moments — same function. Change the recipe once → both callers get the update."

#### Slide D2-S058 — Pizza metaphor
- Format: G04 Headline / Divider
- Title: "The pizza order"
- Body:
  - "You walk into a pizza shop. You say: **'Margherita.'**"
  - "The kitchen does dough → tomato → cheese → bakes → cuts → boxes."
  - "You didn't say any of that. You just said the **name**. The recipe ran."
- Image: none
- Notes: "That's a function. You define the recipe once. You call it by name."

#### Slide D2-S059 — Question: how many times does say_hi() print?
- Format: G04 Headline / Divider
- Title: "How many times does `say_hi()` print if you call it 3 times?"
- Body:
- Image: none
- Notes: Kids answer: 3 times. "The function *definition* doesn't print anything. *Calling* it does."

#### Slide D2-S060 — Takeaway: define once, call anywhere
- Format: G04 Headline / Divider
- Title: "Define once. Call anywhere."
- Body:
  - "Without functions: copy-paste the same 5 lines every time you need them."
  - "With functions: **write once**, call by name from anywhere in the file."
  - "Change the recipe once → every call gets the update automatically."
- Image: none
- Notes: —

#### Slide D2-S061 — Functions in games
- Format: G04 Headline / Divider
- Title: "Functions are everywhere in games"
- Body:
  - "`jump()` — called whenever player presses space."
  - "`die()` — called when health hits 0."
  - "`spawn_enemy()` — called at the start of each wave."
- Image: none
- Notes: —

#### Slide D2-S062 — In our game: reset_player()
- Format: G04 Headline / Divider
- Title: "In our game: `reset_player()`"
- Body:
  - "When a ghost catches the player: send them home, clear movement, wipe direction."
  - "That's 5 lines. We wrap them in `reset_player()`."
  - "Called every time a ghost catches the player — and from the start-game code too."
- Image: none
- Notes: "One function, multiple call sites."

#### Slide D2-S063 — Where in game (TODO #4 location)
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `reset_player()`"
- Body: "The function body is at `main.gd` lines 164-191. You'll write the contents."
- Image: `D2C4.png` — main.gd lines 164-191, showing `func reset_player() -> void:` signature + empty `#@todo`. No red overlay.
- Notes: —

#### Slide D2-S063a — Pre-TODO #4: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Send the player back to the starting tile
  # Move the player's sprite to match that tile on screen
  # Mark the player as not currently moving
  # Forget which direction the player was going
  # Forget any direction the player had queued up
  ```
  - "**What:** Five assignments that send the player home with a clean slate."
  - "**Why:** Without this, a ghost catch leaves the player stuck mid-tile."
  - "**How:** `cell_to_world(player_cell)` is pre-given — converts tile coords to screen position."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S064 — TODO #4: reset_player() body
- Format: G13 TODO
- Title: "**TODO #4** — Write `reset_player()` body"
- Syntax: func_void, dot_eq
- Body RHS:
  ```gdscript
  # Send the player back to the starting tile
  # Move the player's sprite to match that tile on screen
  # Mark the player as not currently moving
  # Forget which direction the player was going
  # Forget any direction the player had queued up
  ```
- Image: `D2C4.png` — main.gd lines 164-191, red overlay on `#@todo` gap.
- Notes: 5 lines. All variable names and helpers listed in the code comments above `#@todo` in their file.

#### Slide D2-S065 — After-works: Ghost catches you → you respawn!
- Format: G12 Screenshot + Caption
- Title: "Ghost catches you → you respawn!"
- Body: "Run the game. Walk into a ghost. You pop back to the start."
- Image: none
- Notes: "Your function just ran — called from deep inside the ghost collision code."

---

### 10.4f Personalization #2 (slide S065a)

#### Slide D2-S065a — Personalization #2: tune your respawn
- Format: G04 Headline / Divider
- Title: "Personalization #2"
- Body:
  - "Where should the player respawn? Find `const PLAYER_START` near the top of `main.gd`."
  - "Change the tile coordinate. Run it. Where does the player land after a ghost catch?"
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: open-ended. No screenshots needed.

---

### 10.4g Chunk #5 — `func` with parameter (slides S066–S075)

#### Slide D2-S066 — Bridge: functions can take inputs
- Format: G04 Headline / Divider
- Title: "Functions can take INPUTS"
- Body:
  - "Last chunk: `func reset_player()` — no inputs. Same thing every time."
  - "This chunk: `func move_player(direction)` — something **between the parentheses**."
  - "That thing is called a **parameter** — an input you hand to the function."
- Image: none
- Notes: —

#### Slide D2-S067 — Concept: parameter
- Format: G04 Headline / Divider
- Title: "Parameter"
- Body:
- Image: none
- Notes: Say the word. "Info you hand to the function when you call it."

#### Slide D2-S068 — A parameter is info you hand in
- Format: G04 Headline / Divider
- Title: "A parameter is info you hand to the function"
- Body:
  - "`func add_points(amount):` — `amount` is the parameter."
  - "Call `add_points(10)` → `amount` is `10` inside the function."
  - "Call `add_points(50)` → `amount` is `50`."
  - "Same function. Different input each time."
- Image: none
- Notes: —

#### Slide D2-S069 — Code shape: func with param
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

#### Slide D2-S070 — Pizza extends: large or small
- Format: G04 Headline / Divider
- Title: "Margherita — large or small?"
- Body:
  - "You say: **'Margherita large.'** Kitchen runs the same recipe. Big ball of dough."
  - "You say: **'Margherita small.'** Same recipe. Small ball of dough."
  - "The **size** is the parameter. One recipe, different inputs."
- Image: none
- Notes: —

#### Slide D2-S071 — Takeaway: one function, different inputs
- Format: G04 Headline / Divider
- Title: "One function. Different inputs each time."
- Body:
  - "`move_player(Vector2i.UP)` → moves up."
  - "`move_player(Vector2i.DOWN)` → moves down."
  - "Same function, called with whatever key is pressed."
- Image: none
- Notes: —

#### Slide D2-S072 — In our game: move_player(direction)
- Format: G04 Headline / Divider
- Title: "In our game: `move_player(direction)`"
- Body:
  - "`direction` is the parameter — a `Vector2i` for up, down, left, or right."
  - "Arrow key pressed → `direction` is set → `move_player(direction)` is called."
  - "The function moves the player one tile in that direction (if no wall is in the way)."
- Image: none
- Notes: —

#### Slide D2-S073 — Where in game (TODO #5 location)
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `move_player(direction)`"
- Body: "Inside `move_player(direction)` at `main.gd` lines 194-229. The `direction: Vector2i` parameter is already in the signature."
- Image: `D2C5.png` — main.gd lines 194-229, showing `direction: Vector2i` parameter. No red overlay.
- Notes: —

#### Slide D2-S073a — Pre-TODO #5: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Figure out which tile the player would land on if they step in this direction
  # If that tile is a wall, return early — don't move
  # If the player stepped off the edge, wrap them to the other side of the maze
  # Slide the player to the new tile
  ```
  - "**What:** Move the player one tile — wall check first, tunnel wrap after."
  - "**Why:** Without this, arrow keys do nothing."
  - "**How:** `hit_wall`, `wrap_cell`, `step_player_to` are all pre-given helpers."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S074 — TODO #5: move_player(direction) body
- Format: G13 TODO
- Title: "**TODO #5** — Write `move_player(direction)` body"
- Syntax: func_param, if, return, func_call
- Body RHS:
  ```gdscript
  # Figure out which tile the player would land on if they step in this direction
  # If that tile is a wall, return early — don't move
  # If the player stepped off the edge, wrap them to the other side of the maze
  # Slide the player to the new tile
  ```
- Image: `D2C5.png` — main.gd lines 194-229, red overlay on `#@todo` gap.
- Notes: 4 lines. Wall check → return → wrap → step. All helpers pre-given.

#### Slide D2-S075 — After-works: Arrow keys move!
- Format: G12 Screenshot + Caption
- Title: "Arrow keys move the player!"
- Body: "Run the game. Press arrow keys. Player slides one tile at a time."
- Image: none
- Notes: "Your function is called every time an arrow key is held. The parameter carries the direction."

---

### 10.4h Chunk #6 — `func` returning a bool (slides S076–S086)

#### Slide D2-S076 — Bridge: functions can hand back an answer
- Format: G04 Headline / Divider
- Title: "Functions can HAND BACK an answer"
- Body:
  - "So far: functions **do** something."
  - "New idea: a function can also **return a value** — hand an answer back to the caller."
  - "That answer is called the **return value**."
- Image: none
- Notes: —

#### Slide D2-S077 — Concept: return
- Format: G04 Headline / Divider
- Title: "return"
- Body:
- Image: none
- Notes: Say the word. "Functions can send something back."

#### Slide D2-S078 — return hands a value back
- Format: G04 Headline / Divider
- Title: "`return` hands a value back to the caller"
- Body:
  - "`return` = 'here's your answer.'"
  - "The caller gets the value and can store it or use it immediately."
- Image: none
- Notes: —

#### Slide D2-S079 — Return value in real game context
- Format: G10 Code Shape
- Title: "Storing a return value — from your game"
- Body:
  ```gdscript
  # count_dots() scans the maze and returns a number.
  # Store that number so we know the win target.
  var dots_left := count_dots()

  # hit_wall() scans one tile and returns true or false.
  # Use the answer immediately in an if — no var needed.
  if hit_wall(next_cell):
      return
  ```
- Image: none
- Notes: "Same pattern two ways: store the value, or use it directly in `if`. Both are valid."

#### Slide D2-S080 — Boolean refresher
- Format: G04 Headline / Divider
- Title: "Remember booleans from Day 1?"
- Body:
  - "A **boolean** is a true/false value — the light switch."
  - "`true` = on. `false` = off."
  - "Today: our function hands back a **boolean** — 'yes this is a wall' or 'no it isn't.'"
- Image: none
- Notes: "One-slide callback. If kids don't remember, don't reteach — context will make it click."

#### Slide D2-S081 — Pizza hands back
- Format: G04 Headline / Divider
- Title: "The kitchen hands the pizza BACK"
- Body:
  - "Old: you say 'margherita', kitchen makes it. No pizza in your hands."
  - "New: `var dinner = margherita('large')` — kitchen makes it AND **hands it to you**."
  - "`dinner` IS the pizza. That's the return value."
- Image: none
- Notes: —

#### Slide D2-S082 — `-> bool` = yes or no
- Format: G04 Headline / Divider
- Title: "`-> bool` = this function answers yes or no"
- Body:
  - "`hit_wall(cell) -> bool` — 'is there a wall at this cell?'"
  - "`is_alive() -> bool` — 'is the player still alive?'"
  - "`in_range(target) -> bool` — 'is the enemy close enough to shoot?'"
- Image: none
- Notes: —

#### Slide D2-S083 — In our game: hit_wall(cell)
- Format: G04 Headline / Divider
- Title: "In our game: `hit_wall(cell)`"
- Body:
  - "`move_player(direction)` needs to know: 'is the next tile a wall?'"
  - "It calls `hit_wall(next_cell)` → gets back `true` or `false`."
  - "If `true` → don't move. If `false` → move."
- Image: none
- Notes: "Kids already wrote `move_player` and called `hit_wall` without knowing it. Now they write it."

#### Slide D2-S084 — Where in game (TODO #6 location, R5 partial hole)
- Format: G12 Screenshot + Caption
- Title: "Where you'll type it — `hit_wall(cell)` (partial hole)"
- Body: "Inside `hit_wall(cell)` at `main.gd` lines 232-257. Off-grid + tunnel guards are pre-given. You write only the in-grid wall query."
- Image: `D2C6.png` — main.gd lines 232-257, showing the partial-section hole. No red overlay.
- Notes: —

#### Slide D2-S084a — Pre-TODO #6: What you're about to write
- Format: G14 Pre-TODO
- Title: "What you're about to write"
- Body:
  ```gdscript
  # Ask the wall layer what tile is at this cell and store the result
  # Return true if a tile was found there, false if the cell is empty
  ```
  - "**What:** Two lines inside the `#@todo` block — the in-grid wall check."
  - "**Why:** The off-grid and tunnel guards above are pre-given. Your section answers: is there a wall tile here?"
  - "**How:** `get_cell_source_id(cell)` returns `-1` if no tile exists. Any other number = wall tile."
- Image: none
- Notes: "This is one approach — yours works if it runs."

#### Slide D2-S085 — TODO #6: hit_wall in-grid section (R5 partial hole)
- Format: G13 TODO
- Title: "**TODO #6** — Write the in-grid wall check"
- Syntax: func_return, dot
- Body RHS:
  ```gdscript
  # Ask the wall layer what tile is at this cell and store the result
  # Return true if a tile was found there, false if the cell is empty
  ```
- Image: `D2C6.png` — main.gd lines 232-257. Two-tone overlay: gray = pre-given off-grid + tunnel guards; red = your hole.
- Notes: R5 partial hole. 2 lines. Gray overlay = pre-given; red = your hole.

#### Slide D2-S086 — After-works: The maze is alive!
- Format: G12 Screenshot + Caption
- Title: "The maze is alive!"
- Body: "Run the game. Walls block. Tunnel wraps. Ghosts patrol. Dots are chompable."
- Image: none
- Notes: End-of-morning celebration. "Every mechanic running right now came from code YOU wrote this morning."

---

### 10.5 Personalization #3 (slide S086a)

#### Slide D2-S086a — Personalization #3: make it yours
- Format: G04 Headline / Divider
- Title: "Personalization #3 — Make it yours"
- Body:
  - "The game works. Now make it YOURS."
  - "Repaint the walls and dots. Move the tunnel row. Tweak the ghost timing. Swap the player sprite."
  - "Download free art from **kenney.nl** and drop it in."
  - "*Low on time? Skip this and keep going. Finished early? This is for you.*"
- Image: none
- Notes: open-ended play block. Kids who want the Final Challenge can jump straight to it.

---

### 10.6 Final Challenge — R3.2 compressed (slides S087–S090)

#### Slide D2-S087 — Section divider: Final Challenge
- Format: G04 Headline / Divider
- Title: "Final Challenge"
- Body:
  - "Unlock the real Pac-Man ghosts. Open `ghost_personalities.gd` — six `#@todo` holes."
  - "When all six are filled: open `main.gd`, flip `PERSONALITY_MODE_ENABLED` to `true`, and run."
  - "Four personality ghosts replace the three plain ones."
- Image: none
- Notes: opt-in stretch. The enable toggle and all wiring are pre-given — kids fill only the six holes.

#### Slide D2-S088 — FC pointer: you already know how to do this
- Format: G04 Headline / Divider
- Title: "You already know how to do this."
- Body:
  - "Each TODO in `ghost_personalities.gd` mirrors a chunk you wrote this morning."
  - "**FC-1** ← Chunk **#1** (`for i in range(N)`)"
  - "**FC-2** ← Chunk **#2** (`for item in list`)"
  - "**FC-3** ← Chunk **#3** (`while` loop + counter + return)"
  - "**FC-4** ← Chunk **#4** (`func` no params)"
  - "**FC-5** ← Chunk **#5** (`func` with parameter + return)"
  - "**FC-6** ← Chunk **#6** (`func` returning bool)"
- Image: none
- Notes: R3 requirement — read aloud. Let kids find the mirror chunks before starting.

#### Slide D2-S089 — The 4 personalities
- Format: G07 Table
- Title: "The 4 personalities"
- Body:
  | Ghost | Colour | Behaviour |
  |---|---|---|
  | **Blinky** | Red | Heads straight for the player |
  | **Pinky** | Pink | Aims 4 tiles ahead of the player |
  | **Inky** | Cyan | Flanks from the opposite side of Blinky |
  | **Clyde** | Orange | Chases when far, scatters when close |
- Image: none
- Notes: "The targeting math is pre-given — kids wire personalities together, not compute vectors."

#### Slide D2-S090 — FC compressed: all 6 holes (R3.2)
- Format: G07 Table
- Title: "Final Challenge — all 6 holes"
- Body:
  | FC | Syntax | Write this (comments) |
  |---|---|---|
  | **FC-1** `spawn_personality_ghosts()` | `for_range` | `# for i in range(PERSONALITY_COUNT):` / `#     spawn_one_personality(i)` |
  | **FC-2** `step_all_personality_ghosts()` | `for_in` | `# for ghost in ghosts:` / `#     step_personality(ghost)` |
  | **FC-3** `count_ghosts_of(personality) -> int` | `while_loop, return` | `# var count := 0` / `# for ghost in ghosts: if get_meta == personality: count += 1` / `# return count` |
  | **FC-4** `reset_personality_ghosts()` | `for_in, var, plus_eq` | `# var i := 0` / `# for ghost in ghosts: respawn_personality_ghost(ghost, i) / i += 1` |
  | **FC-5** `target_for(ghost) -> Vector2i` | `func_return, if` | `# var p = ghost.get_meta("personality")` / `# if p == BLINKY: return blinky_target(ghost)` / `# elif PINKY … INKY … CLYDE` |
  | **FC-6** `is_clyde_close(ghost) -> bool` | `func_return` | `# var d := distance_to_player(ghost)` / `# return d < 8.0` |
- Image: none
- Notes: Detailed instructions live in `ghost_personalities.gd` right next to each `#@todo`. All targeting math is pre-given.

---

### 10.7 Export to .exe (slides S099–S107)

> Reuses D1 export screenshots (`D1B6S1`–`D1B6S8`) — the Godot export flow is identical every day.

#### Slide D2-S099 — Section divider: Take it home
- Format: G04 Headline / Divider
- Title: "Take it home"
- Body: "Turn your maze game into a real Windows program — a `.exe` you can run on any PC, no Godot needed."
- Image: none
- Notes: the day's takeaway artifact.

#### Slide D2-S100 — Export 1: Project → Export
- Format: G12 Screenshot + Caption
- Title: "Step 1 — Project → Export…"
- Body: "In the top menu bar, click **Project**, then **Export…**"
- Image: `D1B6S1.png` — the Project menu open, Export… visible.
- Notes: save first (Ctrl+S) so the latest code ships.

#### Slide D2-S101 — Export 2: the Export window
- Format: G12 Screenshot + Caption
- Title: "Step 2 — The Export window"
- Body: "The Export window opens. Click **Add…** at the top to add a target."
- Image: `D1B6S2.png` — empty Export window, Add… button.
- Notes: —

#### Slide D2-S102 — Export 3: pick Windows Desktop
- Format: G12 Screenshot + Caption
- Title: "Step 3 — Choose Windows Desktop"
- Body: "From the list, pick **Windows Desktop**."
- Image: `D1B6S3.png` — platform list, Windows Desktop.
- Notes: —

#### Slide D2-S103 — Export 4: preset is ready
- Format: G12 Screenshot + Caption
- Title: "Step 4 — Your Windows preset"
- Body: "Godot adds a Windows Desktop preset. Leave the options as they are — **Runnable** on, Architecture **x86_64**."
- Image: `D1B6S4.png` — Windows Desktop preset, Options tab.
- Notes: —

#### Slide D2-S104 — Export 5: if a red error shows up
- Format: G12 Screenshot + Caption
- Title: "Step 5 — If a red error shows up"
- Body: "If you see **'No export template found'**, click **Manage Export Templates**."
- Image: `D1B6S5.png` — red error + Manage Export Templates link.
- Notes: One-time per-machine install. If templates were pre-installed, kids won't hit this.

#### Slide D2-S105 — Export 6: install the templates
- Format: G12 Screenshot + Caption
- Title: "Step 6 — Download the templates"
- Body: "Click **Download and Install**. Let it finish, then close."
- Image: `D1B6S6.png` — Export Template Manager, Download and Install button.
- Notes: —

#### Slide D2-S106 — Export 7: name it and save
- Format: G12 Screenshot + Caption
- Title: "Step 7 — Name it and Save"
- Body: "Click **Export Project**, type a name (e.g. `Day 2 - Maze`), pick your folder, and click **Save**."
- Image: `D1B6S7.png` — Save dialog with filename.
- Notes: —

#### Slide D2-S107 — Export 8: your game is a real program
- Format: G12 Screenshot + Caption
- Title: "Step 8 — Double-click and play"
- Body: "Godot writes your `.exe` plus a `.pck` data file. Double-click the `.exe` — your maze game runs with no Godot needed. Keep the two files together."
- Image: `D1B6S8.png` — File Explorer showing .exe + .pck.
- Notes: the .exe needs the .pck beside it — copy both if you move them.

---

### 10.8 Day closer (slide S108)

#### Slide D2-S108 — Tomorrow: defend your base
- Format: G02 Timeline / Closer
- Title: "Tomorrow: defend your base"
- Body: "1990s. Tower & base defense. We go deeper on **functions** and meet **lists** — to spawn waves of enemies and the towers that stop them."
- Image: optional tower-defense teaser (placeholder OK).
- Notes: tease Day 3's genre and concepts.

> **Status**: structural draft. Order + content topics + metaphors are locked at this level. Per-slide expansion (matching D1 §10 schema verbatim — title / body / image / notes per slide) is the next pass, gated on:
> (a) Per-chunk RHS prose goal statement options (pending user pick — options to follow in chat).
> (b) Historical-context slide content sourcing for Pac-Man (1980 revolutionary background).
> (c) Day tab color for D2 (pending brand pack).
>
> The python-pptx build chat should NOT consume this draft. Per-slide expansion pass must land first.

