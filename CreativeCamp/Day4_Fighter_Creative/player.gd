extends CharacterBody2D

# === pre-given ===
const GRAVITY := 1500.0
const MAX_FALL_SPEED := 900.0

var player_num: int = 1     # 1 or 2 — drives input routing
var character_name: String = "knight"
var character_data: Dictionary = {}
var attack_cooldown_timer: float = 0.0
var hit_flash_timer: float = 0.0   # cosmetic — modulate red briefly
var melee_swing_timer: float = 0.0  # cosmetic — draw swing arc

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar_fill: ColorRect = $HpBar/Fill   # width scales with hp/max_hp

const PROJECTILE_SCENE := preload("res://Projectile.tscn")

# MAIN reference — resolved at enter_tree (current_scene is the loaded root)
var MAIN: Node = null

func _enter_tree() -> void:
	if MAIN == null:
		MAIN = get_tree().current_scene

# called by main.gd after instantiate
func setup(num: int, char_name: String, spawn_pos: Vector2) -> void:
	if MAIN == null:
		MAIN = get_tree().current_scene
	player_num = num
	character_name = char_name
	character_data = MAIN.CHARACTERS[char_name]
	position = spawn_pos
	sprite.texture = load(character_data["sprite"])
	sprite.modulate = character_data["tint"] if num == 1 else character_data["tint"].darkened(0.2)
	# Pre-given: copy this character's stats from character_data into the player.
	max_hp = 100
	hp = 100
	facing = 1 if num == 1 else -1
	walk_speed = character_data["walk_speed"]
	jump_impulse = character_data["jump_impulse"]
	attack_type = character_data["attack_type"]
	attack_damage = character_data["attack_damage"]
	attack_cooldown = character_data["attack_cooldown"]
	state = "idle"

# --- Pre-given: core properties every Player tracks (health + facing) ---
var hp: int = 100
var max_hp: int = 100
var facing: int = 1

# --- Pre-given: properties that mirror the character config ---
var walk_speed: float = 220.0
var jump_impulse: float = 520.0
var attack_type: String = "melee"
var attack_damage: int = 18
var attack_cooldown: float = 0.55

# --- Pre-given: the `state` property + the set_state() helper that switches it ---
var state: String = "idle"

func set_state(new_state: String) -> void:
	if new_state == state:
		return
	print(new_state)
	state = new_state

# === pre-given: input routing per player ===
func get_input_pressed(action: String) -> bool:
	return Input.is_action_pressed("p%d_%s" % [player_num, action])

func get_input_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed("p%d_%s" % [player_num, action])

func get_move_direction() -> int:
	if get_input_pressed("left"):
		return -1
	if get_input_pressed("right"):
		return 1
	return 0

# === pre-given: physics + flow ===
func _physics_process(delta: float) -> void:
	if not MAIN.fight_active:
		return
	# gravity
	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	# facing follows input direction (only updates when walking)
	if get_input_pressed("left"):
		facing = -1
	elif get_input_pressed("right"):
		facing = 1
	sprite.flip_h = (facing == 1)
	# decay timers
	attack_cooldown_timer = max(attack_cooldown_timer - delta, 0.0)
	hit_flash_timer = max(hit_flash_timer - delta, 0.0)
	if melee_swing_timer > 0.0:
		melee_swing_timer = max(melee_swing_timer - delta, 0.0)
		queue_redraw()
	sprite.modulate = character_data["tint"] if hit_flash_timer <= 0.0 else Color(1, 0.4, 0.4)

	# === KID CHUNK #6 — STATE MACHINE: pick the right state-change ===
	# Pre-given: the match dispatcher + per-branch velocity + attack / hit exits.
	# Kid fills (4 sub-holes): the `if` blocks that decide WHICH state comes next.
	match state:
		"idle":
			velocity.x = 0
			# TODO #2: We're standing still. If the player starts moving left or
			# right, we should switch into the "walk" state. `get_move_direction()`
			# is 0 when no arrow is held, and -1 or 1 when one is. Write the `if`
			# that switches to "walk" when the move direction is NOT zero.
			#
			# Syntax:  if a != b:
			#@todo
			if get_move_direction() != 0:
				set_state("walk")
			#@end
			# Pre-given: jump out of idle when jump is pressed on the floor.
			if get_input_just_pressed("jump") and is_on_floor():
				velocity.y = -jump_impulse
				set_state("jump")
		"walk":
			velocity.x = walk_speed * get_move_direction()
			# TODO #3: We're walking. If the player stops pressing left/right,
			# `get_move_direction()` becomes 0 — switch back to "idle". Write the
			# `if` that switches to "idle" when the move direction EQUALS zero.
			#
			# Syntax:  if a == b:
			#@todo
			if get_move_direction() == 0:
				set_state("idle")
			#@end
			# Pre-given: jump out of walk when jump is pressed on the floor.
			if get_input_just_pressed("jump") and is_on_floor():
				velocity.y = -jump_impulse
				set_state("jump")
		"jump":
			velocity.x = walk_speed * get_move_direction() * 0.85
			# Pre-given: once upward velocity runs out (velocity.y > 0), start falling.
			if velocity.y > 0:
				set_state("fall")
		"fall":
			velocity.x = walk_speed * get_move_direction() * 0.85
			# Pre-given: when we land back on the floor, return to idle.
			if is_on_floor():
				set_state("idle")
		"attack":
			# Pre-given: keep moving while attacking, exit when cooldown done.
			var ground_factor: float = 1.0 if is_on_floor() else 0.85
			velocity.x = walk_speed * get_move_direction() * ground_factor
			if attack_cooldown_timer <= 0.0:
				set_state("idle" if is_on_floor() else "fall")
		"hit":
			# Pre-given: frozen while flashing, then exit.
			velocity.x = 0
			if hit_flash_timer <= 0.0:
				set_state("idle" if is_on_floor() else "fall")

	# Pre-given: attack input is universal across idle / walk / jump / fall.
	if state != "attack" and state != "hit" and get_input_just_pressed("attack"):
		# TODO #4: The attack key was just pressed — but attacks have a cooldown so
		# players can't spam them. `attack_cooldown_timer` counts down to 0 after
		# each swing. Only run the swing if that timer has reached zero.
		# Write the `if` that runs the two pre-given lines ONLY when the timer is
		# at (or below) 0.
		#
		# Syntax:  if a <= b:
		#@todo
		if attack_cooldown_timer <= 0.0:
		#@end
			# Pre-given: do the attack, then enter the attack state.
			attack()
			set_state("attack")

	move_and_slide()

