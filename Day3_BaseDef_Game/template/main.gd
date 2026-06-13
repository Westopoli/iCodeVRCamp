extends Node2D

# ============================================================
#  DAY 3 — BASE DEFENSE
#
#  Today's tools: FUNCTIONS (deep — taking lists, returning
#  things) and LISTS (make them, add to them, scan them).
#
#  The game: enemies pour in from every edge of the field.
#  They want to wreck your base in the centre. You stop them
#  by placing TOWERS that shoot enemies (Cannon, Sniper,
#  Splash). Earn coins for each kill. Beat all 8 waves to win.
#
#  Controls:
#    1 / 2 / 3   pick tower type (or click the bottom buttons)
#    LMB         place selected tower on an empty grid cell
#    SPACE       start the next wave
#    R           restart
# ============================================================

# --- grid + viewport ---
const TILE := 40
const GRID_W := 32         # playfield columns (0..31)
const GRID_H := 17         # playfield rows    (0..16)  bottom 40 px = button bar
const SPRITE_SCALE := 0.625  # Kenney tiles are 64px -> scale to TILE

# --- base position (two cells, centre of the field) ---
const BASE_CELL_A := Vector2i(15, 8)
const BASE_CELL_B := Vector2i(16, 8)

# --- starting state ---
const START_COINS := 90
const START_BASE_HP := 22

# ============================================================
#  DIFFICULTY KNOB
#
#  One number. Scales enemy HP + per-wave HP bonus.
#  0 = easy (kids who struggle), 1 = normal, 2 = hard (top kids).
#  Try editing this and replaying — same code, different feel.
#  This is "lists indexed by state" — D3 concept in action.
# ============================================================
const DIFFICULTY := 2
const DIFF_HP_MULT := [0.7, 1.5, 3]        # enemy HP multiplier
const DIFF_WAVE_HP_BONUS := [0, 2, 4]        # extra HP per wave index on hard
const DIFF_NAME := ["EASY", "NORMAL", "HARD"]

# --- tower stats (TUNED via _balance/Day3 sim, iter 13 — see BIBLE D3 lock) ---
const TOWER_STATS := {
	"cannon": {"cost": 28, "range": 105.0, "fire_rate": 0.55, "damage": 3,  "hp": 30, "tile": 250, "color": Color(1.0, 0.6, 0.4)},
	"sniper": {"cost": 45, "range": 280.0, "fire_rate": 1.20, "damage": 16, "hp": 25, "tile": 251, "color": Color(0.6, 0.8, 1.0)},
	"splash": {"cost": 47, "range": 115.0, "fire_rate": 0.80, "damage": 5,  "hp": 40, "tile": 252, "color": Color(1.0, 0.9, 0.4)},
}

# --- enemy stats (TUNED) ---
const ENEMY_STATS := {
	"grunt":  {"hp": 18, "speed": 60.0,  "damage_to_base": 2, "tower_dps": 3.5, "reward": 4, "tile": 271, "color": Color(0.85, 0.85, 0.85)},
	"runner": {"hp": 7,  "speed": 115.0, "damage_to_base": 1, "tower_dps": 2.0, "reward": 3, "tile": 270, "color": Color(0.5, 1.0, 0.5)},
}

# --- wave list: each entry is [count, type] — pre-given tuning data ---
const WAVES := [
	[4,  "grunt"],
	[6,  "grunt"],
	[5,  "runner"],
	[8,  "grunt"],
	[8,  "runner"],
	[12, "grunt"],
	[10, "runner"],
	[18, "grunt"],
]

const SPAWN_INTERVAL := 0.7   # seconds between spawns within a wave

# Set to true to swap the wave list for the Final Challenge endless mode.
const ENDLESS_MODE := false

# Toggle this for an optional grid overlay (kids may like the visual).
const DRAW_GRID_LINES := true

# Whether enemy-enemy collision is "soft" (slide on each other).
# Already wired via Enemy.tscn collision_mask = 6 (layers 2 + 4 = enemies + towers).

# --- nodes wired in Main.tscn ---
@onready var base_node: Area2D = $Base
@onready var enemies_node: Node2D = $Enemies
@onready var towers_node: Node2D = $Towers
@onready var flash_layer: Node2D = $FlashLayer
@onready var wave_label: Label = $UI/TopBar/WaveLabel
@onready var coins_label: Label = $UI/TopBar/CoinsLabel
@onready var base_hp_label: Label = $UI/TopBar/BaseHPLabel
@onready var selected_label: Label = $UI/TopBar/SelectedLabel
@onready var hint_label: Label = $UI/ButtonBar/HintLabel
@onready var cannon_btn: Button = $UI/ButtonBar/CannonButton
@onready var sniper_btn: Button = $UI/ButtonBar/SniperButton
@onready var splash_btn: Button = $UI/ButtonBar/SplashButton
@onready var game_over_panel: Panel = $UI/GameOverPanel
@onready var you_win_panel: Panel = $UI/YouWinPanel

