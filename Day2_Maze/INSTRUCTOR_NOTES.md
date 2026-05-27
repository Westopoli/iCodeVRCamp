# Day 2 — Maze (Pac-Man) — Instructor Notes

Reference doc for the **instructor**, not the students. Covers the Godot
features used in this scaffold that the kids don't need to understand to
finish the chunks, but that you need to be confident about when they ask.

Companion to the BIBLE.md §15 slide-requirements list.

---

## What the kids actually do today

Six TODO chunks in `main.gd`:

| # | Concept | Where in main.gd | Hole size |
|---|---|---|---|
| 1 | `for i in range(3)` | `_ready()` | 1 line |
| 2 | `for ghost in ghosts` | `_process()` | 1-2 lines (**stretch**) |
| 3 | `while` (nested scan) | `count_dots()` | 5-7 lines (**stretch**) |
| 4 | `func` no params | `reset_player()` | 3-4 lines |
| 5 | `func` with param | `move_player(direction)` | 5-7 lines (**stretch**) |
| 6 | `func` returning bool | `hit_wall(cell)` | 1-2 lines |

`#@todo`/`#@end` markers in the source mean: Template ZIP has bare
`# TODO #N` comments only, Complete ZIP has working code. Template **does
not compile** until kids fill chunks — deliberate, the missing-symbol
error is the debugging hook.

---

## TileMap / TileMapLayer (the big new Godot concept today)

We're using **TileMapLayer** nodes, not the legacy single-`TileMap` node.
Godot 4.3+ recommends one node per layer because it scales better.

### What's a TileSet vs a TileMap vs a TileMapLayer?

- **TileSet** — the *palette*. A resource (saved as `.tres` or inline in
  the scene) that takes a PNG atlas and chops it into addressable tiles.
  This is where you say "this 16×16 region of the PNG is tile #5; it has
  collision; it's a wall."
- **TileMapLayer** — a *node in the scene* that paints tiles from a
  TileSet onto a 2D grid. One layer = one painted surface. We use two:
  `Walls` (collision tiles) and `Dots` (the pellets to chomp).

The Kenney Tiny Dungeon `tilemap_packed.png` is one big atlas of
16×16 tiles in a grid. You wire it once into a TileSet, then both
layers reference that same TileSet.

### One-time TileSet setup (you do this once, in the editor)

1. Open `Day2_Maze` in Godot 4.6.3.
2. Click the `Walls` node in the scene tree.
3. In the Inspector, find the `Tile Set` property → click `<empty>` →
   `New TileSet`. A blank TileSet resource is created and assigned.
4. At the bottom of the editor, the **TileSet** panel pops up. Switch
   to the `Sources` tab on the left.
5. Click `+` → **Atlas**. A file picker opens. Choose
   `assets/Tilemap/tilemap_packed.png`.
6. In the panel that appears on the right:
   - `Texture Region Size` = `16 × 16` (Kenney tiles).
   - `Margins` = `0, 0`, `Separation` = `0, 0`.
7. Godot will ask "auto-create tiles?" — say yes. Every non-empty
   16×16 region becomes an addressable tile.
8. Click on the *wall* tile in the atlas (pick whichever stone block
   looks Pac-Man-ish). Then in the **Setup** dropdown above the atlas
   image, switch to **Paint** → **Physics → Layer 0** (or just leave
   collision off for now — we use TileMap presence, not Godot physics,
   to check walls in this game).
