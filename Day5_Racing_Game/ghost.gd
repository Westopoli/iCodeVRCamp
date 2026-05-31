extends Node3D

var snapshots: Array = []
var playback_t: float = 0.0

func _ready() -> void:
	var v: Node3D = preload("res://assets/kenney_racing/raceCarRed.glb").instantiate()
	v.rotate_y(PI)  # match car.gd mesh flip (Kenney mesh faces +Z)
	$VisualSlot.add_child(v)
	_apply_transparency(v)

func _apply_transparency(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh != null:
			for i in range(mesh.get_surface_count()):
				var src_mat = mesh.surface_get_material(i)
				var dup: StandardMaterial3D
				if src_mat is StandardMaterial3D:
					dup = src_mat.duplicate()
				else:
					dup = StandardMaterial3D.new()
				dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				dup.albedo_color = Color(1, 1, 1, 0.4)
				node.set_surface_override_material(i, dup)
	for child in node.get_children():
		_apply_transparency(child)

func _process(delta: float) -> void:
	playback_t += delta
	if snapshots.is_empty():
		visible = false
		return
	var last_t: float = snapshots[snapshots.size() - 1]["t"]
	if playback_t > last_t:
		visible = false
		return
	visible = true
	var idx: int = 0
	for i in range(snapshots.size() - 1):
		if snapshots[i]["t"] <= playback_t and snapshots[i + 1]["t"] >= playback_t:
			idx = i
			break
	var a: Dictionary = snapshots[idx]
	var b: Dictionary = snapshots[idx + 1] if idx + 1 < snapshots.size() else a
	var span: float = b["t"] - a["t"]
	var f: float = 0.0 if span <= 0.0 else (playback_t - a["t"]) / span
	position = a["pos"].lerp(b["pos"], f)
	rotation = a["rot"].lerp(b["rot"], f)

func reset() -> void:
	playback_t = 0.0
	visible = not snapshots.is_empty()

func set_snapshots(s: Array) -> void:
	snapshots = s
	reset()