# --- preloads ---
const ENEMY_SCENE := preload("res://Enemy.tscn")

# TODO #1: Declare the four pieces of state the game needs to remember: an empty
# list of enemies, an empty list of towers, a coin counter starting at
# START_COINS (90), and a base-HP counter starting at START_BASE_HP (22).
# Without these, nothing else in the file compiles.
#
# Given:
#   - START_COINS      — starting coin constant
#   - START_BASE_HP    — starting base HP constant
#
# Syntax:
#   - var name: Array = []    (empty list)
#   - var name: int = value   (integer with type)
#@todo

# --- other game state (pre-given) ---
var grid: Dictionary = {}          # Vector2i cell -> tower node (occupancy)
var wave_index: int = 0            # 0-based: which wave are we on
var enemies_to_spawn: Array = []   # queue of type strings waiting to spawn this wave
var spawn_cooldown: float = 0.0    # countdown until the next in-wave spawn
var selected_type: String = "cannon"
var game_active: bool = true
var wave_in_progress: bool = false


# ============================================================
#  _ready — once, when the scene loads. Wires signals, draws
#  the grid, sets up wave 1 (auto-starts after a short delay).
# ============================================================
func _ready() -> void:
	randomize()
	game_over_panel.visible = false
	you_win_panel.visible = false

	if DRAW_GRID_LINES:
		draw_grid_lines()

	draw_base_zone()

	base_node.body_entered.connect(_on_base_body_entered)
	cannon_btn.pressed.connect(func(): select_type("cannon"))
	sniper_btn.pressed.connect(func(): select_type("sniper"))
	splash_btn.pressed.connect(func(): select_type("splash"))
	# Single source of truth: button labels driven by TOWER_STATS costs.
	cannon_btn.text = "[1] Cannon $%d" % TOWER_STATS["cannon"]["cost"]
	sniper_btn.text = "[2] Sniper $%d" % TOWER_STATS["sniper"]["cost"]
	splash_btn.text = "[3] Splash $%d" % TOWER_STATS["splash"]["cost"]

	# Wave 1 starts after a short grace period so the player can place
	# a tower or two before the first grunt walks in.
	get_tree().create_timer(2.0).timeout.connect(start_next_wave)

	update_hud()


# ============================================================
#  _process — runs every frame. The game loop lives here.
# ============================================================
func _unhandled_input(event: InputEvent) -> void:
	if not game_active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_at_mouse()


func _process(delta: float) -> void:
	if not game_active:
		return

	# --- input: tower selection hotkeys + restart ---
	if Input.is_action_just_pressed("select_cannon"):  select_type("cannon")
	if Input.is_action_just_pressed("select_sniper"):  select_type("sniper")
	if Input.is_action_just_pressed("select_splash"):  select_type("splash")
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return

	# --- input: SPACE to start the next wave manually ---
	if Input.is_action_just_pressed("start_wave") and not wave_in_progress:
		start_next_wave()

	# --- spawn ticker (drains enemies_to_spawn at SPAWN_INTERVAL) ---
	if wave_in_progress and enemies_to_spawn.size() > 0:
		spawn_cooldown -= delta
		if spawn_cooldown <= 0.0:
			var t: String = enemies_to_spawn.pop_front()
			spawn_enemy(random_edge_cell(), t)
			spawn_cooldown = SPAWN_INTERVAL

	# TODO #3: Every frame, walk through every enemy and call `step_enemy(e, delta)`
	# on it, then walk through every tower and call `tower_tick(t, delta)` on it.
	# Without this chunk, nothing in the game moves or shoots — the enemies just
	# stand at their spawn points.
	#
	# Given:
	#   - enemies              — list of all active enemies
	#   - towers               — list of all placed towers
	#   - delta                — this frame's time (passed in automatically)
	#   - step_enemy(e, delta) — moves one enemy one step
	#   - tower_tick(t, delta) — runs one tower's cooldown + targeting + firing
	#@todo

	# TODO #7: Detect when the current wave is finished (no enemies alive AND no
	# enemies left to spawn). When it is: mark the wave as done, bump the wave
	# counter, and either call `start_next_wave()` or — if we just finished the
	# last wave — call `you_win()`. Without this, wave 1 never ends.
	#
	# Given:
	#   - wave_in_progress      — flag: true while a wave is running
	#   - enemies               — list of active enemies (empty = all dead)
	#   - enemies_to_spawn      — spawn queue (empty = none left to send)
	#   - wave_index            — current wave number (bump by 1 when done)
	#   - WAVES                 — the full wave list (compare size to know if last)
	#   - you_win()             — call if no waves remain
	#   - start_next_wave()     — call if more waves remain
	#
	# Syntax:
	#   - list.size() == 0   (check if list is empty)
	#@todo

	update_hud()


