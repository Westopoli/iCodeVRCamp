extends Node2D

# === Constants ===
const PLAYER_SCENE := preload("res://Player.tscn")

const CHARACTERS := {
	"knight": {
		"display_name": "Knight",
		"sprite": "res://assets/kenney_pp/characters/tile_0000.png",
		"tint": Color(0.7, 0.85, 1.0),
		"walk_speed": 220.0,
		"jump_impulse": 520.0,
		"attack_type": "melee",
		"attack_damage": 18,
		"attack_cooldown": 0.55,
		"attack_range": 70.0,
		"projectile_speed": 0.0,
		"projectile_gravity_scale": 0.0,
	},
	"ninja": {
		"display_name": "Ninja",
		"sprite": "res://assets/kenney_pp/characters/tile_0001.png",
		"tint": Color(1.0, 0.85, 0.85),
		"walk_speed": 320.0,
		"jump_impulse": 560.0,
		"attack_type": "melee",
		"attack_damage": 10,
		"attack_cooldown": 0.30,
		"attack_range": 55.0,
		"projectile_speed": 0.0,
		"projectile_gravity_scale": 0.0,
	},
	"mage": {
		"display_name": "Mage",
		"sprite": "res://assets/kenney_pp/characters/tile_0002.png",
		"tint": Color(0.9, 0.7, 1.0),
		"walk_speed": 240.0,
		"jump_impulse": 500.0,
		"attack_type": "projectile",
		"attack_damage": 16,
		"attack_cooldown": 0.80,
		"attack_range": 0.0,
		"projectile_speed": 380.0,
		"projectile_gravity_scale": 1.0,
	},
	"archer": {
		"display_name": "Archer",
		"sprite": "res://assets/kenney_pp/characters/tile_0003.png",
		"tint": Color(0.85, 1.0, 0.85),
		"walk_speed": 280.0,
		"jump_impulse": 520.0,
		"attack_type": "projectile",
		"attack_damage": 8,
		"attack_cooldown": 0.45,
		"attack_range": 0.0,
		"projectile_speed": 700.0,
		"projectile_gravity_scale": 0.05,
	},
}

# To change a map's platform color: find the map below and edit its Color(r, g, b) value.
# Each channel is 0.0 (dark) to 1.0 (bright) — e.g. Color(1, 0, 0) is pure red.
const MAPS := {
	"battlefield": {
		"display_name": "Battlefield",
		"color": Color(0.35, 0.28, 0.12),   # earthy brown
		"platforms": [
			[0,    600, 1280, 120, false],
			[300,  420, 200,  16,  true],
			[780,  420, 200,  16,  true],
			[540,  280, 200,  16,  true],
		],
	},
	"final_destination": {
		"display_name": "Final Destination",
		"color": Color(0.12, 0.12, 0.22),   # dark space blue
		"platforms": [
			[0, 600, 1280, 120, false],
		],
	},
	"pokemon_stadium": {
		"display_name": "Pokémon Stadium",
		"color": Color(0.55, 0.20, 0.15),   # arena red
		"platforms": [
			[0,   600, 1280, 120, false],
			[240, 440, 200,  16,  true],
			[840, 380, 200,  16,  true],
		],
	},
}

# === Public state ===
var player1: Node = null
var player2: Node = null
var projectiles_node: Node2D
var map_root: Node2D
var fight_active: bool = false
var current_screen: String = "char_select_p1"
var p1_choice: String = ""
var p2_choice: String = ""
var map_choice: String = ""
var winner: int = 0
var countdown_remaining: float = 0.0
var end_auto_restart: float = 0.0

# === Onready ===
@onready var char_select_panel: Panel = $UI/CharSelectPanel
@onready var title_label: Label = $UI/CharSelectPanel/TitleLabel
@onready var map_select_panel: Panel = $UI/MapSelectPanel
@onready var map_title: Label = $UI/MapSelectPanel/MapTitle
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var win_label: Label = $UI/WinLabel
@onready var hud_label: Label = $UI/HudLabel

# === Methods ===

func _ready() -> void:
	projectiles_node = $Projectiles
	build_borders()
	set_screen("char_select_p1")

func build_borders() -> void:
	# left, right, top walls — keep players on-screen. floor handled per-map.
	var specs := [
		[-20, 360, 40, 720],   # left
		[1300, 360, 40, 720],  # right
		[640, -20, 1280, 40],  # top
	]
	for s in specs:
		var body := StaticBody2D.new()
		body.position = Vector2(s[0], s[1])
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(s[2], s[3])
		shape.shape = rect
		body.add_child(shape)
		add_child(body)

