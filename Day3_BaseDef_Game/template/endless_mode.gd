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


# ============================================================
#  FINAL CHALLENGE 1 — STATE VARIABLES
#
#  Endless mode needs to remember three things:
#    spawn_timer        a float starting at 0.0   — counts up
#    difficulty         an integer starting at 1  — escalates over time
#    spawn_interval     a float starting at 2.0   — seconds between spawns
#
#  Declare them as plain top-level `var`s, just like the four
#  you declared in main.gd's TODO #1 this morning.
# ============================================================
# FINAL CHALLENGE 1


# ============================================================
#  Helper called every frame by main.gd's _process when
#  ENDLESS_MODE is true.
# ============================================================
func endless_tick(delta: float) -> void:
	spawn_timer_tick(delta)
	if main.enemies.size() == 0:
		on_screen_clear()


# ============================================================
#  FINAL CHALLENGE 2 — SPAWN ON A TIMER
#
#  Every frame:
#    1. increase `spawn_timer` by `delta`.
#    2. if it has caught up to `spawn_interval`, time to spawn:
#         a) figure out what type to spawn (call pick_enemy_type()
#            from FC-3)
#         b) spawn it: main.spawn_enemy(random_edge(), the_type)
#         c) reset spawn_timer back to 0.0
#
#  This is the same shape as TODO #2a from this morning, just
#  triggered by a timer instead of by a wave list.
# ============================================================
func spawn_timer_tick(delta: float) -> void:
	# FINAL CHALLENGE 2


# ============================================================
#  FINAL CHALLENGE 3 — RETURN ONE THING BASED ON DIFFICULTY
#
#  Function returns a String:  either "grunt" or "runner".
#
#  Rule of thumb (you can change this if you want a different
#  feel):
#    - at low difficulty, mostly grunts.
#    - at high difficulty, more runners (faster, scarier).
#  e.g.:
#       if difficulty > 3:
#           return "runner"
#       else:
#           return "grunt"
#
#  This is the same shape as TODO #5a — pick ONE thing, return
#  it.  No looping needed for this one.
# ============================================================
func pick_enemy_type() -> String:
	# FINAL CHALLENGE 3


# ============================================================
#  FINAL CHALLENGE 4 — SIZE CHECK + ESCALATION
#
#  Whenever the screen clears (no enemies left), we want the
#  game to get HARDER:
#    - bump difficulty by 1
#    - shrink spawn_interval to 90% of its current value
#      (`spawn_interval *= 0.9`) — so spawns come faster.
#
#  This is the same `enemies.size() == 0` check you wrote in
#  TODO #7 — just with a different consequence (escalation
#  instead of "next wave").
# ============================================================
func on_screen_clear() -> void:
	# FINAL CHALLENGE 4


# ============================================================
#  Pre-given helper — picks one of the four edge spawn points.
#  You don't need to touch this one.
# ============================================================
func random_edge() -> Vector2i:
	return main.random_edge_cell()