# ============================================================
#  CHUNK #2 — APPEND / ERASE
#
#  Two tiny holes inside two pre-given helpers. Both are one
#  line each. The framing helpers around them are given.
# ============================================================

# spawn_enemy: pre-given EXCEPT the .append() line in TODO #2a.
# Called by the spawner inside _process.
func spawn_enemy(spawn_cell: Vector2i, enemy_type: String) -> void:
	var e := ENEMY_SCENE.instantiate()
	var stats: Dictionary = ENEMY_STATS[enemy_type]
	# Difficulty scaling: base HP * mult + per-wave bonus on hard.
	var scaled_hp: int = int(round(stats["hp"] * DIFF_HP_MULT[DIFFICULTY])) + DIFF_WAVE_HP_BONUS[DIFFICULTY] * wave_index
	e.enemy_type = enemy_type
	e.hp = scaled_hp
	e.max_hp = scaled_hp
	e.speed = stats["speed"]
	e.damage_to_base = stats["damage_to_base"]
	e.tower_dps = stats["tower_dps"]
	e.position = cell_to_world(spawn_cell)
	# Pick a per-enemy attack point near the base so they don't all
	# converge on the same pixel (D10 design lock).
	e.target_pos = pick_base_target()
	# Sprite + tint.
	var spr: Sprite2D = e.get_node("Sprite2D")
	spr.texture = load("res://assets/kenney_td/towerDefense_tile%03d.png" % stats["tile"])
	spr.modulate = stats["color"]
	enemies_node.add_child(e)

	# TODO #2a: After `spawn_enemy` has built a fresh enemy (`e`) and attached it to
	# the scene, add it to the `enemies` list so the game loop knows about it.
	# One line. Without this, every enemy that spawns is invisible to the game
	# logic — it walks toward the base but never gets shot, counted, or removed.
	#
	# Given:
	#   - e         — the freshly built enemy node
	#   - enemies   — the active-enemy list (from #1)
	#
	# Syntax:
	#   - list.append(item)
	#@todo


# kill_enemy: pre-given EXCEPT the .erase() + reward line in TODO #2b.
# Called whenever an enemy's hp drops to 0 (or it reaches the base).
func kill_enemy(e: Node, give_reward: bool = true) -> void:
	if not is_instance_valid(e):
		return
	if give_reward:
		var reward: int = ENEMY_STATS[e.enemy_type]["reward"]

		# TODO #2b: When a tower kills an enemy, two things must happen before the enemy
		# is freed: take it out of the `enemies` list, and pay the player the kill
		# reward. Two lines. Without these, dead enemies stay in the list and the
		# player never earns coins.
		#
		# Given:
		#   - e         — the enemy being killed
		#   - reward    — coin payout for this enemy type
		#   - enemies   — the active-enemy list
		#   - coins     — the player's coin counter
		#
		# Syntax:
		#   - list.erase(item)
		#@todo
	else:
		# TODO #2b (no reward): When an enemy reaches the base, it's gone from the list
		# — but the player gets no coins (the enemy succeeded; no tower killed it).
		# One line. Without this, base-hit enemies stay in the list and waves stack up.
		#
		# Given:
		#   - e         — the enemy that reached the base
		#   - enemies   — the active-enemy list
		#
		# Syntax:
		#   - list.erase(item)
		#@todo
	e.queue_free()


