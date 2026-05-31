extends Node3D

var paused: bool = false
var _debug_tick: float = 0.0

@onready var car: Node3D = $Car
@onready var track: Node3D = $Track
@onready var camera_rig: Node3D = $CameraRig
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var race_complete_panel: Panel = $UI/RaceCompletePanel
@onready var pause_panel: Panel = $UI/PausePanel


func _ready() -> void:
	print("[MAIN] _ready: car=", car, " pos=", car.position if car else "null")
	print("[MAIN] _ready: track=", track, " children=", track.get_child_count() if track else -1)
	if track:
		var starter := track.get_node_or_null("StarterTrack")
		print("[MAIN] StarterTrack children=", starter.get_child_count() if starter else -1)
		var obstacles := track.get_node_or_null("Obstacles")
		print("[MAIN] Obstacles children=", obstacles.get_child_count() if obstacles else -1)
	print("[MAIN] car_groups=", car.get_groups() if car else "n/a")
	if track.has_signal("lap_completed"):
		track.lap_completed.connect(on_lap_completed)
	if track.has_signal("race_complete"):
		track.race_complete.connect(on_race_complete)
	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)
	countdown_label.visible = false
	race_complete_panel.visible = false
	pause_panel.visible = false
	print("[MAIN] _ready done: cam_rig=", camera_rig.position, " cam_global=", camera.global_position)
	_probe_prefab_aabbs()


func _probe_prefab_aabbs() -> void:
	var names := ["Start", "Finish", "Straight_Short", "Straight_Long",
		"Hairpin_L", "Hairpin_R", "Sweeper_L", "Sweeper_R",
		"Chicane", "90_L", "90_R", "S_curve"]
	for n in names:
		var path := "res://prefabs/%s.tscn" % n
		var packed: PackedScene = load(path)
		if packed == null:
			print("[PROBE] ", n, " FAILED load")
			continue
		var inst: Node3D = packed.instantiate()
		add_child(inst)
		await get_tree().process_frame
		var aabb := _aggregate_aabb(inst)
		print("[PROBE] ", n, " AABB pos=", aabb.position, " size=", aabb.size)
		inst.queue_free()


func _aggregate_aabb(node: Node) -> AABB:
	var result := AABB()
	var first := true
	for child in _iter_descendants(node):
		if child is VisualInstance3D:
			var vi: VisualInstance3D = child
			var a := vi.get_aabb()
			a = vi.global_transform * a
			if first:
				result = a
				first = false
			else:
				result = result.merge(a)
	return result


func _iter_descendants(node: Node) -> Array:
	var out: Array = [node]
	for c in node.get_children():
		out.append_array(_iter_descendants(c))
	return out


func _process(delta: float) -> void:
	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)
	_debug_tick += delta
	if _debug_tick >= 1.0:
		_debug_tick = 0.0
		print("[MAIN] tick: car.pos=", car.position, " cam_rig.pos=", camera_rig.position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		if car.has_method("reset_position"):
			car.reset_position()
		if track.has_method("reset_race"):
			track.reset_race()
		race_complete_panel.visible = false
	elif event.is_action_pressed("pause"):
		paused = not paused
		get_tree().paused = paused
		pause_panel.visible = paused
	elif event.is_action_pressed("quit_game"):
		get_tree().quit()


func on_lap_completed(time_s: float, is_best: bool) -> void:
	var lap_text: String = "Lap done - %.2fs" % time_s
	if is_best:
		lap_text += " (PB!)"
	countdown_label.text = lap_text
	countdown_label.visible = true
	await get_tree().create_timer(2.0).timeout
	countdown_label.visible = false


func on_race_complete(total_time: float, best_lap: float) -> void:
	var label: Label = race_complete_panel.get_node("Label")
	label.text = "RACE COMPLETE\nTotal: %.2fs\nBest Lap: %.2fs\nR to restart" % [total_time, best_lap]
	race_complete_panel.visible = true
