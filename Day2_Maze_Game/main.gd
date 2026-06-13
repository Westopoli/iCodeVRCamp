extends Node2D

# ============================================================
#  DAY 2 — MAZE (PAC-MAN CLONE)
#
#  Today's tools: LOOPS (for, while) and FUNCTIONS (write your
#  own, give them inputs, get answers back).
#
#  The game: chomp every dot in the maze to win. 3 ghosts patrol
#  the halls — if one touches you, you lose a life. You start
#  with 3 lives. Game over at 0.
#
#  The maze is 28 tiles wide and 31 tall — same shape as the
#  original 1980 Pac-Man arcade cabinet. Each tile is 16 pixels.
# ============================================================

# --- maze geometry ---
const TILE := 16
const MAZE_W := 28
const MAZE_H := 31
const STEP_TIME := 0.15        # seconds per one-tile slide (player)
const GHOST_STEP_TIME := 0.22  # ghosts slide slower than player
const GHOST_RELEASE_DELAY := 2.0  # seconds before ghosts start moving

# Tunnel rows: y-coordinates where stepping off the left/right edge
# wraps to the other side (classic Pac-Man tunnel). Off-grid cells on
# any OTHER row are treated as walls so nothing walks into the void.
const TUNNEL_ROWS := [13]

# --- player starting tile (classic Pac-Man spawn row) ---
const PLAYER_START := Vector2i(14, 12)

# --- Final Challenge toggle ---
# Flip this to true AFTER you fill in ghost_personalities.gd.
# When true, the 3 base ghosts get replaced by 4 personality ghosts.
const PERSONALITY_MODE_ENABLED := false

# --- nodes wired up in Main.tscn (already done for you) ---
@onready var wall_layer: TileMapLayer = $Walls
@onready var dot_layer: TileMapLayer = $Dots
@onready var player: Node2D = $Player
@onready var pen_marker: Marker2D = $GhostPen
@onready var lives_label: Label = $UI/LivesLabel
@onready var dots_label: Label = $UI/DotsLabel
@onready var game_over_panel: Panel = $UI/GameOverPanel
@onready var game_over_label: Label = $UI/GameOverPanel/Label

# --- game state ---
var player_lives := 3
var dots_remaining := 0
var ghosts := []
var player_cell := PLAYER_START
var player_moving := false
var current_dir := Vector2i.ZERO
var queued_dir := Vector2i.ZERO
var game_active := true
var ghost_release_timer := 0.0
var fc_node: Node = null   # holds ghost_personalities.gd instance when PERSONALITY_MODE_ENABLED


func _ready():
	game_over_panel.visible = false
	player.position = cell_to_world(player_cell)

	# TODO #1: Spawn 3 ghosts side by side in the ghost pen. Use a `for` loop so we
	# write the spawn call once instead of three times. When you run the game, you
	# should see 3 red squares lined up inside the pen.
	#
	# Given:
	#   - spawn_ghost_at(pos)   — spawns one ghost at a world position
	#   - ghost_spawn_pos(i)    — returns the world position for the i-th ghost
	#
	# Syntax:
	#   - for i in range(3):
	#@todo
	for i in range(3):
		spawn_ghost_at(ghost_spawn_pos(i))
	#@end

	# TODO #3a: Call the `count_dots()` function you'll write below (3b) and remember
	# the answer in `dots_remaining`. This number is what the win check counts down
	# to zero.
	#
	# Given:
	#   - dots_remaining   — the variable to store the count in
	#   - count_dots()     — the function you write in #3b (returns total dot count)
	#@todo
	dots_remaining = count_dots()
	#@end

	# Pre-given: Final Challenge boot-up. If you flipped
	# PERSONALITY_MODE_ENABLED to true, this swaps the 3 base ghosts
	# for 4 personality ghosts.
	if PERSONALITY_MODE_ENABLED:
		var fc_script = load("res://ghost_personalities.gd")
		fc_node = fc_script.new()
		fc_node.main = self
		fc_node.ghosts = ghosts
		add_child(fc_node)
		fc_node.clear_base_ghosts()
		fc_node.spawn_personality_ghosts()

	update_ui()