# ============================================================
#  CHUNK #4 — FUNCTION TAKING A LIST
#
#  Refactor of the chunk #3 enemy loop into its own function.
#  Real-life functions group related work so the caller stays
#  short.  This one takes the WHOLE enemies list as its input.
#
#  NOTE: nothing in this scaffold calls move_all() by default —
#  the kid's TODO #3 already iterates the list.  If the kid
#  wants to refactor #3 into a single call to move_all(enemies)
#  they totally can; the function still has to be written either
#  way as the chunk #4 lesson.
# ============================================================
func move_all(enemy_list: Array, delta: float) -> void:
	# TODO #4: Write `move_all(enemy_list, delta)` — same shape as chunk #3's enemy
	# loop, but the list now comes in through the parameter instead of from the
	# file-scope `enemies` variable. The chunk teaches the shape of a list-taking
	# function; nothing in the scaffold calls it by default, but you can refactor
	# chunk #3 to use it.
	#
	# Given:
	#   - enemy_list         — a list of enemies passed in as a parameter
	#   - step_enemy(e, delta)   — moves one enemy one step
	#
	# Syntax:
	#   - func name(list, delta):
	#@todo


# ============================================================
#  CHUNK #5a — FUNCTION RETURNING ONE FROM A LIST
#
#  Used by Cannon and Sniper towers. Scan every enemy, keep
#  track of the closest one that's within the tower's `range`,
#  and return it. Return null if there's nothing in range.
# ============================================================
func get_nearest_enemy_in_range(pos: Vector2, tower_range: float) -> Node:
	# TODO #5a: Scan every enemy, keep track of the closest one that's still within
	# the tower's `tower_range`, and return it. Return `null` if no enemy is in
	# range. Cannon and Sniper towers both use this — it's the load-bearing call
	# for single-target firing.
	#
	# Given:
	#   - enemies      — list of all active enemies
	#   - pos          — the tower's world position
	#   - tower_range  — the tower's firing range
	#   - nearest      — pre-initialized to null (update as you scan)
	#   - best_dist    — pre-initialized to a very large number (update as you scan)
	#
	# Syntax:
	#   - pos.distance_to(e.position)   (distance between two positions)
	#@todo


# ============================================================
#  CHUNK #5b — FUNCTION RETURNING A LIST FROM A LIST
#
#  Used by the Splash tower. Scan every enemy, collect each one
#  that's within `radius` of `pos`, and return them ALL as a
#  brand-new list. Same shape as 5a but you keep going instead
#  of stopping at the first winner.
# ============================================================
func get_enemies_in_radius(pos: Vector2, radius: float) -> Array:
	# TODO #5b: Scan every enemy, and for each one that's within `radius` of `pos`,
	# add it to a result list. After the loop, return the whole list. Splash towers
	# need this — they hit everyone in their radius, not just the closest one.
	#
	# Given:
	#   - enemies   — list of all active enemies
	#   - pos       — the tower's world position
	#   - radius    — the splash radius
	#   - result    — pre-initialized empty list (append to it, then return it)
	#
	# Syntax:
	#   - pos.distance_to(e.position)   (distance between two positions)
	#   - list.append(item)
	#@todo


# ============================================================
#  Pre-given: how each tower decides what to do every frame.
#  Calls into your chunk #5a / #5b / #6 to pick a target and
#  fire at it.
# ============================================================
func tower_tick(t: Node, delta: float) -> void:
	if not is_instance_valid(t):
		return
	# cooldown ticks down
	t.set_meta("cooldown", t.get_meta("cooldown", 0.0) - delta)
	if t.get_meta("cooldown", 0.0) > 0.0:
		return

	var t_type: String = t.get_meta("type")
	var t_range: float = TOWER_STATS[t_type]["range"]
	var t_rate: float = TOWER_STATS[t_type]["fire_rate"]
	var t_damage: int = TOWER_STATS[t_type]["damage"]

	# TODO #6: Two branches, one chunk. Cannon and Sniper share a branch (single-
	# target via #5a). Splash gets its own branch (list-target via #5b). In each
	# branch, pick the target, fire if there's something to hit, reset the tower's
	# cooldown. This is the chunk that actually makes the game playable — until
	# #6a + #6b are filled, towers stand still and never shoot.
	#
	# Given:
	#   - get_nearest_enemy_in_range(pos, range)   — returns one enemy or null (#5a)
	#   - get_enemies_in_radius(pos, radius)        — returns a list of enemies (#5b)
	#   - fire_at(t, target, damage)               — fires at a single enemy or list
	#   - t.position, t_range, t_damage, t_rate    — tower stats (already unpacked)
	#   - t.set_meta("cooldown", t_rate)           — resets the tower's cooldown
	match t_type:
		"cannon", "sniper":
			# TODO #6a — single-target branch (Cannon + Sniper)
			#@todo
		"splash":
			# TODO #6b — list-target branch (Splash)
			#@todo


