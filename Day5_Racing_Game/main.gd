@tool
extends Node3D

# Three closed AoR layouts, all geometry-verified in track_sim.py (pos_gap=0.000,
# worst pair gap=0.000). Right turns only so far; corner kit = 90_R/Sweeper_R/
# Tight_R. Each loop returns to the start heading (net +360).
#   T1 Sweeper Oval  — fast flowing, 4 sweepers (Spa/oval).
#   T2 Technical     — 90s + tights, compact notch (Lydden rallycross).
#   T3 Esses         — tight chicane + esses sections (Suzuka-ish).
const T1_SWEEPER := [
	"Start", "Straight_Long", "Straight_Long", "Sweeper_R",
	"Straight_Long", "Straight_Long", "Sweeper_R", "Straight_Short",
	"Straight_Long", "Straight_Long", "Sweeper_R",
	"Straight_Long", "Straight_Long", "Sweeper_R",
]
const T2_TECHNICAL := [
	"Start", "Straight_Long", "Straight_Long", "90_R",
	"Straight_Long", "Tight_R", "Straight_Short",
	"Straight_Long", "Straight_Long", "90_R",
	"Straight_Long", "Tight_R",
]
const T3_ESSES := [
	"Start", "Straight_Long", "Tight_L", "Tight_R", "Straight_Long", "90_R",
	"Straight_Long", "Straight_Long", "90_R", "Straight_Short",
	"Straight_Long", "Tight_L", "Tight_R", "Straight_Long", "90_R",
	"Straight_Long", "Straight_Long", "90_R",
]

# Runtime-playable default track (game drives whatever is baked; this is the
# fallback build + the single-piece editor preview).
const LAYOUT := T1_SWEEPER

# Toggle in the Inspector to (re)generate the track from LAYOUT as REAL, owned,
# selectable nodes baked into Main.tscn. After baking you can drag / rotate /
# delete individual pieces and checkpoints in the editor; edits persist (the game
# uses whatever is baked). Re-toggle to regenerate a fresh layout.
var _rebuild_flag: bool = false
@export var rebuild_track: bool:
	get:
		return _rebuild_flag
	set(value):
		_rebuild_flag = false  # momentary button — never stays on, never auto-fires on load
		if value and Engine.is_editor_hint() and is_inside_tree():
			_bake_track()

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


func _bake_track() -> void:
	# Generate owned nodes that save into the scene.
	TrackBuilder.build(track, LAYOUT, get_tree().edited_scene_root)


# Bakes all 3 design tracks (T1/T2/T3) side by side as OWNED, individually
# selectable nodes (each piece gets a unique ordered name in the Scene dock =
# hand-editable). Use this to compare the three layouts in-engine, then
# drag/delete pieces or keep the one you want.
var _bake_all_flag: bool = false
@export var bake_all_variants: bool:
	get:
		return _bake_all_flag
	set(value):
		_bake_all_flag = false
		if value and Engine.is_editor_hint() and is_inside_tree():
			_bake_all_variants()


func _bake_all_variants() -> void:
	var root: Node = get_tree().edited_scene_root
	# Wipe EVERYTHING under Track (old preview, prior bakes, stale trigger gates)
	# so the scene holds only the freshly baked T1/T2/T3 — no leftover squares.
	for c in track.get_children():
		track.remove_child(c)
		c.queue_free()
	var tracks := [T1_SWEEPER, T2_TECHNICAL, T3_ESSES]
	var names := ["T1_Sweeper", "T2_Technical", "T3_Esses"]
	# Each loop grows in +X from its start; space starts well clear of the widest.
	var x_offsets := [0.0, 200.0, 400.0]
	for i in 3:
		var start := Transform3D(Basis(), Vector3(x_offsets[i], 0, 0))
		var info := TrackBuilder.build(track, tracks[i], root, names[i], start, false)
		_spawn_markers(track.get_node(names[i]), root, i + 1, Vector3(x_offsets[i], 0, 0))
		print("Baked %s at x=%d : %d pieces" % [names[i], x_offsets[i], info["pieces"].size()])


# PARITY DUMP (debug). Walks every baked piece and writes its REAL Godot world
# transform + Exit marker + visual AABB to user://parity_dump.json. The Python
# harness (parity.py) diffs this against its placement model to find exactly where
# engine != model — the seams the model is blind to. Writes to user:// so it lands
# in the OS user-data dir (printed to Output) regardless of res:// being read-only.
var _dump_flag: bool = false
@export var dump_parity: bool:
	get:
		return _dump_flag
	set(value):
		_dump_flag = false
		if value and Engine.is_editor_hint() and is_inside_tree():
			_dump_parity()


func _dump_parity() -> void:
	var out := {}
	for container in track.get_children():
		if not (container is Node3D):
			continue
		var pieces := []
		for piece in container.get_children():
			if not (piece is Node3D):
				continue
			var t: Transform3D = piece.global_transform
			var rec := {
				"name": piece.name,
				"origin": _v3(t.origin),
				"basis_x": _v3(t.basis.x),
				"basis_y": _v3(t.basis.y),
				"basis_z": _v3(t.basis.z),
			}
			var ex: Node3D = piece.get_node_or_null("Exit")
			if ex:
				var et: Transform3D = ex.global_transform
				rec["exit_origin"] = _v3(et.origin)
				rec["exit_basis_z"] = _v3(et.basis.z)
			var aabb: Variant = _world_aabb(piece)
			if aabb != null:
				rec["aabb_pos"] = _v3((aabb as AABB).position)
				rec["aabb_end"] = _v3((aabb as AABB).end)
			pieces.append(rec)
		if not pieces.is_empty():
			out[container.name] = pieces
	var path := "user://parity_dump.json"
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "  "))
	f.close()
	print("PARITY DUMP -> ", ProjectSettings.globalize_path(path))


