extends Node3D

## Simple road + sidewalks + blocky buildings along the track (visual only; collision stays on Floor).

const FLOOR_TOP_Y: float = 0.045
## Matches Floor box in TempleRunMain (long strip along −Z).
const TRACK_CENTER_Z: float = -5000.0
const TRACK_LENGTH: float = 10000.0


func _ready() -> void:
	_road_and_sidewalks()
	_building_rows()


func _road_and_sidewalks() -> void:
	var road := MeshInstance3D.new()
	var road_m := BoxMesh.new()
	road_m.size = Vector3(7.0, 0.06, TRACK_LENGTH)
	road.mesh = road_m
	road.position = Vector3(0.0, FLOOR_TOP_Y + road_m.size.y * 0.5, TRACK_CENTER_Z)
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.1, 0.1, 0.11)
	road.set_surface_override_material(0, road_mat)
	add_child(road)

	var sw_mat := StandardMaterial3D.new()
	sw_mat.albedo_color = Color(0.58, 0.56, 0.53)
	sw_mat.roughness = 0.92

	var sw_w := 22.5
	var sw_h := 0.05
	var left := MeshInstance3D.new()
	var left_m := BoxMesh.new()
	left_m.size = Vector3(sw_w, sw_h, TRACK_LENGTH)
	left.mesh = left_m
	left.position = Vector3(-14.75, FLOOR_TOP_Y + sw_h * 0.5, TRACK_CENTER_Z)
	left.set_surface_override_material(0, sw_mat)
	add_child(left)

	var right := MeshInstance3D.new()
	var right_m := BoxMesh.new()
	right_m.size = Vector3(sw_w, sw_h, TRACK_LENGTH)
	right.mesh = right_m
	right.position = Vector3(14.75, FLOOR_TOP_Y + sw_h * 0.5, TRACK_CENTER_Z)
	right.set_surface_override_material(0, sw_mat)
	add_child(right)


func _building_rows() -> void:
	var xs: Array[float] = [-5.85, 5.85]
	var heights: Array[float] = [6.5, 8.0, 5.5, 9.5, 7.0, 8.5]
	var depths: Array[float] = [4.2, 3.8, 4.5, 4.0, 4.6, 4.1]
	var widths: Array[float] = [3.4, 3.8, 3.2, 3.6, 3.5, 3.7]
	var colors: Array[Color] = [
		Color(0.4, 0.42, 0.46),
		Color(0.36, 0.39, 0.44),
		Color(0.44, 0.43, 0.4),
		Color(0.33, 0.36, 0.41),
		Color(0.41, 0.4, 0.38),
		Color(0.38, 0.41, 0.45),
	]
	var i := 0
	while true:
		var z: float = 22.0 - float(i) * 70.0
		if z < -(TRACK_LENGTH - 80.0):
			break
		var idx: int = i % heights.size()
		for s in range(2):
			var bx: float = xs[s]
			var h: float = heights[idx] * (0.92 if s == 1 else 1.0)
			_box_building(
				Vector3(bx, FLOOR_TOP_Y, z),
				Vector3(widths[idx], h, depths[idx]),
				colors[idx].lerp(Color(0.55, 0.52, 0.48), float(s) * 0.12)
			)
		i += 1


func _box_building(foot_on_ground: Vector3, size: Vector3, albedo: Color) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = Vector3(foot_on_ground.x, FLOOR_TOP_Y + size.y * 0.5, foot_on_ground.z)
	var mat := StandardMaterial3D.new()
	var hk: int = abs(hash(str(foot_on_ground) + str(size)))
	var hue_shift := float(hk % 1000) / 1000.0
	mat.albedo_color = albedo.lerp(albedo.darkened(0.12), hue_shift * 0.35)
	mat.roughness = 0.88
	mi.set_surface_override_material(0, mat)
	add_child(mi)
	if randf() < 0.14:
		var ac := MeshInstance3D.new()
		var cm := BoxMesh.new()
		cm.size = Vector3(0.55, 0.12, 0.38)
		ac.mesh = cm
		ac.position = mi.position + Vector3(randf_range(-0.4, 0.4), size.y * 0.5 + 0.08, randf_range(-0.2, 0.2))
		var am := StandardMaterial3D.new()
		am.albedo_color = Color(0.75, 0.76, 0.78)
		am.metallic = 0.35
		am.roughness = 0.4
		ac.set_surface_override_material(0, am)
		add_child(ac)