func _process(delta):
	if not game_active:
		return   # game over / win — freeze everything

	# read keyboard direction every frame — queue it for the next tile.
	# Pac-Man keeps gliding in the last direction; new input only kicks
	# in when the player reaches the next tile centre.
	if Input.is_action_pressed("ui_left"):       queued_dir = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right"):    queued_dir = Vector2i.RIGHT
	elif Input.is_action_pressed("ui_up"):       queued_dir = Vector2i.UP
	elif Input.is_action_pressed("ui_down"):     queued_dir = Vector2i.DOWN

	if not player_moving:
		try_step()

	ghost_release_timer += delta
	if ghost_release_timer < GHOST_RELEASE_DELAY:
		return   # let player get a head start

	# Pre-given: Final Challenge routing. When personality mode is on,
	# the FC file's step_all_personality_ghosts() takes over (you write
	# it as FC-2 in ghost_personalities.gd).
	if PERSONALITY_MODE_ENABLED:
		fc_node.step_all_personality_ghosts()
	else:
		# TODO #2: Each frame, walk through every ghost in the `ghosts` list and tell it
		# to take one step. After this chunk (and the 2-second release delay), the ghosts
		# start patrolling instead of standing still in the pen.
		#
		# Given:
		#   - ghosts         — the list of all active ghost nodes
		#   - step_ghost(ghost)   — makes one ghost take one step
		#
		# Syntax:
		#   - for item in list:
		#@todo
		for ghost in ghosts:
			step_ghost(ghost)
		#@end

	check_ghost_collisions()


func try_step() -> void:
	# Pre-given caller for move_player(): prefer the most recently
	# pressed direction; if that way is walled, keep gliding in the
	# current direction; if that's walled too, stop.
	if queued_dir != Vector2i.ZERO and not hit_wall(player_cell + queued_dir):
		current_dir = queued_dir
		move_player(current_dir)
	elif current_dir != Vector2i.ZERO and not hit_wall(player_cell + current_dir):
		move_player(current_dir)
	else:
		current_dir = Vector2i.ZERO


# ============================================================
#  KID FUNCTIONS — you write these today.
# ============================================================

# TODO #4: Write a function called `reset_player()` that sends the player back
# to the starting tile and clears any leftover movement. The game calls this
# when a ghost catches the player.
#
# Given:
#   - PLAYER_START          — the starting tile coordinate (Vector2i)
#   - cell_to_world(cell)   — converts a tile coordinate to a world position
#   - player_cell           — current tile the player occupies
#   - player.position       — the player sprite's world position
#   - player_moving         — movement flag to clear (set to false)
#   - current_dir           — current movement direction to clear
#   - queued_dir            — queued movement direction to clear
#
# Syntax:
#   - Vector2i.ZERO   (empty direction — use to clear current_dir and queued_dir)
#   - func name() -> void:
#@todo
func reset_player() -> void:
	player_cell = PLAYER_START
	player.position = cell_to_world(player_cell)
	player_moving = false
	current_dir = Vector2i.ZERO
	queued_dir = Vector2i.ZERO
#@end


# TODO #5: Write the function that actually moves the player one tile in a given
# direction — but only if that direction isn't blocked by a wall. After this
# chunk, the arrow keys move the player around the maze.
#
# Given:
#   - player_cell           — the player's current tile coordinate
#   - hit_wall(cell)        — returns true if that cell is a wall (your #6)
#   - wrap_cell(cell)       — handles tunnel wrap at map edges
#   - step_player_to(cell)  — moves player_cell and slides the sprite
#
# Syntax:
#   - direction: Vector2i   (parameter type annotation)
#@todo
func move_player(direction: Vector2i) -> void:
	var next_cell := player_cell + direction
	if hit_wall(next_cell):
		return
	next_cell = wrap_cell(next_cell)
	step_player_to(next_cell)
