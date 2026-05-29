extends VehicleBody3D

@export var suspension_stiffness: float = 50.0
@export var suspension_travel: float = 0.25
@export var damping_compression: float = 0.5
@export var damping_relaxation: float = 0.7

signal speed_changed(speed_ms: float)
signal slide_changed(angle_deg: float)

var sim_config: Dictionary = {}
var lap_history: Array = []
var lap_history_dt: float = 0.1
var _snapshot_accumulator: float = 0.0
var _lap_start_time: float = 0.0
var _dbg_phys_counter: int = 0


func _ready() -> void:
	print("[CAR] _ready: in_tree=", is_inside_tree(), " global_pos=", global_position, " groups=", get_groups())
	var f := FileAccess.open("res://car_tune.json", FileAccess.READ)
	if f:
		sim_config = JSON.parse_string(f.get_as_text())
		f.close()
		print("[CAR] tune loaded keys=", sim_config.keys())
	else:
		print("[CAR] tune FAILED to open res://car_tune.json")
	if sim_config.has("mass"):
		self.mass = sim_config["mass"]
	for wheel_name in ["Wheel_FL", "Wheel_FR", "Wheel_RL", "Wheel_RR"]:
		var w: VehicleWheel3D = get_node(wheel_name)
		w.suspension_stiffness = suspension_stiffness
		w.suspension_travel = suspension_travel
		w.damping_compression = damping_compression
		w.damping_relaxation = damping_relaxation
	var glb_path := "res://assets/kenney_racing/raceCarRed.glb"
	var glb_res := load(glb_path)
	print("[CAR] GLB load: path=", glb_path, " res=", glb_res)
	if has_node("VisualSlot"):
		var v = preload("res://assets/kenney_racing/raceCarRed.glb").instantiate()
		$VisualSlot.add_child(v)
		print("[CAR] GLB added to VisualSlot, child_count=", $VisualSlot.get_child_count())
	else:
		var v2 = preload("res://assets/kenney_racing/raceCarRed.glb").instantiate()
		add_child(v2)
		print("[CAR] GLB added to self (no VisualSlot)")
	if not is_in_group("car"):
		add_to_group("car")
		print("[CAR] joined 'car' group (was missing)")


func _physics_process(delta: float) -> void:
	var throttle: float = Input.get_action_strength("throttle")
	var brake_input: float = Input.get_action_strength("brake")
	var steer_input: float = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var handbrake: bool = Input.is_action_pressed("handbrake")
	_dbg_phys_counter += 1
	if _dbg_phys_counter >= 30:
		_dbg_phys_counter = 0
		var fl_dbg: VehicleWheel3D = $Wheel_FL
		var rl_dbg: VehicleWheel3D = $Wheel_RL
		print("[CARPHYS] thr=", throttle, " brk=", brake_input, " steer=", steer_input, " hb=", handbrake,
			" pos.y=", position.y, " vel=", linear_velocity.length(),
			" fl_contact=", fl_dbg.is_in_contact(), " rl_contact=", rl_dbg.is_in_contact())

	var max_steer: float = sim_config.get("max_steer_angle", 0.45)
	var engine_force_val: float = sim_config.get("engine_force", 4500.0)
	var brake_force_val: float = sim_config.get("brake_force", 8000.0)
	var front_grip: float = sim_config.get("front_grip", 1.0)
	var rear_grip: float = sim_config.get("rear_grip", 1.0)
	var hb_mult: float = sim_config.get("handbrake_grip_multiplier", 0.25)
	var ps_threshold: float = sim_config.get("throttle_powerslide_threshold", 0.5)

	var fl: VehicleWheel3D = $Wheel_FL
	var fr: VehicleWheel3D = $Wheel_FR
	var rl: VehicleWheel3D = $Wheel_RL
	var rr: VehicleWheel3D = $Wheel_RR

	fl.steering = max_steer * steer_input
	fr.steering = max_steer * steer_input

	rl.engine_force = engine_force_val * throttle
	rr.engine_force = engine_force_val * throttle

	fl.brake = brake_force_val * brake_input
	fr.brake = brake_force_val * brake_input
	rl.brake = brake_force_val * brake_input
	rr.brake = brake_force_val * brake_input

	fl.wheel_friction_slip = front_grip
	fr.wheel_friction_slip = front_grip

	var slide_active: bool = handbrake or (handbrake and throttle >= ps_threshold)
	if slide_active:
		rl.wheel_friction_slip = rear_grip * hb_mult
		rr.wheel_friction_slip = rear_grip * hb_mult
	else:
		rl.wheel_friction_slip = rear_grip
		rr.wheel_friction_slip = rear_grip

	var speed: float = linear_velocity.length()
	speed_changed.emit(speed)

	var slide_deg: float = 0.0
	if speed > 1.0:
		var forward: Vector3 = -transform.basis.z
		var vel_dir: Vector3 = linear_velocity.normalized()
		var dot: float = clamp(forward.dot(vel_dir), -1.0, 1.0)
		slide_deg = rad_to_deg(acos(dot))
	slide_changed.emit(slide_deg)

	_snapshot_accumulator += delta
	if _snapshot_accumulator >= lap_history_dt:
		_snapshot_accumulator = 0.0
		lap_history.append({
			"t": Time.get_ticks_msec() / 1000.0 - _lap_start_time,
			"pos": global_position,
			"rot": global_rotation
		})


func reset_position() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	position = Vector3(0, 1, 5)
	rotation = Vector3.ZERO
	lap_history.clear()
	_snapshot_accumulator = 0.0
	_lap_start_time = Time.get_ticks_msec() / 1000.0