func _v3(v: Vector3) -> Array:
	return [v.x, v.y, v.z]


# Union world-space AABB of every VisualInstance3D under a piece (the real drawn
# extent, what actually shows the seam in-engine).
func _world_aabb(node: Node) -> Variant:
	var acc: Variant = null
	for vi in _find_visuals(node):
		var box: AABB = vi.global_transform * vi.get_aabb()
		acc = box if acc == null else (acc as AABB).merge(box)
	return acc


func _find_visuals(node: Node) -> Array:
	var out := []
	if node is VisualInstance3D:
		out.append(node)
	for c in node.get_children():
		out.append_array(_find_visuals(c))
	return out


# Drops N big pylons next to a variant's start so each track is identified by
# COUNT (1, 2, 3) — readable from any camera angle, unlike a small flag color.
func _spawn_markers(container: Node3D, owner_root: Node, n: int, base: Vector3) -> void:
	var pylon: PackedScene = load("res://assets/kenney_racing/pylon.glb")
	for k in n:
		var m: Node3D = pylon.instantiate()
		m.name = "Marker_%d_of_%d" % [k + 1, n]
		container.add_child(m)
		m.owner = owner_root
		# Line them up beside the start tile, raised and scaled big to read clearly.
		m.global_transform = Transform3D(Basis().scaled(Vector3.ONE * 8.0), base + Vector3(20 + k * 12, 0, 8))


func _ready() -> void:
	var starter: Node = track.get_node_or_null("StarterTrack")
	var already_baked: bool = starter != null and starter.get_child_count() > 0

	if Engine.is_editor_hint():
		# Show an owner-less preview only if nothing is baked yet, so an untouched
		# scene isn't blank. Press the Inspector "Rebuild Track" toggle to commit
		# real editable nodes.
		if not already_baked:
			TrackBuilder.build(track, LAYOUT)
			_car_start = Transform3D.IDENTITY
			_place_car()
		return

	# Runtime: drive whatever is in the scene.
	#  - StarterTrack baked (single-track workflow): drive it as-is.
	#  - Display tracks baked (T1/T2/T3 via Bake All): drive the FIRST one and
	#    spawn its triggers, instead of building a throwaway that OVERLAPS it.
	#  - Nothing baked: build a playable track from LAYOUT.
	var display := _first_display_container()
	if already_baked:
		_car_start = starter.get_child(0).global_transform
	elif display:
		_car_start = TrackBuilder.spawn_triggers_for(track, display)
	else:
		var info := TrackBuilder.build(track, LAYOUT)
		_car_start = info["car_start"]
	_place_car()

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

	# Camera must sit AT the rig; only the rig is moved each frame. Zero any stale
	# local offset a scene save may have baked in (else the camera flies far off).
	camera.position = Vector3.ZERO
	camera_rig.position = car.position + Vector3(0, 15, 20)
	camera.look_at(car.position)
	countdown_label.visible = false
	race_complete_panel.visible = false
	pause_panel.visible = false

	# Timing starts now; crossing the start line after all 3 checkpoints = lap done.
	if track.has_method("start_race"):
		track.start_race()


# First baked display track (a Track child container holding "NN_Name" pieces),
# or null. Skips StarterTrack (handled separately) and trigger Area nodes.
func _first_display_container() -> Node3D:
	for c in track.get_children():
		if not (c is Node3D) or c.name == "StarterTrack":
			continue
		for piece in c.get_children():
			if piece is Node3D and piece.name.length() > 2 and piece.name[2] == "_":
				return c
	return null


func _place_car() -> void:
	# Sit the car on the middle of the Start tile, facing -Z (into the track).
	# -Z offset = half a Start tile, scaled with the road.
	var spawn := _car_start.origin + Vector3(0, 1.0, -2.0 * TrackBuilder.ROAD_SCALE)
	if car.has_method("set_start_point"):
		car.set_start_point(spawn)
	if car.has_method("reset_position"):
		car.reset_position()
	else:
		car.global_transform = Transform3D(Basis(), spawn)


@export var cam_distance: float = 16.0    # how far behind the car (world units)
@export var cam_height: float = 8.0       # how high above the car
@export var cam_lookahead: float = 7.0    # aim point ahead of the car
@export var cam_smooth: float = 5.0       # position lerp speed (higher = snappier)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Chase camera that tracks the car's TRAVEL direction, not its facing, so the
	# view stays behind motion during slides/drifts (driving sideways stays
	# readable). Falls back to car heading when nearly stopped.
	var rb := car as RigidBody3D
	var vel: Vector3 = rb.linear_velocity if rb else Vector3.ZERO
	var flat := Vector3(vel.x, 0.0, vel.z)
	var fwd := -car.global_transform.basis.z
	fwd.y = 0.0
	if fwd.length() < 0.01:
		fwd = Vector3.FORWARD
	fwd = fwd.normalized()
	var dir: Vector3 = flat.normalized() if flat.length() > 3.0 else fwd

	var target := car.global_position - dir * cam_distance + Vector3(0, cam_height, 0)
	var t: float = clamp(delta * cam_smooth, 0.0, 1.0)
	camera_rig.global_position = camera_rig.global_position.lerp(target, t)
	camera.position = Vector3.ZERO
	camera.look_at(car.global_position + dir * cam_lookahead + Vector3(0, 1.5, 0))


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
