extends Node

# ============================================================
#  FINAL CHALLENGE — UNLOCK THE 4 PAC-MAN GHOSTS
#
#  In the morning's game, 3 ghosts all chase you the same way:
#  half the time they head toward you, half the time they pick
#  a random direction. They're identical. Real Pac-Man has FOUR
#  ghosts and each one has a PERSONALITY:
#
#    BLINKY (red)    — chaser. Always heads for your tile.
#    PINKY  (pink)   — ambusher. Aims 4 tiles ahead of you.
#    INKY   (cyan)   — tricky. Uses Blinky's position to flank.
#    CLYDE  (orange) — moody. Chases when far, scatters when close.
#
#  YOU DON'T HAVE TO WRITE THE TARGETING MATH.
#  ==========================================
#  Pinky's ambush, Inky's flank, Clyde's scatter rule, the per-ghost
#  routing, and the reset are ALL written for you below as pre-given
#  helpers. Your job is one thing — the same thing you did all morning:
#
#    write ONE loop  — to spawn the 4 personality ghosts at the start.
#
#  That single loop flips the whole game from 3 plain ghosts to 4
#  ghosts with real Pac-Man personalities.
#
#  HOW TO TURN IT ON
#  =================
#  Once you've filled in the FINAL CHALLENGE loop in this file:
#  1. Open main.gd.
#  2. Change `const PERSONALITY_MODE_ENABLED := false` to `true`.
#  3. Run the game.
#  4. Watch 4 personality ghosts replace the 3 base ghosts.
# ============================================================


# --- references back to main.gd, set during the FC boot-up ---
# Pre-given. main.gd assigns these when PERSONALITY_MODE_ENABLED.
var main: Node = null
var ghosts: Array = []


# --- personality tags ---
# Pre-given. Used as ghost.set_meta("personality", BLINKY) etc.
const BLINKY := "blinky"
const PINKY  := "pinky"
const INKY   := "inky"
const CLYDE  := "clyde"

const PERSONALITIES := [BLINKY, PINKY, INKY, CLYDE]
const PERSONALITY_COUNT := 4

# Where Clyde flees to when scared (bottom-left corner of the maze).
const SCATTER_CORNER := Vector2i(1, 29)

# Ghost body colors.
const GHOST_COLORS := {
	"blinky": Color(1.0, 0.3, 0.3),
	"pinky":  Color(1.0, 0.7, 0.9),
	"inky":   Color(0.3, 0.8, 1.0),
	"clyde":  Color(1.0, 0.7, 0.3),
}


# ============================================================
#  PRE-GIVEN HELPERS — already written. Read if you want to,
#  but you don't need to change anything in this section.
# ============================================================

# Per-personality target tile. Each returns the cell this kind of
# ghost is aiming for right now.

func blinky_target(_ghost) -> Vector2i:
	# Blinky: head straight for the player.
	return main.player_cell


func pinky_target(_ghost) -> Vector2i:
	# Pinky: aim 4 tiles ahead of where the player is facing.
	var ahead: Vector2i = main.player_cell + main.current_dir * 4
	return ahead


func inky_target(_ghost) -> Vector2i:
	# Inky: take the tile 2 ahead of the player, then bounce it
	# through Blinky's position to flank from the opposite side.
	var two_ahead: Vector2i = main.player_cell + main.current_dir * 2
	var blinky := find_blinky()
	var blinky_cell: Vector2i
	if blinky == null:
		blinky_cell = main.player_cell
	else:
		blinky_cell = blinky.get_meta("cell")
	return two_ahead + (two_ahead - blinky_cell)


func clyde_target(ghost) -> Vector2i:
	# Clyde: chase the player when far, scatter when close.
	# (Uses your TODO FC-6 is_clyde_close.)
	if is_clyde_close(ghost):
		return SCATTER_CORNER
	return main.player_cell


func distance_to_player(ghost) -> float:
	# Tile-distance from this ghost to the player.
	var gcell: Vector2i = ghost.get_meta("cell")
	return Vector2(gcell).distance_to(Vector2(main.player_cell))


func find_blinky() -> Node:
	# Find the red ghost (Blinky) in the ghosts list. null if not found.
	for ghost in ghosts:
		if ghost.get_meta("personality") == BLINKY:
			return ghost
	return null


