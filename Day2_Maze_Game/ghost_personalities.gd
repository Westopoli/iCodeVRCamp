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
#  Pinky's ambush, Inky's flank, and Clyde's scatter rule are all
#  written for you below in pre-given helper functions. Your job is
#  to WIRE THE PERSONALITIES TOGETHER using only what you learned
#  this morning:
#
#    for i in range(N)     — to spawn 4 ghosts at start
#    for x in list         — to step each ghost every frame
#    while + counter       — to count ghosts of a personality
#    func with no params   — to reset all ghosts back to the pen
#    func with a param     — to route each ghost to its target
#    func returning a bool — to ask "is Clyde close to the player?"
#
#  Every TODO below maps to a chunk you already wrote this
#  morning in main.gd. Your slides have the full mirror map.
#
#  HOW TO TURN IT ON
#  =================
#  Once you've filled every #@todo block in this file:
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
#  YOUR JOB — fill these six TODOs.
# ============================================================

# FINAL CHALLENGE FC-1: Write spawn_personality_ghosts() — make one ghost appear per personality (PERSONALITY_COUNT total). Mirrors morning chunk #1.
#
# Syntax:
#   - for i in range(N):
#
# Write it — one # line per line of code you'll write:
# func spawn_personality_ghosts() -> void:
#     for i in range(PERSONALITY_COUNT):
#         spawn_one_personality(i)
#@todo
func spawn_personality_ghosts() -> void:
	for i in range(PERSONALITY_COUNT):
		spawn_one_personality(i)
#@end


# FINAL CHALLENGE FC-2: Write step_all_personality_ghosts() — make every ghost in the ghosts list take one step. Mirrors morning chunk #2.
#
# Syntax:
#   - for item in list:
#
# Write it — one # line per line of code you'll write:
# func step_all_personality_ghosts() -> void:
#     for ghost in ghosts:
#         step_personality(ghost)
#@todo
func step_all_personality_ghosts() -> void:
	for ghost in ghosts:
		step_personality(ghost)
#@end


# FINAL CHALLENGE FC-3: Write count_ghosts_of(personality) — return how many ghosts in the ghosts list have that personality tag. Mirrors morning chunk #3.
#
# Syntax:
#   - func name(personality: String) -> int:
#   - for item in list:
#   - if condition:
#
# Write it — one # line per line of code you'll write:
# func count_ghosts_of(personality: String) -> int:
#     start count at 0
#     for each ghost in ghosts:
#         if ghost.get_meta("personality") == personality:
#             add 1 to count
#     return count
#@todo
func count_ghosts_of(personality: String) -> int:
	var count := 0
	for ghost in ghosts:
		if ghost.get_meta("personality") == personality:
			count += 1
	return count
#@end


# FINAL CHALLENGE FC-4: Write reset_personality_ghosts() — send every ghost back to the pen. Mirrors morning chunk #4.
#
# Syntax:
#   - func name() -> void:
#   - for item in list:
#
# Write it — one # line per line of code you'll write:
# func reset_personality_ghosts() -> void:
#     start i at 0
#     for each ghost in ghosts:
#         call respawn_personality_ghost(ghost, i)
#         add 1 to i
#@todo
func reset_personality_ghosts() -> void:
	var i := 0
	for ghost in ghosts:
		respawn_personality_ghost(ghost, i)
		i += 1
#@end


# FINAL CHALLENGE FC-5: Write target_for(ghost) — return the tile this ghost is aiming for, based on its personality. Mirrors morning chunk #5.
#
# Syntax:
#   - func name(ghost) -> Vector2i:
#   - if condition:
#   - return value
#
# Write it — one # line per line of code you'll write:
# func target_for(ghost) -> Vector2i:
#     read p from ghost.get_meta("personality")
#     if p == BLINKY:
#         return blinky_target(ghost)
#     if p == PINKY:
#         return pinky_target(ghost)
#     if p == INKY:
#         return inky_target(ghost)
#     return clyde_target(ghost)
#@todo
func target_for(ghost) -> Vector2i:
	var p = ghost.get_meta("personality")
	if p == BLINKY:
		return blinky_target(ghost)
	if p == PINKY:
		return pinky_target(ghost)
	if p == INKY:
		return inky_target(ghost)
	return clyde_target(ghost)
#@end


# FINAL CHALLENGE FC-6: Write is_clyde_close(ghost) — report back true when this ghost is closer than 8 tiles to the player. Mirrors morning chunk #6.
#
# Syntax:
#   - func name(ghost) -> bool:
#   - return value
#
# Write it — one # line per line of code you'll write:
# func is_clyde_close(ghost) -> bool:
#     read d from distance_to_player(ghost)
#     return true if d < 8.0
#@todo
func is_clyde_close(ghost) -> bool:
	var d := distance_to_player(ghost)
	return d < 8.0
#@end
