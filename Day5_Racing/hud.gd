extends CanvasLayer

@onready var speed_label: Label = $HUD/SpeedLabel
@onready var lap_label: Label = $HUD/LapLabel
@onready var current_time_label: Label = $HUD/CurrentTimeLabel
@onready var best_time_label: Label = $HUD/BestTimeLabel
@onready var drift_label: Label = $HUD/DriftLabel

var lap_start: float = 0.0
var best_lap: float = INF
var current_lap: int = 1
var lap_count: int = 3

func _ready() -> void:
	var car = get_tree().get_first_node_in_group("car")
	if car == null:
		print("hud.gd: warning — no node in group 'car' found at _ready")
		return
	if car.has_signal("speed_changed"):
		car.speed_changed.connect(on_speed_changed)
	if car.has_signal("slide_changed"):
		car.slide_changed.connect(on_slide_changed)

func _process(_delta: float) -> void:
	current_time_label.text = "%.2fs" % (Time.get_ticks_msec() / 1000.0 - lap_start)

func on_speed_changed(speed_ms: float) -> void:
	speed_label.text = "%.0f km/h" % (speed_ms * 3.6)

func on_slide_changed(angle_deg: float) -> void:
	drift_label.text = "Drift: %d" % int(abs(angle_deg)) + "°"

func on_lap_started() -> void:
	lap_start = Time.get_ticks_msec() / 1000.0

func on_lap_completed(time_s: float, is_best: bool) -> void:
	if is_best:
		best_lap = time_s
		best_time_label.text = "Best: %.2fs" % best_lap
	current_lap += 1
	lap_label.text = "Lap %d / %d" % [current_lap, lap_count]

func format_seconds(s: float) -> String:
	return "%.2f" % s
