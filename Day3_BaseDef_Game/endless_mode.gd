extends Node

# ============================================================
#  FINAL CHALLENGE — ENDLESS MODE
#
#  The morning game stopped after 8 waves.  Endless mode rips
#  out the wave list and replaces it with infinite spawning that
#  ramps forever:
#    - enemies spawn on a timer (not from a wave list)
#    - every screen clear, enemies speed up + spawn faster
#    - towers also get a small per-frame buff so they keep up
#    - your base regenerates a little HP every screen clear
#      (no HP cap — the base can climb above its starting value)
#    - there is no win panel; the game ends only when the base
#      falls
#
#  Every hole below is a REWORDED version of a chunk you wrote
#  this morning.  No new ideas — the same shapes, applied to
#  endless state instead of wave state.
#
#  Mirror map (read this first):
#      FC-1  ←  TODO #1   (declare state vars)
#      FC-2a ←  TODO #2a  (.append to a list)
#      FC-2b ←  TODO #2b  (.erase from a list + reward)
#      FC-3  ←  TODO #3   (iterate two lists each frame)
#      FC-4  ←  TODO #4   (function takes a list as a parameter)
#      FC-5a ←  TODO #5a  (function returns ONE from a list)
#      FC-5b ←  TODO #5b  (function returns a LIST from a list)
#      FC-6  ←  TODO #6   (match + nested function calls)
#      FC-7  ←  TODO #7   (size() check + state transition)
#
#  To switch the game into endless mode: open `main.gd`, find
#  `const ENDLESS_MODE := false`, change false → true.  Save, play.
# ============================================================

# This script gets added as a child of the Main node when
# ENDLESS_MODE is true (wiring lives in main.gd's _ready).
# It reads/writes main.enemies, main.towers, main.coins, and
# main.base_hp via the parent reference below.
@onready var main: Node = get_parent()

# --- pre-given tuning constants ---
const SPAWN_INTERVAL_START := 2.0        # seconds between spawns at difficulty 1
const SPAWN_INTERVAL_SHRINK := 0.9       # each clear: interval *= this (faster spawns)
const STREAK_BONUS := 5                  # coin payout each time the queue drains
const SPEED_RAMP_PER_STREAK := 6.0       # enemy speed bump per second per clear_streak
const TOWER_DAMAGE_RAMP_PER_STREAK := 0.4 # tower damage buff per second per clear_streak
const WOUNDED_HP_THRESHOLD := 5          # FC-5b: what counts as "wounded"
const BASE_HP_REGEN_PER_CLEAR := 2       # base HP restored each screen clear (no cap)


# ============================================================
#  FINAL CHALLENGE 1 — STATE VARIABLES
#
#  Endless mode needs to remember five things between frames:
#    spawn_timer    a float starting at 0.0  — counts up each frame
#    difficulty     an integer starting at 1 — drives the difficulty band
#    spawn_interval a float starting at SPAWN_INTERVAL_START (2.0) —
#                   seconds between spawns; shrinks over time
#    spawn_queue    an empty list — holds enemy-type strings waiting
#                   to spawn on upcoming ticks
#    clear_streak   an integer starting at 0 — how many screen-clears
#                   in a row (drives speed ramp + base regen)
#
#  Inputs:  none.
#  Outcome: after the script loads, all five state variables exist
#           at their starting values.
# ============================================================
# FINAL CHALLENGE 1
#@todo
var spawn_timer: float = 0.0
var difficulty: int = 1
var spawn_interval: float = SPAWN_INTERVAL_START
var spawn_queue: Array = []
var clear_streak: int = 0
#@end


# ============================================================
#  Pre-given: per-frame entry point.  main.gd's _process calls
#  this when ENDLESS_MODE is true.  The body wires every FC hole
#  into the game's tick.
# ============================================================
func endless_tick(delta: float) -> void:
	# Pre-given: tick the spawn timer + drain the queue.
	spawn_timer_tick(delta)

	# ========================================================
	#  TODO FC-3: PER-FRAME BUFF SWEEP
	#
	#  Endless mode buffs both sides every frame so the game can
	#  ramp forever.  Walk every enemy on the field and bump its
	#  speed (the pre-given `endless_buff` helper handles the
	#  math), then walk every tower and bump its damage (the
	#  pre-given `buff_tower` helper handles that one).
	#
	#  Inputs:  main.enemies, main.towers, and delta.
	#  Outcome: endless_buff(e, delta) is called for every enemy,
	#           and buff_tower(t, delta) is called for every tower.
	# ========================================================
	#@todo
	for e in main.enemies:
		endless_buff(e, delta)
	for t in main.towers:
		buff_tower(t, delta)
	#@end

	# Pre-given: check if the screen just cleared.
	check_for_screen_clear()


