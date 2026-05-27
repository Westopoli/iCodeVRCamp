# Day 2 — Maze (Pac-Man) — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 2 slide deck.
> Verified against `Day2_Maze/main.gd` + `ghost_personalities.gd` + `Main.tscn` +
> `PacmanTileSet.tres` on 2026-05-26. Instructor-facing companion is
> `Day2_Maze/INSTRUCTOR_NOTES.md`. Reads top-to-bottom as the day's lesson flow.

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

## 3. Chunk table — verified against `main.gd`

In lesson order (also BIBLE §4 order and `main.gd` file order):

| # | Concept | File location | Hole lines | Hole size |
|---|---|---|---|---|
| #1 | `for i in range(N)` | `main.gd:63-66` (in `_ready`) | 2 | tiny |
| #2 | `for item in list` | `main.gd:102-105` (in `_process`) | 2 | small |
| #3 (caller) | calling `count_dots()` | `main.gd:70-72` (in `_ready`) | 1 | tiny |
| #3 (body) | `while` loop scan | `main.gd:202-214` (whole `count_dots()` func) | 10 | medium |
| #4 | `func` no params | `main.gd:132-139` (whole `reset_player()`) | 5 | medium |
| #5 | `func` with param | `main.gd:154-162` (whole `move_player(direction)`) | 6 | medium |
| #6 | `func` returning bool | `main.gd:172-180` (whole `hit_wall(cell)`) | 5 | medium |

