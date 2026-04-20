extends Area3D

## Penguin snack: small fish pickup (wallet still uses GameManager “coins” as tally).

var _taken: bool = false
var _fish_visual: Node3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	_build_fish_visual()


func _build_fish_visual() -> void:
	var root := Node3D.new()
	root.name = "FishVisual"
	add_child(root)
	_fish_visual = root

	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.19
	cap.height = 0.5
	body.mesh = cap
	body.rotation_degrees = Vector3(90, 0, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.58, 0.2)
	mat.metallic = 0.12
	mat.roughness = 0.45
	mat.emission_enabled = true
	mat.emission = Color(0.35, 0.15, 0.05)
	mat.emission_energy_multiplier = 0.25
	body.set_surface_override_material(0, mat)
	root.add_child(body)

	var tail := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.32, 0.34, 0.07)
	tail.mesh = bm
	tail.position = Vector3(0, 0, 0.29)
	var mat_t := StandardMaterial3D.new()
	mat_t.albedo_color = Color(0.78, 0.4, 0.14)
	tail.set_surface_override_material(0, mat_t)
	root.add_child(tail)

	for side in [-1, 1]:
		var eye := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.045
		sm.height = 0.09
		eye.mesh = sm
		eye.position = Vector3(float(side) * 0.1, 0.07, -0.21)
		var em := StandardMaterial3D.new()
		em.albedo_color = Color(0.06, 0.07, 0.09)
		eye.set_surface_override_material(0, em)
		root.add_child(eye)


func _process(_delta: float) -> void:
	if _fish_visual:
		_fish_visual.rotation.z = sin(Time.get_ticks_msec() * 0.0035) * 0.16
	if not GameManager.is_game_running:
		return
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	if global_position.z > player.global_position.z + 18.0:
		queue_free()


func _on_body_entered(body: Node3D) -> void:
	if _taken or not body.is_in_group("player"):
		return
	if absf(body.global_position.x - global_position.x) > 1.2:
		return
	_taken = true
	set_deferred("monitoring", false)
	RunnerAudio.play_collect()
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		Input.vibrate_handheld(22)
	GameManager.add_coins(1)
	if _fish_visual:
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(_fish_visual, "scale", Vector3(1.45, 1.45, 1.45), 0.1)
		tw.tween_property(self, "position:y", position.y + 0.55, 0.12)
		tw.finished.connect(func(): queue_free())
	else:
		queue_free()