func set_screen(s: String) -> void:
	current_screen = s
	char_select_panel.visible = (s == "char_select_p1" or s == "char_select_p2")
	map_select_panel.visible = (s == "map_select")
	countdown_label.visible = (s == "countdown")
	win_label.visible = (s == "end")
	hud_label.visible = (s in ["countdown", "fight"])
	if s == "char_select_p1":
		title_label.text = "P1 — pick your fighter:\n1 = Knight   2 = Ninja   3 = Mage   4 = Archer\n(Space confirms)"
	elif s == "char_select_p2":
		title_label.text = "P2 — pick your fighter:\n1 = Knight   2 = Ninja   3 = Mage   4 = Archer\n(Space confirms)"
	elif s == "map_select":
		map_title.text = "Pick your map:\n1 = Battlefield   2 = Final Destination   3 = Pokémon Stadium\n(Space confirms)"
	elif s == "countdown":
		countdown_remaining = 3.0
		fight_active = false
		hud_label.text = "%s  vs  %s   on   %s" % [CHARACTERS[p1_choice]["display_name"], CHARACTERS[p2_choice]["display_name"], MAPS[map_choice]["display_name"]]
	elif s == "fight":
		fight_active = true
	elif s == "end":
		fight_active = false
		end_auto_restart = 4.0
		win_label.text = "P%d WINS!\n(Press R or wait — back to character select)" % winner

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key_num = -1
	if event.keycode >= KEY_1 and event.keycode <= KEY_4:
		key_num = event.keycode - KEY_1 + 1
	var keys = ["knight", "ninja", "mage", "archer"]
	match current_screen:
		"char_select_p1":
			if key_num >= 1 and key_num <= 4:
				p1_choice = keys[key_num - 1]
				set_screen("char_select_p2")
		"char_select_p2":
			if key_num >= 1 and key_num <= 4:
				p2_choice = keys[key_num - 1]
				set_screen("map_select")
		"map_select":
			var maps = ["battlefield", "final_destination", "pokemon_stadium"]
			if key_num >= 1 and key_num <= 3:
				map_choice = maps[key_num - 1]
				start_match(p1_choice, p2_choice, map_choice)
		"end":
			if event.keycode == KEY_R:
				restart_to_char_select()
		"fight":
			if event.keycode == KEY_R:
				restart_to_char_select()

func _process(delta: float) -> void:
	if current_screen == "countdown":
		countdown_remaining -= delta
		var n = int(ceil(countdown_remaining))
		countdown_label.text = "GO!" if n <= 0 else str(n)
		if countdown_remaining <= 0.0:
			set_screen("fight")
	elif current_screen == "end":
		end_auto_restart -= delta
		if end_auto_restart <= 0.0:
			restart_to_char_select()

func start_match(p1_char: String, p2_char: String, map_id: String) -> void:
	clear_match_state()
	build_map(map_id)

	# TODO #4: Spawn the two fighters — build one Player instance for P1 and one for P2 from the same scene, add each to the tree, and set them up at opposite ends of the map.
	#
	# Syntax:
	#   - var node = SCENE.instantiate()
	#   - add_child(node)
	#   - node.method(args)
	#
	# Given:
	#   PLAYER_SCENE    — the preloaded Player scene (use .instantiate() to build one)
	#   player1         — variable to store the P1 node
	#   player2         — variable to store the P2 node
	#   p1_char         — the character name string P1 chose
	#   p2_char         — the character name string P2 chose
	#   add_child()     — Godot built-in; puts a node into the scene tree so it runs
	#
	# Line by line:
	#   func start_match(p1_char: String, p2_char: String, map_id: String) -> void:
	#       Create a new Player 1 instance from the player scene
	#       Add Player 1 to the game world so it exists and runs
	#       Set up Player 1 as player number 1 with their chosen character on the left side
	#       Create a new Player 2 instance from the player scene
	#       Add Player 2 to the game world so it exists and runs
	#       Set up Player 2 as player number 2 with their chosen character on the right side
	#@todo
	player1 = PLAYER_SCENE.instantiate()
	add_child(player1)
	player1.setup(1, p1_char, Vector2(200, 500))
	player2 = PLAYER_SCENE.instantiate()
	add_child(player2)
	player2.setup(2, p2_char, Vector2(1080, 500))
	#@end

	set_screen("countdown")

func build_map(map_id: String) -> void:
	if map_root and is_instance_valid(map_root):
		map_root.queue_free()
	map_root = Node2D.new()
	map_root.name = "MapRoot"
	add_child(map_root)
	var data: Dictionary = MAPS[map_id]
	for plat in data["platforms"]:
		var x = plat[0]; var y = plat[1]; var w = plat[2]; var h = plat[3]; var one_way = plat[4]
		var body := StaticBody2D.new()
		body.position = Vector2(x + w / 2.0, y + h / 2.0)
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(w, h)
		shape.shape = rect
		shape.one_way_collision = one_way
		body.add_child(shape)
		var cr := ColorRect.new()
		cr.size = Vector2(w, h)
		cr.position = Vector2(-w / 2.0, -h / 2.0)
		cr.color = data["color"]
		body.add_child(cr)
		map_root.add_child(body)

func on_player_died(p: Node) -> void:
	if winner != 0:
		return
	winner = 2 if p.player_num == 1 else 1
	set_screen("end")

func clear_match_state() -> void:
	if player1 and is_instance_valid(player1):
		player1.queue_free()
	if player2 and is_instance_valid(player2):
		player2.queue_free()
	for child in projectiles_node.get_children():
		child.queue_free()
	player1 = null
	player2 = null
	winner = 0

func restart_to_char_select() -> void:
	clear_match_state()
	if map_root and is_instance_valid(map_root):
		map_root.queue_free()
		map_root = null
	p1_choice = ""
	p2_choice = ""
	map_choice = ""
	set_screen("char_select_p1")