**Total**: 7 `#@todo`/`#@end` blocks across **6 conceptual chunks** (chunk #3 has two sites — caller in `_ready` + body of `count_dots()`).

---

## 4. Pre-coding setup

> Identical to Day 1's pre-coding setup — kids already know how to open a project, open a script, run, and read errors. Reuse Day 1 walkthroughs A/B/C/D for the Day 2 deck (re-target the project path to `Day2_Maze/`).
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
- **In-file location**: `main.gd:63-66`, inside `_ready()`, under `# TODO #1: spawn the ghost pen.`
- **Surrounding context**:
  ```gdscript
  func _ready():
      game_over_panel.visible = false
      player.position = cell_to_world(player_cell)

      # TODO #1: spawn the ghost pen. Make a `for` loop with `range(3)`
      # ...
      #@todo
  ```
- **As-typed code**:
  ```gdscript
  for i in range(3):
      spawn_ghost_at(pen_marker.position + Vector2(i * TILE, 0))
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
- **In-file location**: `main.gd:102-105`, inside `_process()`, under `# TODO #2: each frame, walk through every ghost in the ghosts list and call step_ghost(ghost) on it.`
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
- **In-file location**: `main.gd:70-72`, immediately under chunk #1.
- **As-typed code**:
  ```gdscript
  dots_remaining = count_dots()
  ```

#### 3b — Body (the `count_dots()` function itself)

- **Concept**: `while <condition>:` keeps running until the condition is false. Use it here to walk every tile of the grid with two nested loops.
- **Goal**: Write a function that scans every tile in the maze and counts how many of them have a dot painted on them, then returns that total. This is the number the player has to chomp down to zero to win.
- **Board example**:
  ```gdscript
  var n := 0
  while n < 5:
      print(n)
      n += 1
  ```
- **In-file location**: `main.gd:202-214`, under `# TODO #3: count_dots() — scan every tile in the maze with a WHILE loop`.
- **As-typed code**:
  ```gdscript
  func count_dots() -> int:
      var count := 0
      var x := 0
      while x < MAZE_W:
          var y := 0
          while y < MAZE_H:
              if dot_layer.get_cell_source_id(Vector2i(x, y)) != -1:
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
- **In-file location**: `main.gd:132-139`, under `# TODO #4: write reset_player() — no inputs, returns nothing.`
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
- **In-file location**: `main.gd:154-162`, under `# TODO #5: move_player(direction) takes a Vector2i...`
- **As-typed code**:
  ```gdscript
  func move_player(direction: Vector2i) -> void:
      var next_cell := player_cell + direction
      if hit_wall(next_cell):
          return
      next_cell = wrap_cell(next_cell)
      player_cell = next_cell
      tween_player_to(cell_to_world(player_cell))
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
- **In-file location**: `main.gd:172-180`, under `# TODO #6: hit_wall(cell) takes a tile position and RETURNS true if that tile is a wall, false if open floor.`
- **As-typed code**:
  ```gdscript
  func hit_wall(cell: Vector2i) -> bool:
      # off-grid cells are walls EXCEPT on tunnel rows (where wrapping is allowed)
      if cell.y < 0 or cell.y >= MAZE_H:
          return true
      if cell.x < 0 or cell.x >= MAZE_W:
          return not (cell.y in TUNNEL_ROWS)
      return wall_layer.get_cell_source_id(cell) != -1
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

## 7. Stretch goals — Final Challenge (`ghost_personalities.gd`)

> **What "stretch goals" means in this camp**: every day ends with a Final Challenge file. The FC tasks are **reworded versions of the morning chunks** — same concepts, new context. Repetition is the point: every FC hole drives a morning concept deeper, no new ideas required.

**File**: `ghost_personalities.gd`.
**Payoff**: replace the 3 generic 50/50-chase ghosts with the **4 authentic Pac-Man personalities** — Blinky (direct chaser), Pinky (ambusher 4 tiles ahead), Inky (uses Blinky + player vector), Clyde (chase when far, scatter when close).
**Hint level**: half-guided. Slides give the targeting rule per personality in prose + diagrams; the kid writes the code. No copy-along.

### Mirror map

| FC hole | Mirrors morning chunks | Concept practiced |
|---|---|---|
| FC-1 `target_for(ghost)` | #5 (func with param) + #6 (func returning a value) | Read meta, branch on value, return a target cell |
| FC-2 `should_scatter(ghost, player_cell)` | #5 (func with params) + #6 (func returning bool) | Two-param function returning bool |
| FC-3 `move_personality(ghost)` | #2 (loop) + #4 (func no return) + #5 (param) | Move-one-ghost using personality target |
| FC-4 `reset_personality_ghosts()` | #4 (func no params) | Re-spawn all 4 ghosts with personality tags |

### The 4 personalities (slides MUST cover these — kid reads from slides, writes code)

| Ghost | Colour | Targeting rule |
|---|---|---|
| **Blinky** | Red | Targets the player's current tile every frame. Most aggressive. |
| **Pinky** | Pink | Targets the tile **4 tiles ahead** of the player's facing direction (ambush). |
| **Inky** | Cyan | Take the tile 2 ahead of the player, double the vector from Blinky to that tile, target the doubled-vector endpoint. (Optional: simplify to "stays between Blinky and player".) |
| **Clyde** | Orange | If more than 8 tiles from the player → chase like Blinky. If within 8 tiles → scatter to the bottom-left corner of the maze. Moody. |

### Hole FC-1 — `target_for(ghost) -> Vector2i`

- **Concept reviewed**: function with parameter (#5), function returning a value (#6), reading `ghost.get_meta("personality")`.
- **Goal**: Return the tile that *this specific ghost* is aiming for right now, based on its personality. Blinky aims at the player. Pinky aims 4 tiles ahead. Inky aims at a tile computed from Blinky's position. Clyde aims at the player.
- **Expected solution** (one possible shape):
  ```gdscript
  func target_for(ghost) -> Vector2i:
      var personality: String = ghost.get_meta("personality")
      var main = ghost.get_parent()
      match personality:
          BLINKY:
              return main.player_cell
          PINKY:
              return main.player_cell + main.current_dir * 4
          INKY:
              var two_ahead: Vector2i = main.player_cell + main.current_dir * 2
              var blinky_cell: Vector2i = main.ghosts[0].get_meta("cell")
              return two_ahead + (two_ahead - blinky_cell)
          CLYDE:
              return main.player_cell
      return main.player_cell
  ```
### Hole FC-2 — `should_scatter(ghost, player_cell) -> bool`

- **Concept reviewed**: function with two params (#5 generalised), function returning a bool (#6).
- **Goal**: Return `true` if this ghost should be in "scatter" mode right now (running to a corner instead of chasing). Only Clyde scatters, and only when he's within 8 tiles of the player.
- **Expected solution**:
  ```gdscript
  func should_scatter(ghost, player_cell: Vector2i) -> bool:
      if ghost.get_meta("personality") != CLYDE:
          return false
      var ghost_cell: Vector2i = ghost.get_meta("cell")
      var dist := (Vector2(ghost_cell) - Vector2(player_cell)).length()
      return dist < 8.0
  ```
### Hole FC-3 — `move_personality(ghost)`

- **Concept reviewed**: ties #2 (loop), #4 (function), #5 (param), #6 (return).
- **Goal**: Move one ghost one tile, using its personality's target. This is the replacement for the generic 50/50-chase `step_ghost` in `main.gd` — instead of "maybe chase, maybe random," this function always steers toward `target_for(ghost)`.
### Hole FC-4 — `reset_personality_ghosts()`

- **Concept reviewed**: function with no params (#4).
- **Goal**: Send all 4 personality ghosts back to the pen with their personality tags still attached. The game calls this when the player dies and respawns.
### Where to hook in

The header comment in `ghost_personalities.gd` lays out 3 options. Most natural:

1. Change `_ready()`'s `range(3)` → `range(4)` and tag each ghost with a `personality` meta.
2. Rewrite or replace `step_ghost()`'s 50/50 rule to call `move_personality(ghost)` from this file.

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

- [x] All 7 `#@todo` blocks in `main.gd` mapped to chunk rows in §3.
- [x] All 4 `#@todo` blocks in `ghost_personalities.gd` documented in §7.
- [x] As-typed code blocks byte-identical to source between `#@todo`/`#@end` markers.
- [x] Scene tree in §2 matches `Main.tscn` node names + types.
- [x] Asset reference (§8) atlas path matches `PacmanTileSet.tres` (`res://assets/Tilemap/tilemap_packed.png`).
- [x] Constants table (§2) matches `main.gd` lines 18-31.
- [x] Narrative arc card (§1) matches BIBLE §15 universal narrative arc memory (Pac-Man = 1980 = Namco).
- [x] Chunk order in §3 + §5 matches BIBLE §4 D2 order.
- [x] No "stretch" tag on any morning chunk; "Stretch goals" applies only to §7 FC.
- [x] Each walkthrough (Pre-coding setup + Personalization + FC) appears exactly once at its lesson position.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 2." Output should require no follow-up clarification.
