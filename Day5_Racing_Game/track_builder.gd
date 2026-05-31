class_name TrackBuilder
extends RefCounted

# Data-driven track assembler.
# Each prefab declares its outgoing connector as an "Exit" Marker3D and enters
# at its own origin travelling -Z. build() walks a layout list, snapping each
# piece's origin onto a moving cursor, then advancing the cursor to that piece's
# Exit. Start/Finish line + 3 ordered checkpoints are spawned from the walk so
# any layout gets working lap detection. Single source of geometry truth.

const PREFAB_DIR := "res://prefabs/"
const TRIGGER_SIZE := Vector3(9, 4, 2)   # spans road width (4) + margin, low gate

# track_root: the Track Node3D (track.gd lives here). layout: Array[String] of
# prefab names. Returns { car_start: Transform3D, pieces: Array, end: Transform3D }.
static func build(track_root: Node3D, layout: Array) -> Dictionary:
	var container: Node3D = track_root.get_node_or_null("StarterTrack")
	if container == null:
		container = Node3D.new()
		container.name = "StarterTrack"
		track_root.add_child(container)
	for c in container.get_children():
		c.free()

	var cursor := Transform3D.IDENTITY
	var placed: Array = []
	var car_start := Transform3D.IDENTITY

	for i in layout.size():
		var piece_name: String = layout[i]
		var packed: PackedScene = load(PREFAB_DIR + piece_name + ".tscn")
		if packed == null:
			push_warning("TrackBuilder: missing prefab '%s'" % piece_name)
			continue
		var inst: Node3D = packed.instantiate()
		container.add_child(inst)
		inst.global_transform = cursor
		placed.append(inst)
		if i == 0:
			car_start = cursor
		var exit_marker: Node3D = inst.get_node_or_null("Exit")
		if exit_marker:
			# Collapse the exit to a flat, pure-yaw cursor: the track stays on
			# the y=0 plane no matter what the corner's basis does, and heading
			# is read from the exit's forward (-Z) vector so basis sign quirks
			# can't tilt or climb the chain.
			var g := exit_marker.global_transform
			var fwd := -g.basis.z
			var yaw := atan2(-fwd.x, -fwd.z)
			var p := g.origin
			p.y = 0.0
			cursor = Transform3D(Basis(Vector3.UP, yaw), p)
		else:
			push_warning("TrackBuilder: '%s' has no Exit marker" % piece_name)

	_spawn_triggers(track_root, placed, car_start)
	return { "car_start": car_start, "pieces": placed, "end": cursor }


static func _spawn_triggers(track_root: Node3D, placed: Array, car_start: Transform3D) -> void:
	_make_area(track_root, "StartLine", car_start)
	var n: int = placed.size()
	if n < 4:
		return
	var idxs := [int(n * 0.25), int(n * 0.5), int(n * 0.75)]
	for j in 3:
		var p: Node3D = placed[idxs[j]]
		_make_area(track_root, "Checkpoint%d" % (j + 1), p.global_transform)


static func _make_area(track_root: Node3D, node_name: String, xform: Transform3D) -> void:
	var existing := track_root.get_node_or_null(node_name)
	if existing:
		existing.free()
	var area := Area3D.new()
	area.name = node_name
	area.collision_layer = 0
	area.collision_mask = 2   # car is on layer 2 (Car.tscn collision_layer = 2)
	track_root.add_child(area)
	# Lift the gate so its box straddles the road surface.
	var t := xform
	t.origin += Vector3(0, 1.5, 0)
	area.global_transform = t
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = TRIGGER_SIZE
	cs.shape = box
	area.add_child(cs)