# ============================================================
#  Pre-given: the spawn timer + queue plumbing.  When the timer
#  catches up to spawn_interval, ask `escalate()` to refill the
#  queue (if empty) and then drain one entry via take_next_spawn.
# ============================================================
func spawn_timer_tick(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		if spawn_queue.size() == 0:
			escalate()
		take_next_spawn()
		spawn_timer = 0.0


# ============================================================
#  FINAL CHALLENGE 2a — ADD A SPAWN TO THE QUEUE
#
#  This helper is called by `escalate()` (FC-6) to load the
#  spawn queue with the next enemy type.  Your job is one line:
#  put the type string on the end of the queue.
#
#  Inputs:  `t` (a string, either "grunt" or "runner") and the
#           `spawn_queue` list (from FC-1).
#  Outcome: after this runs, `t` sits at the back of spawn_queue.
# ============================================================
func queue_spawn(t: String) -> void:
	# FINAL CHALLENGE 2a
	#@todo
	spawn_queue.append(t)
	#@end


# ============================================================
#  FINAL CHALLENGE 2b — DRAIN THE QUEUE + REWARD
#
#  The spawn timer just fired and the queue is guaranteed
#  non-empty (the pre-given caller refilled it if needed).
#  Pop the first type off the queue, hand it to
#  `main.spawn_enemy(random_edge(), the_type)`, and pay the
#  player a small coin bonus (endless mode is generous — every
#  spawn pays).
#
#  Inputs:  the `spawn_queue` list, `main.coins`, `main.spawn_enemy`,
#           the pre-given `random_edge()` helper, and STREAK_BONUS.
#  Outcome: one type has been removed from the front of
#           spawn_queue, main.spawn_enemy has been called with
#           that type at a random edge cell, and main.coins has
#           grown by STREAK_BONUS.
# ============================================================
func take_next_spawn() -> void:
	# FINAL CHALLENGE 2b
	#@todo
	var t: String = spawn_queue.pop_front()
	main.spawn_enemy(random_edge(), t)
	main.coins += STREAK_BONUS
	#@end


# ============================================================
#  FINAL CHALLENGE 4 — FUNCTION TAKING A LIST
#
#  Same job as the FC-3 loop over `main.enemies`, but the list
#  now arrives through this function's parameter.  Whoever calls
#  `buff_all(some_list, delta)` decides which list gets buffed.
#
#  Nothing in this scaffold calls `buff_all` by default (FC-3
#  already buffs `main.enemies` directly).  You CAN refactor
#  FC-3 to call `buff_all(main.enemies, delta)` if you want —
#  just like you could refactor TODO #3 this morning to call
#  `move_all(enemies, delta)`.  The function still has to be
#  written either way as the FC-4 lesson.
#
#  Inputs:  `enemy_list` (a list of enemies) and `delta`.
#  Outcome: endless_buff(e, delta) is called for every enemy
#           in `enemy_list`.
# ============================================================
func buff_all(enemy_list: Array, delta: float) -> void:
	# FINAL CHALLENGE 4
	#@todo
	for e in enemy_list:
		endless_buff(e, delta)
	#@end


# ============================================================
#  FINAL CHALLENGE 5a — RETURN THE FASTEST ENEMY (R5 partial hole)
#
#  Endless mode wants to know which enemy is currently the
#  scariest one — the one with the highest .speed value.  Pre-
#  given init below starts with no winner and "best speed so
#  far" of zero, so the first enemy automatically beats it.
#  Your loop walks main.enemies and updates the winner.
#
#  Inputs:  `main.enemies` (the list of live enemies).
#  Outcome: when this section finishes, `fastest` holds the
#           enemy with the highest .speed (or stays null if the
#           list is empty), and `best_speed` holds its speed.
# ============================================================
func get_fastest_enemy() -> Node:
	# Pre-given: start with no winner and a "best speed so far"
	# value of zero — the first enemy automatically beats it.
	var fastest: Node = null
	var best_speed: float = 0.0

	# FINAL CHALLENGE 5a
	#@todo
	for e in main.enemies:
		if e.speed > best_speed:
			fastest = e
			best_speed = e.speed
	#@end

	# Pre-given: hand the winner (or null) back to the caller.
	return fastest


# ============================================================
#  FINAL CHALLENGE 5b — RETURN A LIST OF WOUNDED ENEMIES
#
#  Build and return a brand-new list of every enemy whose HP is
#  at or below WOUNDED_HP_THRESHOLD.  Endless mode could use
#  this to flag near-dead enemies on the HUD or to hand a target
#  priority list to towers — for now it's here so the game can
#  see who's about to drop.
#
#  Inputs:  `main.enemies` and WOUNDED_HP_THRESHOLD (pre-given).
#  Outcome: a new list is returned containing every enemy whose
#           `hp` is `<=` the threshold.  Empty list is fine.
# ============================================================
func get_wounded_enemies() -> Array:
	# FINAL CHALLENGE 5b
	#@todo
	var result: Array = []
	for e in main.enemies:
		if e.hp <= WOUNDED_HP_THRESHOLD:
			result.append(e)
	return result
	#@end


# ============================================================
#  FINAL CHALLENGE 6 — MATCH + NESTED CALL (per difficulty band)
#
#  Pre-given `difficulty_band()` returns "easy" / "medium" /
#  "hard" / "insane" based on the current `difficulty`.  The
#  match dispatcher below routes each band to a different queue
#  refill.  Your job: in each branch, decide which enemy type
#  to queue and queue it.
#
#  Helpers available in every branch:
#    queue_spawn(t)              — you wrote FC-2a; adds t to queue.
#    pick_type_for_band(band)    — pre-given; returns a string
#                                   ("grunt" or "runner") for the
#                                   current difficulty band.
#
#  Outcome per branch: one or more spawns have been queued —
#  gentle on "easy", brutal on "insane".  Use unpack-then-queue
#  (var t = pick_type_for_band(band); queue_spawn(t)) or nested
#  (queue_spawn(pick_type_for_band(band))) — either is fine.
# ============================================================
func escalate() -> void:
	# Pre-given: figure out the band, then dispatch.
	var band: String = difficulty_band()
	match band:
		"easy":
			# FINAL CHALLENGE 6a — easy band: queue 1 enemy
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			#@end
		"medium":
			# FINAL CHALLENGE 6b — medium band: queue 2 enemies
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			#@end
		"hard":
			# FINAL CHALLENGE 6c — hard band: queue 3 enemies
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			#@end
		"insane":
			# FINAL CHALLENGE 6d — insane band: queue 4 enemies
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			#@end


# ============================================================
#  FINAL CHALLENGE 7 — SCREEN-CLEAR CHECK + ESCALATION
#
#  Endless mode's version of "wave is done": when no enemies are
#  alive AND nothing is queued to spawn, the player has briefly
#  cleared the screen.  Use that moment to ramp the game.
#
#  Inputs:  `main.enemies`, `spawn_queue`, `clear_streak`,
#           `difficulty`, `spawn_interval`, `main.base_hp`, and
#           the constants SPAWN_INTERVAL_SHRINK + BASE_HP_REGEN_PER_CLEAR.
#  Outcome: when both lists are empty:
#             - clear_streak goes up by 1
#             - difficulty goes up by 1
#             - spawn_interval shrinks by SPAWN_INTERVAL_SHRINK
#               (so spawns come faster)
#             - main.base_hp grows by BASE_HP_REGEN_PER_CLEAR
#               (no cap — base HP can climb past its start value)
#             - pre-given `escalate()` is called to queue the
#               next burst
# ============================================================
func check_for_screen_clear() -> void:
	# FINAL CHALLENGE 7
	#@todo
	if main.enemies.size() == 0 and spawn_queue.size() == 0:
		clear_streak += 1
		difficulty += 1
		spawn_interval *= SPAWN_INTERVAL_SHRINK
		main.base_hp += BASE_HP_REGEN_PER_CLEAR
		escalate()
	#@end


# ============================================================
#  Pre-given helpers — kids never modify these.
# ============================================================

# Picks one of the four edge spawn points for the next spawn.
func random_edge() -> Vector2i:
	return main.random_edge_cell()


# Speed ramp on an enemy: per second, .speed grows by
# clear_streak * SPEED_RAMP_PER_STREAK.  No cap.
func endless_buff(e: Node, delta: float) -> void:
	if not is_instance_valid(e):
		return
	e.speed += SPEED_RAMP_PER_STREAK * clear_streak * delta


# Damage ramp on a tower: per second, the tower's damage bonus
# meta grows by clear_streak * TOWER_DAMAGE_RAMP_PER_STREAK.
# fire_at in main.gd reads .get_meta("damage_bonus", 0.0) if
# present — kept simple here so towers keep up with the enemy
# ramp without main.gd needing endless-aware fire logic.
func buff_tower(t: Node, delta: float) -> void:
	if not is_instance_valid(t):
		return
	var bonus: float = t.get_meta("damage_bonus", 0.0)
	bonus += TOWER_DAMAGE_RAMP_PER_STREAK * clear_streak * delta
	t.set_meta("damage_bonus", bonus)


# Returns the current difficulty band — drives FC-6's match.
func difficulty_band() -> String:
	if difficulty <= 2:
		return "easy"
	if difficulty <= 5:
		return "medium"
	if difficulty <= 10:
		return "hard"
	return "insane"


# Returns the enemy-type string for a given band.  Runners
# show up more as the band gets nastier.
func pick_type_for_band(band: String) -> String:
	match band:
		"easy":
			return "grunt"
		"medium":
			return "grunt" if randf() < 0.7 else "runner"
		"hard":
			return "grunt" if randf() < 0.4 else "runner"
		_:
			return "runner"
