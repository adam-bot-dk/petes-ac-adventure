extends CharacterBody2D

# Pete — GDD: one-thumb tap jump, hold slide, double-tap dash (unlock 5000 lifetime coins).

const JUMP_VELOCITY := -400.0
const GRAVITY := 980.0
const MOVE_SPEED := 300.0
const DASH_SPEED := 600.0
const DASH_COOLDOWN := 1.0
const DASH_UNLOCK_COINS := 5000
const DOUBLE_TAP_MS := 280
const SLIDE_HOLD_SEC := 0.14

var is_sliding: bool = false
var is_dashing: bool = false
var can_dash: bool = true

var normal_size: Vector2 = Vector2(64, 96)
var slide_size: Vector2 = Vector2(64, 48)

var speed_multiplier: float = 1.0
var invincible: bool = false
var hit_lock: bool = false

var animation_player: Node

var _last_tap_ms: int = 0
var _slide_touch_index: int = -1
var _slide_hold_time: float = 0.0
var _slide_active_from_hold: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_set_hitbox_size(normal_size)
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player == null:
		animation_player = get_node_or_null("AnimatedSprite2D")

func can_be_hurt() -> bool:
	return not invincible and not hit_lock

func take_hit() -> void:
	if not can_be_hurt():
		return
	hit_lock = true
	if sprite:
		sprite.modulate = Color(1.0, 0.5, 0.5, 1.0)
	GameManager.lose_life()
	await get_tree().create_timer(0.45).timeout
	if sprite:
		sprite.modulate = Color.WHITE
	hit_lock = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_dashing:
		velocity.x = DASH_SPEED
	else:
		velocity.x = MOVE_SPEED * speed_multiplier

	if is_sliding and is_on_floor():
		_set_hitbox_size(slide_size)
		velocity.y = 0.0
	elif not is_sliding:
		_set_hitbox_size(normal_size)

	if _slide_touch_index >= 0:
		_slide_hold_time += delta
		if _slide_hold_time >= SLIDE_HOLD_SEC and is_on_floor():
			is_sliding = true
			_slide_active_from_hold = true
			if animation_player and animation_player.has_method("play"):
				animation_player.play("slide")

	move_and_slide()

	if sprite and is_on_floor() and not is_sliding:
		sprite.position.y = sin(float(Time.get_ticks_msec()) * 0.018) * 3.8
	elif sprite:
		sprite.position.y = 0.0

func _set_hitbox_size(s: Vector2) -> void:
	var rect := collision_shape.shape as RectangleShape2D
	if rect:
		rect.size = s

func _unhandled_input(event: InputEvent) -> void:
	if not GameManager.is_game_running or GameManager.is_paused:
		return

	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
		return

	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.relative.x < -35.0 and absf(drag.relative.y) < 50.0:
			GameManager.add_bonus_score_from_trick(15)
		return

	# Desktop / keyboard & mapped actions
	if event.is_action_pressed("jump"):
		_try_jump()
	if event.is_action_pressed("slide"):
		if not is_sliding and is_on_floor():
			is_sliding = true
	if event.is_action_released("slide") and is_sliding:
		is_sliding = false
	if event.is_action_pressed("dash"):
		_try_dash()

func _handle_screen_touch(st: InputEventScreenTouch) -> void:
	if st.pressed:
		var now := Time.get_ticks_msec()
		if now - _last_tap_ms < DOUBLE_TAP_MS and GameManager.total_coins_earned >= DASH_UNLOCK_COINS:
			_try_dash()
			_last_tap_ms = 0
			return
		_slide_touch_index = st.index
		_slide_hold_time = 0.0
		_slide_active_from_hold = false
	else:
		if st.index != _slide_touch_index:
			return
		if not _slide_active_from_hold and _slide_hold_time < SLIDE_HOLD_SEC:
			_try_jump()
			_last_tap_ms = Time.get_ticks_msec()
		is_sliding = false
		_slide_touch_index = -1
		_slide_hold_time = 0.0
		_slide_active_from_hold = false

func _try_jump() -> void:
	if is_on_floor() and not is_sliding:
		velocity.y = JUMP_VELOCITY
		if animation_player and animation_player.has_method("play"):
			animation_player.play("jump")

func _try_dash() -> void:
	if GameManager.total_coins_earned < DASH_UNLOCK_COINS:
		return
	if not can_dash or not is_on_floor():
		return
	is_dashing = true
	can_dash = false
	if animation_player and animation_player.has_method("play"):
		animation_player.play("dash")
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	is_dashing = false
	can_dash = true

func become_invincible(duration: float) -> void:
	invincible = true
	await get_tree().create_timer(duration).timeout
	invincible = false

func set_power_up_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier

func get_vehicle_type() -> String:
	var unlocked := GameManager.unlocked_vehicles
	if "truck" in unlocked:
		return "truck"
	if "van" in unlocked:
		return "van"
	if "scooter" in unlocked:
		return "scooter"
	return "foot"