9. Click the `Dots` node. Set its `Tile Set` to the **same** TileSet
   you just made (drag from the FileSystem panel, or pick it from the
   Inspector's resource browser).
10. Now both layers share the palette. Walls layer = paint wall tiles
    on it. Dots layer = paint dot tiles on it.

### How the kid's code uses it

```gdscript
wall_layer.get_cell_source_id(cell)   # returns -1 if no tile there
dot_layer.get_cell_source_id(cell)    # same — used to count dots
dot_layer.erase_cell(cell)            # called when player chomps a dot
```

That's the *entire* API surface kids touch. The slides should show
just these three calls.

### Painting the maze

After the TileSet is wired, click the `Walls` TileMapLayer node, then
click somewhere in the 2D viewport. The TileSet panel switches to
**paint mode** — drag-paint walls across the grid. Switch to the `Dots`
layer, drop dot tiles in every corridor.

**Reference layout:** Classic Pac-Man maze is 28 columns × 31 rows.
You can grab the canonical layout off Wikipedia or draw your own.
Per BIBLE Q9=A, *kids* paint their own from blank — so for the
scaffold ZIP, you may want to ship the maze near-empty with just
walls around the border and the ghost pen drawn in, so the painting
is genuinely the kid's personalization step.

---

## CharacterBody2D vs Node2D (note: we don't use the former)

BIBLE Q1=B locked "TileMap + CharacterBody2D + `move_and_collide`."
Q5=A locked grid-snap movement. **These conflict.** Grid-snap moves
the player by tween between tile centres, not by physics integration.
There's no use for `move_and_collide`.

Resolution this build: **Player is `Node2D`, not `CharacterBody2D`.**
Wall collision is checked manually via the kid's `hit_wall(cell)`
function (TODO #6) against the TileMap. `move_and_collide` saved for
D3+ where free-motion makes sense.

If you want to bring it back to honour the lock literally, swap the
Player node type to `CharacterBody2D` in `Main.tscn` and ignore the
physics — but it adds nothing to this game. Worth surfacing on the
slides as "the Godot-recommended way for moving characters, which
we'll use properly in Day 3 / Day 4."

---

## Grid-snap movement (the tween helper)

Pre-given in `main.gd` as `tween_player_to(target)`:

```gdscript
func tween_player_to(target: Vector2) -> void:
	player_moving = true
	var tween := create_tween()
	tween.tween_property(player, "position", target, STEP_TIME)
	tween.tween_callback(_on_player_arrived)
```

- Sets a `player_moving` flag so `_process` ignores input while
  the slide is in progress (no diagonal cheating, no input queue).
- The `_on_player_arrived` callback clears the flag AND handles dot
  eating (any dot under the cell you just landed on gets erased,
  `dots_remaining` ticks down).
- 0.15 s per tile = roughly 6-7 tiles/sec, similar to Pac-Man speed.

Ghost movement uses the same pattern in `step_ghost()` (also
pre-given). 50% directed (toward player tile), 50% random valid
direction. Anti-180° rule means ghosts don't immediately reverse —
classic Pac-Man behaviour.

---

## Final Challenge — ghost_personalities.gd

Ships in the scaffold as a separate file. **Not** on the slide deck
walkthrough. Kid opts in.

It re-implements the 3 ghosts as the 4 authentic Pac-Man personalities
(Blinky / Pinky / Inky / Clyde). The 4 personality algorithms MUST be
on the slides — see BIBLE §15. Kid writes the code from the algorithm
description, not from sample code.

Hint level vs D1: more guidance than D1 (which was unguided). Slides
spell out targeting rules in plain English + diagrams. Code is on the
kid.

---

## Common kid stuck-points (anticipate these)

- **"Why is my ghost just sitting there?"** TileMap not painted yet,
  or `hit_wall` returns true for *every* tile because every cell in
  the TileMap has something on it. Check the dot layer is separate
  from the wall layer.
- **"My count_dots returns 0."** `dot_layer.get_cell_source_id(cell)`
  vs `wall_layer.get_cell_source_id(cell)` — easy to grab the wrong
  layer. Or the scan bounds `< MAZE_W` / `< MAZE_H` got swapped to
  `<= ` which goes one past.
- **"Player moves into walls."** They probably forgot the
  `if hit_wall(next_cell): return` guard in `move_player`.
- **"Game over screen shows on launch."** `game_over_panel.visible`
  not set false in `_ready()`. Already done in the scaffold but if
  they touch it, that's where to look.
- **"Ghosts all stack on top of each other."** TODO #1's `i * TILE`
  offset got dropped — the loop spawned 3 ghosts at the same spot.

---

## Build verification

From the repo root:

```powershell
.\build\build_templates.ps1 -Day Day2_Maze
```

Produces:
- `dist/Day2_Maze_Complete.zip` — full game source.
- `dist/Day2_Maze_Template.zip` — same minus the `#@todo` blocks
  (won't compile until kids fill chunks).

Both exclude `.godot/` (machine-specific import cache, regenerated
on first open).