#@end


# TODO #6: finish `func hit_wall(cell) -> bool`. The function should
# return true when `cell` is a wall and false when it's open floor.
# The off-grid + tunnel edge cases are pre-given for you (they use
# operators you haven't seen yet). YOUR JOB is the last part: when
# the cell IS inside the maze, ask the Walls layer whether a wall
# tile is painted at that cell, and return true/false accordingly.
# Useful: wall_layer.get_cell_source_id(cell) returns -1 when there
#         is NO tile at that cell. Any other number means a wall.
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
	# TODO #6: Write a function that looks at a tile position and reports back `true`
	# if it's a wall, `false` if it's open floor. Both the player and the ghosts use
	# this to know what they can walk through. (The off-grid edge cases above are
	# pre-given — your job is just the last part inside the maze.)
	#
	# Given:
	#   - wall_layer.get_cell_source_id(cell)   — returns -1 if no tile, any other number if wall
	#
	# Syntax:
	#   - -> bool   (return type annotation)
	#   - return source_id != -1
	#@todo
	var source_id := wall_layer.get_cell_source_id(cell)
	return source_id != -1
	#@end


# TODO #3b: Write a function that scans every tile in the maze, counts how many
# have a dot painted on them, and returns that total. This is the number the
# player has to chomp down to zero to win.
#
# Given:
#   - MAZE_W              — maze width in tiles
#   - MAZE_H              — maze height in tiles
#   - cell_has_dot(x, y)  — returns true if tile (x, y) has a dot
#
# Syntax:
#   - while x < limit:   (keeps looping until condition is false)
#   - -> int             (return type annotation)
#@todo
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
#@end


# ============================================================
#  HELPERS — pre-given. Read them if you want to know how the
#  game wires together, but you don't need to change anything.
# ============================================================

func cell_to_world(cell: Vector2i) -> Vector2:
	# centre of the tile, in pixels
	return Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)


func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / TILE), int(pos.y / TILE))


func ghost_spawn_pos(index: int) -> Vector2:
	# Where in the pen the index-th ghost should spawn.
	# Used by TODO #1.
	var offset := Vector2(index * TILE, 0)
	return pen_marker.position + offset


func cell_has_dot(x: int, y: int) -> bool:
	# True when the Dots layer has a tile painted at (x, y).
	# Used by TODO #3b.
	var cell := Vector2i(x, y)
	return dot_layer.get_cell_source_id(cell) != -1


func step_player_to(cell: Vector2i) -> void:
	# Update player_cell and slide the sprite to that cell's centre.
	# Used by TODO #5.
	player_cell = cell
	tween_player_to(cell_to_world(cell))


func wrap_cell(cell: Vector2i) -> Vector2i:
	# tunnel wrap: only horizontal, only on tunnel rows
	if cell.y in TUNNEL_ROWS:
		if cell.x < 0:
			cell.x = MAZE_W - 1
		elif cell.x >= MAZE_W:
			cell.x = 0
	return cell


func tween_player_to(target: Vector2) -> void:
	# slide the player from their current position to `target` over
	# STEP_TIME seconds. While sliding, ignore new input.
	player_moving = true
	var tween := create_tween()
	tween.tween_property(player, "position", target, STEP_TIME)
	tween.tween_callback(_on_player_arrived)


func _on_player_arrived() -> void:
	player_moving = false
	# if the tile we just arrived at had a dot, chomp it
	if dot_layer.get_cell_source_id(player_cell) != -1:
		dot_layer.erase_cell(player_cell)
		dots_remaining -= 1
		update_ui()
		if dots_remaining <= 0:
			you_win()
	# auto-continue gliding (Pac-Man classic feel)
	try_step()