# --- Pre-given: take_damage() applies a hit. The kid writes ONLY the death check.
func take_damage(amount: int) -> void:
	# Pre-given: subtract the damage, flash red, freeze in "hit", resize HP bar.
	hp -= amount
	hit_flash_timer = 0.2
	set_state("hit")
	hp_bar_fill.size.x = (float(hp) / max_hp) * 80.0   # bar is 80px wide
	# TODO #1: After taking damage, check if this fighter has run out of health.
	# `hp` is the current health. If it has dropped to zero (or below), call
	# `die()`. Write the `if` that calls `die()` when hp is at (or below) 0.
	#
	# Syntax:  if a <= b:
	#@todo
	if hp <= 0:
		die()
	#@end

# --- Pre-given: attack() does the whole swing. The kid writes ONLY the hit check
# (does the swing actually connect?).
func attack() -> void:
	# Pre-given: start the cooldown, then branch on this fighter's attack type.
	attack_cooldown_timer = attack_cooldown
	match attack_type:
		"melee":
			# Pre-given: show the swing arc and find the opponent.
			melee_swing_timer = 0.15
			queue_redraw()
			var opponent = get_opponent()
			if opponent == null and opponent.is_dead():
				return
			var to_opp = opponent.position - position
			# Pre-given: three checks for whether the swing lands.
			var in_range = abs(to_opp.x) <= character_data["attack_range"]
			var facing_opponent = sign(to_opp.x) == facing
			var same_height = abs(to_opp.y) <= 60
			# TODO #5: The swing only hurts the opponent if ALL THREE checks above
			# are true: they're `in_range`, you're `facing_opponent`, AND you're at
			# the `same_height`. Each is true/false. Write the `if` that deals damage
			# (the pre-given line below) only when all three are true at once.
			#
			# Syntax:  if a and b and c:
			#@todo
			if in_range and facing_opponent and same_height:
			#@end
				# Pre-given: land the hit.
				opponent.take_damage(attack_damage)
		"projectile":
			spawn_projectile()

# === pre-given ===
func spawn_projectile() -> void:
	var p = PROJECTILE_SCENE.instantiate()
	p.position = position + Vector2(facing * 30, -10)
	p.setup(
		Vector2(character_data["projectile_speed"] * facing, -50),  # slight upward initial
		character_data["projectile_gravity_scale"],
		character_data["attack_damage"],
		self,  # owner — projectile ignores this player
	)
	MAIN.projectiles_node.add_child(p)

func get_opponent() -> Node:
	return MAIN.player2 if player_num == 1 else MAIN.player1

func is_dead() -> bool:
	return hp <= 0

func _draw() -> void:
	if melee_swing_timer <= 0.0 or attack_type != "melee":
		return
	var reach: float = character_data["attack_range"]
	var rect := Rect2(Vector2(0 if facing == 1 else -reach, -20), Vector2(reach, 40))
	draw_rect(rect, Color(1, 1, 1, 0.7), true)

func die() -> void:
	set_state("hit")   # frozen
	visible = false
	MAIN.on_player_died(self)
