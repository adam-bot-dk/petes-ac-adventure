extends Area3D

## Road obstacles: JUMP = mini outdoor AC condenser; SLIDE = low duct you duck under + vertical trunk lines.

enum Kind { JUMP, SLIDE }

@export var kind: Kind = Kind.JUMP

var _consumed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	_apply_shape()


func _apply_shape() -> void:
	var col := $CollisionShape3D
	var sh := col.shape as BoxShape3D
	var mesh := $MeshInstance3D
	if sh == null:
		return
	match kind:
		Kind.JUMP:
			sh.size = Vector3(1.1, 2.1, 0.55)
			col.position.y = 1.05
		Kind.SLIDE:
			sh.size = Vector3(1.35, 0.5, 0.55)
			col.position.y = 0.28
	if mesh:
		mesh.visible = false
	var old := get_node_or_null("HvacVisual")
	if old:
		old.queue_free()
	var root := Node3D.new()
	root.name = "HvacVisual"
	add_child(root)
	if kind == Kind.JUMP:
		_build_ac_unit_visual(root)
	else:
		_build_slide_duct_visual(root)
	_apply_hint_label()


func _mat_body() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.84, 0.82, 0.78)
	m.metallic = 0.38
	m.roughness = 0.52
	return m


func _mat_dark_metal() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.32, 0.34, 0.36)
	m.metallic = 0.55
	m.roughness = 0.38
	return m


func _mat_copper_hint() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.72, 0.48, 0.32)
	m.metallic = 0.6
	m.roughness = 0.42
	return m


func _add_box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.set_surface_override_material(0, mat)
	parent.add_child(mi)


func _add_cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, rot_deg: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = height
	mi.mesh = cm
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.set_surface_override_material(0, mat)
	parent.add_child(mi)


func _build_ac_unit_visual(root: Node3D) -> void:
	var body := _mat_body()
	var dark := _mat_dark_metal()
	var fan_mat := _mat_body()
	fan_mat.albedo_color = Color(0.78, 0.76, 0.72)
	# Concrete pad
	_add_box(root, Vector3(0, 0.03, 0), Vector3(1.05, 0.05, 0.52), body)
	# Main cabinet (condenser)
	_add_box(root, Vector3(0, 0.58, 0), Vector3(0.92, 1.05, 0.46), body)
	# Louvered front hint (dark inset)
	_add_box(root, Vector3(0, 0.55, 0.22), Vector3(0.78, 0.85, 0.04), dark)
	# Fan housing / top stack
	_add_box(root, Vector3(0, 1.38, -0.02), Vector3(0.72, 0.55, 0.42), fan_mat)
	# Fan circle (faces toward player from +Z side)
	_add_cylinder(root, Vector3(0, 1.38, 0.2), 0.2, 0.12, Vector3(90, 0, 0), dark)
	# Corner pipes
	_add_cylinder(root, Vector3(0.38, 0.2, -0.18), 0.045, 0.35, Vector3(0, 0, 0), _mat_copper_hint())
	_add_cylinder(root, Vector3(-0.38, 0.2, -0.18), 0.045, 0.35, Vector3(0, 0, 0), _mat_copper_hint())
	# Service panel
	_add_box(root, Vector3(0.35, 0.9, -0.21), Vector3(0.22, 0.45, 0.03), dark)


func _build_slide_duct_visual(root: Node3D) -> void:
	var duct := _mat_body()
	duct.albedo_color = Color(0.78, 0.76, 0.72)
	var dark := _mat_dark_metal()
	var teal := StandardMaterial3D.new()
	teal.albedo_color = Color(0.2, 0.48, 0.62)
	teal.metallic = 0.25
	teal.roughness = 0.55
	teal.emission_enabled = true
	teal.emission = Color(0.05, 0.15, 0.22)
	teal.emission_energy_multiplier = 0.2
	# Low horizontal supply duct (the thing you slide under)
	_add_box(root, Vector3(0, 0.28, 0), Vector3(1.32, 0.22, 0.52), duct)
	# Bottom insulation / wrap hint
	_add_box(root, Vector3(0, 0.14, 0), Vector3(1.28, 0.06, 0.48), dark)
	# Tall vertical risers (connected trunk lines)
	_add_box(root, Vector3(-0.58, 1.05, 0), Vector3(0.14, 1.35, 0.14), duct)
	_add_box(root, Vector3(0.58, 1.05, 0), Vector3(0.14, 1.35, 0.14), duct)
	# 90° elbow-ish pieces (simple blocks) at top of risers
	_add_box(root, Vector3(-0.58, 1.82, 0.1), Vector3(0.16, 0.16, 0.35), duct)
	_add_box(root, Vector3(0.58, 1.82, 0.1), Vector3(0.16, 0.16, 0.35), duct)
	# Cross tie / hanger bar
	_add_box(root, Vector3(0, 1.92, 0), Vector3(1.25, 0.06, 0.1), dark)
	# Flex drop (small cylinder)
	_add_cylinder(root, Vector3(0, 0.42, 0.22), 0.07, 0.2, Vector3(0, 0, 0), teal)


func _apply_hint_label() -> void:
	var label := Label3D.new()
	label.text = "JUMP" if kind == Kind.JUMP else "SLIDE"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.outline_size = 6
	label.modulate = Color(1.0, 0.96, 0.9) if kind == Kind.JUMP else Color(0.88, 0.97, 1.0)
	label.position = Vector3(0.0, 2.75 if kind == Kind.JUMP else 1.65, 0.0)
	add_child(label)


func _process(_delta: float) -> void:
	if not GameManager.is_game_running:
		return
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	if global_position.z > player.global_position.z + 22.0:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if _consumed or not body.is_in_group("player"):
		return
	if absf(body.global_position.x - global_position.x) > 1.15:
		return
	match kind:
		Kind.JUMP:
			if not body.is_on_floor():
				return
			_consume_and_damage(body)
		Kind.SLIDE:
			if not body.is_on_floor():
				return
			if body.has_method("is_player_sliding") and body.is_player_sliding():
				return
			_consume_and_damage(body)


func _consume_and_damage(body: Node3D) -> void:
	_consumed = true
	set_deferred("monitoring", false)
	set_deferred("collision_mask", 0)
	if body.has_method("take_hit"):
		body.call_deferred("take_hit")