func step_ghost_toward(ghost, target_cell: Vector2i) -> void:
	# Move one ghost one tile, choosing the direction whose next
	# cell lands closest to target_cell. Mirrors main.gd's step_ghost
	# but with a personality target instead of the 50/50 rule.
	if ghost.get_meta("moving"):
		return
	var cell: Vector2i = ghost.get_meta("cell")
	var last_dir: Vector2i = ghost.get_meta("dir")
	var options := []
	for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if d == -last_dir:
			continue
		if not main.hit_wall(cell + d):
			options.append(d)
	if options.is_empty():
		options.append(-last_dir)
	var best: Vector2i = options[0]
	var best_dist := 1e9
	for d in options:
		var step_cell: Vector2i = cell + d
		var dist := (Vector2(step_cell) - Vector2(target_cell)).length_squared()
		if dist < best_dist:
			best_dist = dist
			best = d
	var next_cell: Vector2i = main.wrap_cell(cell + best)
	ghost.set_meta("cell", next_cell)
	ghost.set_meta("dir", best)
	ghost.set_meta("moving", true)
	var tween := create_tween()
	var target_pos: Vector2 = main.cell_to_world(next_cell) - Vector2(main.TILE / 2.0, main.TILE / 2.0)
	tween.tween_property(ghost, "position", target_pos, main.GHOST_STEP_TIME)
	tween.tween_callback(_on_ghost_arrived.bind(ghost))


func _on_ghost_arrived(ghost) -> void:
	ghost.set_meta("moving", false)


func step_personality(ghost) -> void:
	# Step a single ghost one tile using its personality target.
	# (Uses your TODO FC-5 target_for.)
	if ghost.get_meta("moving"):
		return
	var target := target_for(ghost)
	step_ghost_toward(ghost, target)


func make_personality_ghost(world_pos: Vector2, personality: String) -> void:
	# Create one personality ghost as a colored ColorRect and add it
	# to the scene + ghosts list.
	var ghost := ColorRect.new()
	ghost.size = Vector2(main.TILE, main.TILE)
	ghost.color = GHOST_COLORS[personality]
	ghost.position = world_pos - Vector2(main.TILE / 2.0, main.TILE / 2.0)
	ghost.set_meta("cell", main.world_to_cell(world_pos))
	ghost.set_meta("dir", Vector2i.UP)
	ghost.set_meta("moving", false)
	ghost.set_meta("personality", personality)
	main.add_child(ghost)
	ghosts.append(ghost)


func spawn_one_personality(index: int) -> void:
	# Spawn the index-th personality ghost in the pen.
	# Wraps make_personality_ghost so your TODO FC-1 stays a clean loop.
	var personality: String = PERSONALITIES[index]
	var world_pos: Vector2 = main.pen_marker.position + Vector2(index * main.TILE, 0)
	make_personality_ghost(world_pos, personality)


func respawn_personality_ghost(ghost, index: int) -> void:
	# Send one ghost back to pen slot `index`. Personality tag stays.
	var spawn_pos: Vector2 = main.pen_marker.position + Vector2(index * main.TILE, 0)
	ghost.position = spawn_pos - Vector2(main.TILE / 2.0, main.TILE / 2.0)
	ghost.set_meta("cell", main.world_to_cell(spawn_pos))
	ghost.set_meta("dir", Vector2i.UP)
	ghost.set_meta("moving", false)


func clear_base_ghosts() -> void:
	# Remove the 3 base ghosts main.gd's TODO #1 spawned so the
	# personality ghosts can take over.
	for ghost in ghosts:
		ghost.queue_free()
	ghosts.clear()


# ============================================================
#  YOUR JOB — one loop. Everything else is pre-given.
# ============================================================

# FINAL CHALLENGE: Spawn the 4 personality ghosts. Write a loop that runs
# PERSONALITY_COUNT times and calls spawn_one_personality(i) each time —
# that swaps in Blinky, Pinky, Inky, and Clyde.
# Syntax:
#   for i in range(PERSONALITY_COUNT):
#@todo
func spawn_personality_ghosts() -> void:
	for i in range(PERSONALITY_COUNT):
		spawn_one_personality(i)
#@end


# --- Pre-given: step every personality ghost once per frame. ---
func step_all_personality_ghosts() -> void:
	for ghost in ghosts:
		step_personality(ghost)


# --- Pre-given: count how many ghosts have a given personality. ---
func count_ghosts_of(personality: String) -> int:
	var count := 0
	for ghost in ghosts:
		if ghost.get_meta("personality") == personality:
			count += 1
	return count


# --- Pre-given: send every personality ghost back to its pen slot. ---
func reset_personality_ghosts() -> void:
	var i := 0
	for ghost in ghosts:
		respawn_personality_ghost(ghost, i)
		i += 1


# --- Pre-given: route a ghost to the right target based on its
# personality (Blinky chases, Pinky ambushes, Inky flanks, Clyde scatters). ---
func target_for(ghost) -> Vector2i:
	var p = ghost.get_meta("personality")
	if p == BLINKY:
		return blinky_target(ghost)
	if p == PINKY:
		return pinky_target(ghost)
	if p == INKY:
		return inky_target(ghost)
	return clyde_target(ghost)


# --- Pre-given: true when this ghost is within 8 tiles of the player
# (Clyde uses this to decide whether to scatter). ---
func is_clyde_close(ghost) -> bool:
	var d := distance_to_player(ghost)
	return d < 8.0
