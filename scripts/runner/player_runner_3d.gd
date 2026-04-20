extends CharacterBody3D

## 3 lanes (X), run forward along world −Z; obstacles sit on the road while you pass them. Jump / slide.

const LANES: Array[float] = [-2.2, 0.0, 2.2]
const LANE_LERP: float = 14.0
const JUMP_VELOCITY: float = 9.5
const GRAVITY: float = 28.0

var lane_index: int = 1
var is_sliding: bool = false
var slide_timer: float = 0.0
const SLIDE_DURATION: float = 0.55

var hit_lock: bool = false

## Full stop after a hit, then ease back to full run speed (also scales distance/time in GameManager).
const HIT_STUN_DURATION: float = 1.5
const HIT_RAMP_DURATION: float = 1.0

var _hit_stun_remaining: float = 0.0
var _hit_ramp_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0

var _touch_start: Vector2 = Vector2.ZERO
var _touch_lane_threshold: float = 80.0
var _key_held_prev: Dictionary = {}

@onready var stand_shape: CollisionShape3D = $CollisionShape3D
@onready var slide_shape: CollisionShape3D = $SlideCollision
@onready var mesh_stand: MeshInstance3D = $MeshStand
@onready var mesh_slide: MeshInstance3D = $MeshSlide


func _ready() -> void:
	add_to_group("player")
	_set_slide_visual(false)


func is_player_sliding() -> bool:
	return is_sliding


func take_hit() -> void:
	if hit_lock or not GameManager.is_game_running:
		return
	hit_lock = true
	_hit_flash_remaining = 0.35
	_set_hit_flash_visual(true)
	var cam := get_viewport().get_camera_3d()
	if cam and cam.has_method("add_shake"):
		cam.add_shake(0.22)
	RunnerAudio.play_hit()
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		Input.vibrate_handheld(55)
	GameManager.lose_life()
	if not GameManager.is_game_running:
		hit_lock = false
		_set_hit_flash_visual(false)
		return
	_hit_stun_remaining = HIT_STUN_DURATION
	_hit_ramp_remaining = HIT_RAMP_DURATION
	velocity.z = 0.0


func get_forward_scale() -> float:
	if _hit_stun_remaining > 0.0:
		return 0.0
	if _hit_ramp_remaining > 0.0:
		var t: float = 1.0 - (_hit_ramp_remaining / HIT_RAMP_DURATION)
		return ease(clampf(t, 0.0, 1.0), 0.35)
	return 1.0


func _physics_process(delta: float) -> void:
	if _hit_flash_remaining > 0.0:
		_hit_flash_remaining -= delta
		if _hit_flash_remaining <= 0.0:
			_set_hit_flash_visual(false)

	if _hit_stun_remaining > 0.0:
		_hit_stun_remaining -= delta
	elif _hit_ramp_remaining > 0.0:
		_hit_ramp_remaining -= delta
		if _hit_ramp_remaining <= 0.0:
			hit_lock = false

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	if slide_timer > 0.0:
		slide_timer -= delta
		if slide_timer <= 0.0:
			is_sliding = false
			_set_slide_visual(false)

	# Before move_and_slide so jump/slide velocity applies this frame. Uses Input singleton so GUI focus does not block lanes.
	if GameManager.is_game_running:
		var fs: float = get_forward_scale()
		if _hit_stun_remaining <= 0.0:
			_lane_and_moves_from_input()
		# Same scale as former obstacle scroll (GameManager.speed / 18).
		velocity.z = -(GameManager.speed / 18.0) * fs
		velocity.x = 0.0
	else:
		velocity.z = 0.0
		velocity.x = 0.0

	move_and_slide()

	var target_x: float = LANES[lane_index]
	position.x = move_toward(position.x, target_x, LANE_LERP * delta)


func _key_just_physical(key: Key) -> bool:
	var cur := Input.is_physical_key_pressed(key)
	var prev: bool = _key_held_prev.get(key, false)
	_key_held_prev[key] = cur
	return cur and not prev


func _lane_and_moves_from_input() -> void:
	var left_a := _key_just_physical(KEY_A)
	var left_arrow := _key_just_physical(KEY_LEFT)
	if Input.is_action_just_pressed("lane_left") or left_a or left_arrow:
		lane_index = clampi(lane_index - 1, 0, 2)
	var right_d := _key_just_physical(KEY_D)
	var right_arrow := _key_just_physical(KEY_RIGHT)
	if Input.is_action_just_pressed("lane_right") or right_d or right_arrow:
		lane_index = clampi(lane_index + 1, 0, 2)
	if (Input.is_action_just_pressed("jump") or _key_just_physical(KEY_SPACE)) and is_on_floor() and not is_sliding:
		velocity.y = JUMP_VELOCITY
		RunnerAudio.play_jump()
	if (Input.is_action_just_pressed("slide") or _key_just_physical(KEY_S)) and is_on_floor():
		is_sliding = true
		slide_timer = SLIDE_DURATION
		_set_slide_visual(true)
		RunnerAudio.play_slide()


func _input(event: InputEvent) -> void:
	# Touch: swipe horizontally to change lane (HUD uses mouse_filter IGNORE so this receives)
	if not GameManager.is_game_running:
		return
	if _hit_stun_remaining > 0.0:
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_touch_start = st.position
		else:
			var drag: Vector2 = st.position - _touch_start
			if absf(drag.x) > _touch_lane_threshold and absf(drag.x) > absf(drag.y) * 1.1:
				if drag.x < 0.0:
					lane_index = clampi(lane_index - 1, 0, 2)
				else:
					lane_index = clampi(lane_index + 1, 0, 2)


func _set_slide_visual(sliding: bool) -> void:
	if stand_shape:
		stand_shape.disabled = sliding
	if slide_shape:
		slide_shape.disabled = not sliding
	if mesh_stand:
		mesh_stand.visible = not sliding
	if mesh_slide:
		mesh_slide.visible = sliding


func _set_hit_flash_visual(active: bool) -> void:
	# MeshInstance3D has no modulate; tint via surface override material.
	var hit := Color(1.0, 0.45, 0.45)
	for mi in [mesh_stand, mesh_slide]:
		if mi == null:
			continue
		if not active:
			mi.set_surface_override_material(0, null)
			continue
		var mat := StandardMaterial3D.new()
		mat.albedo_color = hit
		mat.metallic = 0.08
		mat.roughness = 0.42
		mi.set_surface_override_material(0, mat)
