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


# FC-1: Declare the five pieces of endless-mode state at the top of the script (mirrors morning #1).
#
# Syntax:
#   - var name: float = value
#   - var name: int = value
#   - var name: Array = []    (empty list)
#
# Write it — one # line per line of code you'll write:
# var spawn_timer: float = 0.0
# var difficulty: int = 1
# var spawn_interval: float = SPAWN_INTERVAL_START
# var spawn_queue: Array = []
# var clear_streak: int = 0
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

	# FC-3: Every frame, buff every enemy then buff every tower (mirrors morning #3's two for-loops).
	#
	# Syntax:
	#   - for item in list:
	#
	# Write it — one # line per line of code you'll write:
	# for each e in main.enemies:
	#     call endless_buff(e, delta)
	# for each t in main.towers:
	#     call buff_tower(t, delta)
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


func queue_spawn(t: String) -> void:
	# FC-2a: Add the type string t to the back of spawn_queue (mirrors morning #2a's .append).
	#
	# Syntax:
	#   - list.append(item)
	#
	# Write it — one # line per line of code you'll write:
	# add t to the spawn_queue list: spawn_queue.append(t)
	#@todo
	spawn_queue.append(t)
	#@end


func take_next_spawn() -> void:
	# FC-2b: Pop the next type off the queue, spawn it at a random edge, and pay the streak bonus (mirrors morning #2b).
	#
	# Syntax:
	#   - list.pop_front()   (removes and returns the first item)
	#   - func_name(args)
	#   - counter += amount
	#
	# Write it — one # line per line of code you'll write:
	# pop the first type off spawn_queue: var t = spawn_queue.pop_front()
	# spawn it at a random edge: main.spawn_enemy(random_edge(), t)
	# pay the streak bonus: main.coins += STREAK_BONUS
	#@todo
	var t: String = spawn_queue.pop_front()
	main.spawn_enemy(random_edge(), t)
	main.coins += STREAK_BONUS
	#@end


func buff_all(enemy_list: Array, delta: float) -> void:
	# FC-4: Fill in buff_all so it buffs every enemy in the list it was handed (enemy_list — mirrors morning #4).
	#
	# Syntax:
	#   - for item in list:
	#   - func name(list, delta):
	#
	# Write it — one # line per line of code you'll write:
	# for each e in enemy_list:
	#     call endless_buff(e, delta)
	#@todo
	for e in enemy_list:
		endless_buff(e, delta)
	#@end


func get_fastest_enemy() -> Node:
	# Pre-given: start with no winner and a "best speed so far"
	# value of zero — the first enemy automatically beats it.
	var fastest: Node = null
	var best_speed: float = 0.0

	# FC-5a: Scan the enemies and find the one with the highest speed (mirrors morning #5a).
	#
	# Syntax:
	#   - for item in list:
	#   - if cond:
	#
	# Write it — one # line per line of code you'll write:
	# for each e in main.enemies:
	#     if e.speed > best_speed:
	#         set fastest = e
	#         set best_speed = e.speed
	#@todo
	for e in main.enemies:
		if e.speed > best_speed:
			fastest = e
			best_speed = e.speed
	#@end

	# Pre-given: hand the winner (or null) back to the caller.
	return fastest


func get_wounded_enemies() -> Array:
	# FC-5b: Build and return a brand-new list of every enemy whose hp is at or below WOUNDED_HP_THRESHOLD (mirrors morning #5b).
	#
	# Syntax:
	#   - var name: Array = []    (empty list)
	#   - for item in list:
	#   - list.append(item)
	#   - return value
	#
	# Write it — one # line per line of code you'll write:
	# var result: Array = []
	# for each e in main.enemies:
	#     if e.hp <= WOUNDED_HP_THRESHOLD:
	#         result.append(e)
	# return result
	#@todo
	var result: Array = []
	for e in main.enemies:
		if e.hp <= WOUNDED_HP_THRESHOLD:
			result.append(e)
	return result
	#@end


# FC-6: The four branches below fill escalate() (mirrors morning #6). Pre-given:
# difficulty_band() picks the band and the match dispatches to it. In each branch,
# pick one type with pick_type_for_band(band), then queue that many spawns —
# easy once, medium twice, hard three times, insane four times.
func escalate() -> void:
	# Pre-given: figure out the band, then dispatch.
	var band: String = difficulty_band()
	match band:
		"easy":
			# FC-6a: Easy band — pick a type, then queue one spawn of it.
			#
			# Syntax:
			#   - var x = func_name(args)
			#   - func_name(args)
			#
			# Write it — one # line per line of code you'll write:
			# pick a type for this band: var t = pick_type_for_band(band)
			# queue one spawn: queue_spawn(t)
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			#@end
		"medium":
			# FC-6b: Medium band — pick a type, then queue two spawns of it.
			#
			# Syntax:
			#   - var x = func_name(args)
			#   - func_name(args)
			#
			# Write it — one # line per line of code you'll write:
			# pick a type for this band: var t = pick_type_for_band(band)
			# queue spawn one: queue_spawn(t)
			# queue spawn two: queue_spawn(t)
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			#@end
		"hard":
			# FC-6c: Hard band — pick a type, then queue three spawns of it.
			#
			# Syntax:
			#   - var x = func_name(args)
			#   - func_name(args)
			#
			# Write it — one # line per line of code you'll write:
			# pick a type for this band: var t = pick_type_for_band(band)
			# queue spawn one: queue_spawn(t)
			# queue spawn two: queue_spawn(t)
			# queue spawn three: queue_spawn(t)
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			#@end
		"insane":
			# FC-6d: Insane band — pick a type, then queue four spawns of it.
			#
			# Syntax:
			#   - var x = func_name(args)
			#   - func_name(args)
			#
			# Write it — one # line per line of code you'll write:
			# pick a type for this band: var t = pick_type_for_band(band)
			# queue spawn one: queue_spawn(t)
			# queue spawn two: queue_spawn(t)
			# queue spawn three: queue_spawn(t)
			# queue spawn four: queue_spawn(t)
			#@todo
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			#@end


func check_for_screen_clear() -> void:
	# FC-7: When the screen is clear, ramp the whole game one notch harder and queue the next burst (mirrors morning #7).
	#
	# Syntax:
	#   - if cond and cond:
	#   - list.size() == 0   (check if list is empty)
	#   - counter += amount
	#   - value *= factor
	#   - func_name()
	#
	# Write it — one # line per line of code you'll write:
	# if main.enemies.size() == 0 and spawn_queue.size() == 0:
	#     add 1 to clear_streak
	#     add 1 to difficulty
	#     shrink spawn_interval: spawn_interval *= SPAWN_INTERVAL_SHRINK
	#     regen the base: main.base_hp += BASE_HP_REGEN_PER_CLEAR
	#     call escalate()
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
