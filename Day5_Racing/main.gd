extends Node3D

var paused: bool = false

@onready var car: Node3D = $Car
@onready var track: Node3D = $Track
@onready var camera_rig: Node3D = $CameraRig
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var race_complete_panel: Panel = $UI/RaceCompletePanel
@onready var pause_panel: Panel = $UI/PausePanel


func _ready() -> void:
	if track.has_signal("lap_completed"):
		track.lap_completed.connect(on_lap_completed)
	if track.has_signal("race_complete"):
		track.race_complete.connect(on_race_complete)
	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)
	countdown_label.visible = false
	race_complete_panel.visible = false
	pause_panel.visible = false


func _process(_delta: float) -> void:
	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)


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
