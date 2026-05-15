extends Node3D

const LANES: Array[float] = [-2.2, 0.0, 2.2]

@export var obstacle_scene: PackedScene
@export var pickup_scene: PackedScene
## World −Z: spawns at player.z minus these (larger = farther ahead, easier to read).
@export var spawn_ahead_min: float = 58.0
@export var spawn_ahead_extra: float = 24.0
@export var max_spawned_children: int = 48

var _cooldown: float = 0.35

@onready var _player: Node3D = $"../Player"


func _process(delta: float) -> void:
	if not GameManager.is_game_running or GameManager.is_paused or _player == null:
		return
	if get_child_count() >= max_spawned_children:
		return
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var speed_scale: float = clampf((GameManager.speed - 300.0) / 260.0, 0.0, 1.0)
	var min_cd: float = lerpf(1.08, 0.72, speed_scale)
	var max_cd: float = lerpf(1.82, 1.18, speed_scale)
	_cooldown = randf_range(min_cd, max_cd)
	var lane: int = randi() % 3
	var pz: float = _player.position.z
	var spawn_min: float = spawn_ahead_min + speed_scale * 8.0
	var spawn_extra: float = spawn_ahead_extra + speed_scale * 6.0
	var spawn_z: float = pz - spawn_min - randf() * spawn_extra
	var pickup_chance: float = lerpf(0.48, 0.32, speed_scale)
	if randf() < pickup_chance and pickup_scene:
		_spawn_pickup(lane, spawn_z)
	else:
		_spawn_obstacle(lane, spawn_z)


func _spawn_obstacle(lane: int, spawn_z: float) -> void:
	if obstacle_scene == null:
		return
	var obs := obstacle_scene.instantiate()
	obs.position = Vector3(LANES[lane], 0.0, spawn_z)
	# Kind enum: JUMP = 0, SLIDE = 1 (see runner_obstacle_3d.gd)
	obs.set("kind", 1 if randf() < 0.42 else 0)
	add_child(obs)


func _spawn_pickup(lane: int, spawn_z: float) -> void:
	if pickup_scene == null:
		return
	var p: Node3D = pickup_scene.instantiate() as Node3D
	p.position = Vector3(LANES[lane], 0.65, spawn_z)
	add_child(p)
