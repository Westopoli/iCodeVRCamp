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
#  Almost all of this is written for you. Your only job is the
#  SAME thing you did this morning: write a few FUNCTIONS. No new
#  ideas — define a function body, then call it.
#
#  Mirror map (read this first):
#      FINAL CHALLENGE #1  ←  TODO #1  (function that loops a list)
#      FINAL CHALLENGE #2  ←  TODO #4  (call the function you wrote)
#      FINAL CHALLENGE #3  ←  TODO #3  (function that changes a variable)
#  Everything else (timers, lists, ramps, match) is pre-given.
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


# --- Pre-given: endless-mode state variables ---
var spawn_timer: float = 0.0
var difficulty: int = 1
var spawn_interval: float = SPAWN_INTERVAL_START
var spawn_queue: Array = []
var clear_streak: int = 0


# ============================================================
#  Pre-given: per-frame entry point.  main.gd's _process calls
#  this when ENDLESS_MODE is true.  The body wires every FC hole
#  into the game's tick.
# ============================================================
func endless_tick(delta: float) -> void:
	# Pre-given: tick the spawn timer + drain the queue.
	spawn_timer_tick(delta)

	# FINAL CHALLENGE #2   Call the function you wrote.
	# You defined buff_all(enemy_list, delta) below. Call it here with the
	# enemies list and delta so it runs every frame.
	#
	# Given:
	#   - buff_all(enemy_list, delta)   — the function you wrote (FINAL CHALLENGE #1)
	#   - main.enemies                  — the list of active enemies
	#   - delta                         — this frame's time
	#
	# Syntax:
	#   - function_name(argument1, argument2)
	#@todo
	buff_all(main.enemies, delta)
	#@end

	# --- Pre-given: also buff the towers so they keep up ---
	for t in main.towers:
		buff_tower(t, delta)

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


func pay_streak() -> void:
	# FINAL CHALLENGE #3   Fill in this FUNCTION's body.
	# pay_streak rewards the player for clearing the screen. Make it add
	# STREAK_BONUS to main.coins. One line — just like reward_coins() this morning.
	#
	# Given:
	#   - main.coins     — the player's coin counter
	#   - STREAK_BONUS   — the coin bonus amount (a constant up top)
	#
	# Syntax:
	#   - main.coins += STREAK_BONUS
	#@todo
	main.coins += STREAK_BONUS
	#@end


func queue_spawn(t: String) -> void:
	# --- Pre-given: add an enemy type to the back of the spawn queue ---
	spawn_queue.append(t)


func take_next_spawn() -> void:
	# --- Pre-given: pop the next type, spawn it, and pay the streak bonus
	# (paying goes through pay_streak() — the function you write above). ---
	var t: String = spawn_queue.pop_front()
	main.spawn_enemy(random_edge(), t)
	pay_streak()


func buff_all(enemy_list: Array, delta: float) -> void:
	# FINAL CHALLENGE #1   Fill in this FUNCTION's body.
	# buff_all takes a list of enemies (the parameter `enemy_list`) and a time
	# value (`delta`). Go through enemy_list and call endless_buff(e, delta) on
	# each one — the same shape as move_all() from this morning.
	#
	# Given:
	#   - enemy_list              — the list of enemies passed in to this function
	#   - endless_buff(e, delta)  — applies endless scaling to one enemy
	#
	# Syntax:
	#   - for e in enemy_list:
	#         do_something(e)
	#@todo
	for e in enemy_list:
		endless_buff(e, delta)
	#@end


func get_fastest_enemy() -> Node:
	# Pre-given: start with no winner and a "best speed so far"
	# value of zero — the first enemy automatically beats it.
	var fastest: Node = null
	var best_speed: float = 0.0

	# --- Pre-given: scan the enemies and keep the fastest one ---
	for e in main.enemies:
		if e.speed > best_speed:
			fastest = e
			best_speed = e.speed

	# Pre-given: hand the winner (or null) back to the caller.
	return fastest


func get_wounded_enemies() -> Array:
	# --- Pre-given: collect every wounded enemy into a list and return it ---
	var result: Array = []
	for e in main.enemies:
		if e.hp <= WOUNDED_HP_THRESHOLD:
			result.append(e)
	return result


# FC-6   escalate() match branches
# Goal: in each branch, pick a type with pick_type_for_band(band) and call queue_spawn(t).
# Easy: once. Medium: twice. Hard: three times. Insane: four times.
#
# Pattern (medium branch as example):
#     "mid_level":
#             var kind = pick_type_for_band(band)
#             queue_spawn(kind)
#             queue_spawn(kind)
#
# Note: function names are accurate; variable names are for illustration only.
func escalate() -> void:
	# Pre-given: figure out the band, then dispatch.
	var band: String = difficulty_band()
	# --- Pre-given: harder bands queue more enemies per refill ---
	match band:
		"easy":
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
		"medium":
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
		"hard":
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
		"insane":
			var t: String = pick_type_for_band(band)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)
			queue_spawn(t)


func check_for_screen_clear() -> void:
	# --- Pre-given: when the screen is cleared, ramp difficulty + regen base ---
	if main.enemies.size() == 0 and spawn_queue.size() == 0:
		clear_streak += 1
		difficulty += 1
		spawn_interval *= SPAWN_INTERVAL_SHRINK
		main.base_hp += BASE_HP_REGEN_PER_CLEAR
		escalate()


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