# ============================================================
#  Pre-given: actually deal damage + draw a Line2D flash.
#  Branches on whether `target` is a single node or a list.
# ============================================================
func fire_at(t: Node, target, damage: int) -> void:
	if target is Array:
		for e in target:
			if is_instance_valid(e):
				spawn_flash(t.position, e.position)
				damage_enemy(e, damage)
	else:
		if is_instance_valid(target):
			spawn_flash(t.position, target.position)
			damage_enemy(target, damage)


# ============================================================
#  Pre-given: enemy + tower lifecycle helpers.
# ============================================================
func step_enemy(e: Node, delta: float) -> void:
	if not is_instance_valid(e):
		return
	# Already hit the base this frame — sitting dead, waiting for free.
	if not e.visible:
		return

	# Drift toward our personal attack point on the base.
	var to_target: Vector2 = e.target_pos - e.position
	if to_target.length() < 4.0:
		to_target = base_node.position - e.position

	var forward: Vector2 = to_target.normalized()
	var step: Vector2 = forward * e.speed * delta
	var collision: KinematicCollision2D = e.move_and_collide(step)
	if collision != null:
		# Blocked — nudge perpendicular once (random left or right) and
		# let the next frame try forward again.
		var side: float = -1.0 if randf() < 0.5 else 1.0
		var perp: Vector2 = Vector2(-forward.y, forward.x) * side
		e.move_and_collide(perp * e.speed * delta)


func damage_enemy(e: Node, damage: int) -> void:
	if not is_instance_valid(e):
		return
	e.hp -= damage
	if e.hp <= 0:
		kill_enemy(e, true)


func damage_tower(t: Node, amount: float) -> void:
	if not is_instance_valid(t):
		return
	var cur_hp: float = t.get_meta("hp")
	cur_hp -= amount
	t.set_meta("hp", cur_hp)
	if cur_hp <= 0.0:
		kill_tower(t)


func kill_tower(t: Node) -> void:
	if not is_instance_valid(t):
		return
	var cell: Vector2i = t.get_meta("cell")
	if grid.has(cell):
		grid.erase(cell)
	towers.erase(t)
	t.queue_free()
	# No coin refund (user-locked).


func _on_base_body_entered(body: Node) -> void:
	if not game_active:
		return
	if body in enemies:
		base_hp -= body.damage_to_base
		# Immediate visual feedback — hide the enemy now so the kid sees
		# it vanish on contact. Drop its collision layer so no second
		# body_entered fires before the deferred free runs.
		body.visible = false
		body.collision_layer = 0
		# Defer kill_enemy to avoid mutating the enemies list while
		# the kid's TODO #3 for-loop may be iterating it.
		call_deferred("kill_enemy", body, false)
		if base_hp <= 0:
			call_deferred("game_over")


# ============================================================
#  Pre-given: tower placement (mouse → cell → instantiate).
# ============================================================
func try_place_at_mouse() -> void:
	if not game_active:
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	var cell: Vector2i = world_to_cell(mouse_pos)
	if cell.x < 0 or cell.x >= GRID_W or cell.y < 0 or cell.y >= GRID_H:
		return
	if cell == BASE_CELL_A or cell == BASE_CELL_B:
		return
	if grid.has(cell):
		return
	var cost: int = TOWER_STATS[selected_type]["cost"]
	if coins < cost:
		return
	coins -= cost
	place_tower_at(cell, selected_type)


func place_tower_at(cell: Vector2i, t_type: String) -> void:
	var t := Node2D.new()
	t.position = cell_to_world(cell)
	t.set_meta("kind", "tower")
	t.set_meta("type", t_type)
	t.set_meta("cell", cell)
	t.set_meta("cooldown", 0.0)
	t.set_meta("hp", float(TOWER_STATS[t_type]["hp"]))
	t.set_meta("max_hp", float(TOWER_STATS[t_type]["hp"]))

	# Sprite
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/kenney_td/towerDefense_tile%03d.png" % TOWER_STATS[t_type]["tile"])
	spr.modulate = TOWER_STATS[t_type]["color"]
	spr.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	t.add_child(spr)

	# Towers no longer have a collision body — enemies walk through them.
	# Map obstacles in Main.tscn (Scenery/Obstacle*) handle pathing friction.

	towers_node.add_child(t)
	towers.append(t)
	grid[cell] = t


