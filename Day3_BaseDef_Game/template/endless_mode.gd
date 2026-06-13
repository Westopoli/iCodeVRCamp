extends Node

# ============================================================
#  FINAL CHALLENGE — ENDLESS MODE
#
#  The morning game had 8 waves and then stopped.  Endless mode
#  rips out the wave list and replaces it with infinite spawning
#  that gets harder over time.
#
#  Each of the 4 holes below is ALMOST EXACTLY something you
#  already wrote this morning, just reworded for endless mode.
#  You don't need any new ideas — only what's already in your
#  head.
#
#  Mirror map:
#      FC-1  ←  TODO #1  (declare a few state variables)
#      FC-2  ←  TODO #2a (append to enemies via spawn helper)
#      FC-3  ←  TODO #5a (write a function that returns ONE thing)
#      FC-4  ←  TODO #7  (size() check + escalation)
#
#  To switch the game into endless mode:
#    open `main.gd`, find `const ENDLESS_MODE := false`, and
#    change false → true.  Save, play.
# ============================================================

# This script gets attached to the Main node when ENDLESS_MODE is
# on (instructor wiring).  It calls into helpers already living
# in main.gd via @onready.
@onready var main: Node = get_parent()


# FC-1: Declare 5 top-level variables for endless mode state.
# Mirrors morning chunk #1 (variable declarations).
#
# Given:
#   - SPAWN_INTERVAL_START   — the starting spawn interval constant
#
# Syntax:
#   - var name: float = value
#@todo


# ============================================================
#  Helper called every frame by main.gd's _process when
#  ENDLESS_MODE is true.
# ============================================================
func endless_tick(delta: float) -> void:
	spawn_timer_tick(delta)
	if main.enemies.size() == 0:
		on_screen_clear()


# FC-2a: Append `t` (a type string) to `spawn_queue`.
# Mirrors morning chunk #2a (.append).
#
# Given:
#   - spawn_queue   — the pending-spawn list
#
# Syntax:
#   - list.append(item)
func spawn_timer_tick(delta: float) -> void:
	#@todo


# FC-5a: Return the enemy with the highest `.speed`. The pre-given init
# (fastest = null, best_speed = 0.0) and the pre-given `return fastest`
# sandwich your hole — write only the loop-and-update section.
# Mirrors morning chunk #5a (function returns ONE from a list).
#
# Given:
#   - main.enemies   — list of active enemies
#   - fastest        — pre-initialized to null (update as you scan)
#   - best_speed     — pre-initialized to 0.0 (update as you scan)
#   - e.speed        — an enemy's current speed
func pick_enemy_type() -> String:
	#@todo


# FC-4: Loop the parameter list, calling `endless_buff(e, delta)` on each.
# Mirrors morning chunk #4 (function takes a list as parameter).
#
# Given:
#   - enemy_list              — a list of enemies passed in as a parameter
#   - endless_buff(e, delta)  — applies endless scaling to one enemy
func on_screen_clear() -> void:
	#@todo


# ============================================================
#  Pre-given helper — picks one of the four edge spawn points.
#  You don't need to touch this one.
# ============================================================
func random_edge() -> Vector2i:
	return main.random_edge_cell()
