extends Camera3D

## Behind-the-runner view: looks down the −Z track. Smoothed follow + optional shake.

@export var target_path: NodePath
@export var height_offset: float = 2.6
@export var back_offset: float = 6.2
@export var look_ahead: float = 22.0
@export var look_ahead_speed_boost: float = 7.0
@export var position_smoothing: float = 10.0
@export var fov_base: float = 58.0
@export var fov_speed_boost: float = 4.0

var _shake: float = 0.0
var _smoothed_eye: Vector3 = Vector3.ZERO


func _ready() -> void:
	fov = fov_base
	var p: Node3D = get_node_or_null(target_path) as Node3D
	if p:
		_smoothed_eye = p.global_position + Vector3(0.0, height_offset, back_offset)


func _process(delta: float) -> void:
	var p: Node3D = get_node_or_null(target_path) as Node3D
	if p == null:
		return
	var target_eye: Vector3 = p.global_position + Vector3(0.0, height_offset, back_offset)
	_smoothed_eye = _smoothed_eye.lerp(target_eye, clampf(position_smoothing * delta, 0.0, 1.0))
	var spd: float = GameManager.speed if GameManager else 300.0
	var speed_t: float = clampf((spd - 300.0) / 260.0, 0.0, 1.0)
	var look_dist: float = look_ahead + speed_t * look_ahead_speed_boost
	var look_pt: Vector3 = p.global_position + Vector3(0.0, 1.1 + speed_t * 0.25, -look_dist)
	var shake_vec: Vector3 = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-0.4, 0.4)
	) * _shake
	global_position = _smoothed_eye + shake_vec
	look_at(look_pt, Vector3.UP)
	_shake = move_toward(_shake, 0.0, delta * 3.2)
	var fov_t: float = fov_base + clampf((spd - 300.0) / 350.0, 0.0, 1.0) * fov_speed_boost
	fov = lerpf(fov, fov_t, 2.0 * delta)


func add_shake(amount: float) -> void:
	_shake = clampf(_shake + amount, 0.0, 0.55)