# ============================================================
#  Pre-given: visuals + helpers.
# ============================================================
func spawn_flash(from_pos: Vector2, to_pos: Vector2) -> void:
	var line := Line2D.new()
	line.add_point(from_pos)
	line.add_point(to_pos)
	line.width = 3.0
	line.default_color = Color(1, 1, 0.4, 1)
	flash_layer.add_child(line)
	var tw := create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.12)
	tw.tween_callback(line.queue_free)


func draw_base_zone() -> void:
	# Outline of the base damage rectangle (matches the Base Area2D's
	# RectangleShape2D). Enemies that enter this red box hit the base.
	var shape: RectangleShape2D = base_node.get_node("CollisionShape2D").shape
	var half: Vector2 = shape.size * 0.5
	var line := Line2D.new()
	line.add_point(Vector2(-half.x, -half.y))
	line.add_point(Vector2( half.x, -half.y))
	line.add_point(Vector2( half.x,  half.y))
	line.add_point(Vector2(-half.x,  half.y))
	line.add_point(Vector2(-half.x, -half.y))
	line.width = 2.0
	line.default_color = Color(1.0, 0.25, 0.25, 0.85)
	base_node.add_child(line)


func draw_grid_lines() -> void:
	var grid_node: Node2D = $Grid
	for x in range(GRID_W + 1):
		var l := Line2D.new()
		l.add_point(Vector2(x * TILE, 0))
		l.add_point(Vector2(x * TILE, GRID_H * TILE))
		l.width = 1.0
		l.default_color = Color(1, 1, 1, 0.06)
		grid_node.add_child(l)
	for y in range(GRID_H + 1):
		var l := Line2D.new()
		l.add_point(Vector2(0, y * TILE))
		l.add_point(Vector2(GRID_W * TILE, y * TILE))
		l.width = 1.0
		l.default_color = Color(1, 1, 1, 0.06)
		grid_node.add_child(l)


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)


func world_to_cell(world: Vector2) -> Vector2i:
	return Vector2i(floori(world.x / TILE), floori(world.y / TILE))


func pick_base_target() -> Vector2:
	# Random cell adjacent to the base — gives each enemy its own
	# attack waypoint so they don't pile on the same pixel.
	var candidates: Array = [
		Vector2i(BASE_CELL_A.x - 1, BASE_CELL_A.y),  Vector2i(BASE_CELL_B.x + 1, BASE_CELL_B.y),
		Vector2i(BASE_CELL_A.x, BASE_CELL_A.y - 1),  Vector2i(BASE_CELL_B.x, BASE_CELL_B.y - 1),
		Vector2i(BASE_CELL_A.x, BASE_CELL_A.y + 1),  Vector2i(BASE_CELL_B.x, BASE_CELL_B.y + 1),
	]
	var c: Vector2i = candidates[randi() % candidates.size()]
	return cell_to_world(c)


func random_edge_cell() -> Vector2i:
	# Spawn at a random tile on one of the 4 outer rows/columns.
	var edge: int = randi() % 4
	match edge:
		0: return Vector2i(randi() % GRID_W, 0)              # top
		1: return Vector2i(randi() % GRID_W, GRID_H - 1)     # bottom
		2: return Vector2i(0, randi() % GRID_H)              # left
		_: return Vector2i(GRID_W - 1, randi() % GRID_H)     # right


# ============================================================
#  Pre-given: wave logic + selection + UI + end states.
# ============================================================
func start_next_wave() -> void:
	if not game_active:
		return
	if wave_index >= WAVES.size():
		return
	wave_in_progress = true
	var w: Array = WAVES[wave_index]
	var count: int = w[0]
	var enemy_type: String = w[1]
	enemies_to_spawn = []
	for i in range(count):
		enemies_to_spawn.append(enemy_type)
	spawn_cooldown = 0.0


func select_type(t_type: String) -> void:
	selected_type = t_type


func update_hud() -> void:
	wave_label.text = "Wave: %d / %d" % [min(wave_index + 1, WAVES.size()), WAVES.size()]
	coins_label.text = "Coins: %d" % coins
	base_hp_label.text = "Base: %d HP" % max(base_hp, 0)
	var cost: int = TOWER_STATS[selected_type]["cost"]
	selected_label.text = "Selected: %s ($%d)" % [selected_type.capitalize(), cost]
	if wave_in_progress:
		hint_label.text = "  Wave in progress — survive!"
	elif wave_index >= WAVES.size():
		hint_label.text = "  All waves cleared."
	else:
		hint_label.text = "  Press SPACE to start next wave."


func you_win() -> void:
	game_active = false
	you_win_panel.visible = true


func game_over() -> void:
	game_active = false
	game_over_panel.visible = true
