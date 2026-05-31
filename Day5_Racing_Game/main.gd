@tool
extends Node3D

# Closed loop, right turns only (clockwise rounded square). Four 20m sides + four
# 90-degree corners return to the start heading. Milestone 1 layout; richer
# AoR layouts (left turns, sweepers, hairpins, chicanes, S-curves) land once the
# corner convention is confirmed in-engine.
const LAYOUT := [
	"Start", "Straight_Long", "Straight_Long", "90_R",
	"Straight_Long", "Straight_Long", "Straight_Short", "90_R",
	"Straight_Long", "Straight_Long", "Straight_Short", "90_R",
	"Straight_Long", "Straight_Long", "Finish", "90_R",
]

var paused: bool = false
var _car_start := Transform3D.IDENTITY
var ghost: Node3D = null

@onready var car: Node3D = $Car
@onready var track: Node3D = $Track
@onready var camera_rig: Node3D = $CameraRig
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var ghost_container: Node3D = $GhostContainer
@onready var hud: CanvasLayer = $UI
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var race_complete_panel: Panel = $UI/RaceCompletePanel
@onready var pause_panel: Panel = $UI/PausePanel


func _ready() -> void:
	# Build the track in the editor too, so the layout is visible before play.
	# Preview pieces are owner-less (not saved into Main.tscn) — they regenerate
	# on every scene load / script reload.
	var info := TrackBuilder.build(track, LAYOUT)
	_car_start = info["car_start"]
	_place_car()

	if Engine.is_editor_hint():
		return

	var ghost_scene: PackedScene = load("res://GhostCar.tscn")
	ghost = ghost_scene.instantiate()
	ghost_container.add_child(ghost)
	ghost.visible = false

	if track.has_method("setup_triggers"):
		track.setup_triggers()
	if track.has_signal("lap_started"):
		track.lap_started.connect(on_lap_started)
	if track.has_signal("lap_completed"):
		track.lap_completed.connect(on_lap_completed)
	if track.has_signal("race_complete"):
		track.race_complete.connect(on_race_complete)

	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)
	countdown_label.visible = false
	race_complete_panel.visible = false
	pause_panel.visible = false

	# Timing starts now; crossing the start line after all 3 checkpoints = lap done.
	if track.has_method("start_race"):
		track.start_race()


func _place_car() -> void:
	# Sit the car on the middle of the Start tile, facing -Z (into the track).
	var spawn := _car_start.origin + Vector3(0, 1.0, -2.0)
	if car.has_method("set_start_point"):
		car.set_start_point(spawn)
	if car.has_method("reset_position"):
		car.reset_position()
	else:
		car.global_transform = Transform3D(Basis(), spawn)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		_place_car()
		if track.has_method("reset_race"):
			track.reset_race()
		if track.has_method("start_race"):
			track.start_race()
		if ghost:
			ghost.reset()
		race_complete_panel.visible = false
	elif event.is_action_pressed("pause"):
		paused = not paused
		get_tree().paused = paused
		pause_panel.visible = paused
	elif event.is_action_pressed("quit_game"):
		get_tree().quit()


func on_lap_started() -> void:
	if car.has_method("begin_lap"):
		car.begin_lap()
	if ghost:
		ghost.reset()
	if hud.has_method("on_lap_started"):
		hud.on_lap_started()


func on_lap_completed(time_s: float, is_best: bool) -> void:
	# Capture the just-finished lap as the ghost line whenever it's a new best.
	if is_best and ghost and "lap_history" in car:
		ghost.set_snapshots(car.lap_history.duplicate(true))
	if hud.has_method("on_lap_completed"):
		hud.on_lap_completed(time_s, is_best)
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