func spawn_ghost_at(world_pos: Vector2) -> void:
	# placeholder ghost = red square; swap for a Kenney sprite later.
	var ghost := ColorRect.new()
	ghost.size = Vector2(TILE, TILE)
	ghost.color = Color(1.0, 0.3, 0.3)
	ghost.position = world_pos - Vector2(TILE / 2.0, TILE / 2.0)
	ghost.set_meta("cell", world_to_cell(world_pos))
	ghost.set_meta("dir", Vector2i.UP)
	ghost.set_meta("moving", false)
	add_child(ghost)
	ghosts.append(ghost)


func step_ghost(ghost) -> void:
	# called once per frame per ghost. If the ghost is mid-tween,
	# do nothing. Otherwise pick a direction (50% chase, 50% random)
	# and start a one-tile slide.
	if ghost.get_meta("moving"):
		return
	var cell: Vector2i = ghost.get_meta("cell")
	var last_dir: Vector2i = ghost.get_meta("dir")

	# build the list of directions the ghost can actually take:
	# anywhere that isn't a wall AND isn't a 180° flip
	var options := []
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if d == -last_dir:
			continue
		if not hit_wall(cell + d):
			options.append(d)
	if options.is_empty():
		# dead end — must reverse
		options.append(-last_dir)

	# 50% chase the player, 50% random
	var pick: Vector2i
	if randf() < 0.5:
		pick = direction_toward(cell, player_cell, options)
	else:
		pick = options[randi() % options.size()]

	var next_cell := wrap_cell(cell + pick)
	ghost.set_meta("cell", next_cell)
	ghost.set_meta("dir", pick)
	ghost.set_meta("moving", true)
	var tween := create_tween()
	var target := cell_to_world(next_cell) - Vector2(TILE / 2.0, TILE / 2.0)
	tween.tween_property(ghost, "position", target, GHOST_STEP_TIME)
	tween.tween_callback(_on_ghost_arrived.bind(ghost))


func _on_ghost_arrived(ghost) -> void:
	ghost.set_meta("moving", false)


func direction_toward(from: Vector2i, to: Vector2i, options: Array) -> Vector2i:
	# of the valid options, pick the one whose next step lands
	# closer to `to`.
	var best: Vector2i = options[0]
	var best_dist := 1e9
	for d in options:
		var step_cell: Vector2i = from + d
		var dist := (Vector2(step_cell) - Vector2(to)).length_squared()
		if dist < best_dist:
			best_dist = dist
			best = d
	return best


func check_ghost_collisions() -> void:
	for ghost in ghosts:
		if ghost.get_meta("cell") == player_cell:
			player_lives -= 1
			update_ui()
			if player_lives <= 0:
				game_over()
			else:
				reset_player()
				# Pre-given: Final Challenge routing for the ghost reset.
				if PERSONALITY_MODE_ENABLED:
					fc_node.reset_personality_ghosts()
				else:
					reset_ghosts()
			return


func reset_ghosts() -> void:
	ghost_release_timer = 0.0   # give the player a fresh head-start
	var i := 0
	while i < ghosts.size():
		var ghost = ghosts[i]
		var spawn_pos := pen_marker.position + Vector2(i * TILE, 0)
		ghost.position = spawn_pos - Vector2(TILE / 2.0, TILE / 2.0)
		ghost.set_meta("cell", world_to_cell(spawn_pos))
		ghost.set_meta("dir", Vector2i.UP)
		ghost.set_meta("moving", false)
		i += 1


func update_ui() -> void:
	lives_label.text = "Lives: " + str(player_lives)
	dots_label.text  = "Dots: " + str(dots_remaining)


func game_over() -> void:
	game_active = false
	game_over_panel.visible = true
	game_over_label.text = "GAME OVER\nPress R to restart"


func you_win() -> void:
	game_active = false
	game_over_panel.visible = true
	game_over_label.text = "YOU WIN!\nPress R to restart"


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
