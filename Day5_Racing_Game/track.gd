extends Node3D

signal lap_started
signal lap_completed(time_s: float, is_best: bool)
signal race_complete(total_time: float, best_lap: float)
signal checkpoint_passed(idx: int)

const BEST_TIMES_PATH := "user://best_times.json"

@export var lap_count_target: int = 3

var next_checkpoint: int = 0
var current_lap: int = 1
var lap_start_time: float = 0.0
var race_start_time: float = 0.0
var best_lap_time: float = INF
var race_active: bool = false

@onready var car: Node = get_tree().get_first_node_in_group("car")


func _ready() -> void:
	_load_best_time()


# Called by main.gd AFTER TrackBuilder has spawned StartLine + checkpoints
# (the builder runs in main._ready, which fires after this node's _ready).
func setup_triggers() -> void:
	car = get_tree().get_first_node_in_group("car")
	var start_line := get_node_or_null("StartLine")
	if start_line and start_line.has_signal("body_entered"):
		start_line.body_entered.connect(_on_start_line_entered)
	for i in [1, 2, 3]:
		var cp := get_node_or_null("Checkpoint%d" % i)
		if cp and cp.has_signal("body_entered"):
			cp.body_entered.connect(_on_checkpoint_entered.bind(i))


func _on_start_line_entered(body: Node) -> void:
	if car == null:
		car = get_tree().get_first_node_in_group("car")
	if body != car:
		return
	if next_checkpoint == 0:
		if not race_active:
			start_race()
	elif next_checkpoint == 3:
		lap_complete()


func _on_checkpoint_entered(body: Node, idx: int) -> void:
	if car == null:
		car = get_tree().get_first_node_in_group("car")
	if body != car:
		return
	if idx == next_checkpoint + 1:
		next_checkpoint = idx
		checkpoint_passed.emit(idx)


func start_race() -> void:
	race_active = true
	race_start_time = Time.get_ticks_msec() / 1000.0
	lap_start_time = race_start_time
	lap_started.emit()


func lap_complete() -> void:
	var t := Time.get_ticks_msec() / 1000.0 - lap_start_time
	var is_best := t < best_lap_time
	if is_best:
		best_lap_time = t
		_save_best_time()
	lap_completed.emit(t, is_best)
	current_lap += 1
	next_checkpoint = 0
	if current_lap > lap_count_target:
		var total := Time.get_ticks_msec() / 1000.0 - race_start_time
		race_complete.emit(total, best_lap_time)
		race_active = false
	else:
		lap_start_time = Time.get_ticks_msec() / 1000.0
		lap_started.emit()


func reset_race() -> void:
	race_active = false
	next_checkpoint = 0
	current_lap = 1
	best_lap_time = INF
	_load_best_time()


func _track_key() -> String:
	var s := get_tree().current_scene
	if s:
		return s.scene_file_path
	return "default"


func _load_best_time() -> void:
	if not FileAccess.file_exists(BEST_TIMES_PATH):
		return
	var f := FileAccess.open(BEST_TIMES_PATH, FileAccess.READ)
	if f == null:
		return
	var txt := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		return
	var key := _track_key()
	if data.has(key):
		best_lap_time = float(data[key])


func _save_best_time() -> void:
	var data: Dictionary = {}
	if FileAccess.file_exists(BEST_TIMES_PATH):
		var rf := FileAccess.open(BEST_TIMES_PATH, FileAccess.READ)
		if rf:
			var txt := rf.get_as_text()
			rf.close()
			var parsed: Variant = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY:
				data = parsed
	data[_track_key()] = best_lap_time
	var wf := FileAccess.open(BEST_TIMES_PATH, FileAccess.WRITE)
	if wf:
		wf.store_string(JSON.stringify(data))
		wf.close()
