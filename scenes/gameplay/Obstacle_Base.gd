extends Area2D

# Base obstacle class
# All obstacles inherit from this

signal hit_player

const PLACEHOLDER_ICON := preload("res://icon.svg")

# Fallback if GameManager missing
var move_speed: float = 300.0
## Multiplier on world scroll speed (e.g. slow truck)
var speed_scale: float = 1.0
var is_active: bool = true

func _ready():
	_apply_placeholder_texture()
	body_entered.connect(_on_body_entered)

func _apply_placeholder_texture() -> void:
	var s := get_node_or_null("Sprite2D") as Sprite2D
	if s == null or s.texture != null:
		return
	s.texture = PLACEHOLDER_ICON
	s.scale = Vector2(0.065, 0.065)
	s.region_enabled = false

func _process(delta: float) -> void:
	if is_active:
		var spd: float = GameManager.speed if GameManager else move_speed
		position.x -= spd * speed_scale * delta

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	is_active = false
	hit_player.emit()
	_play_hit_animation()
	if body.has_method("can_be_hurt") and not body.can_be_hurt():
		queue_free()
		return
	if body.has_method("take_hit"):
		body.take_hit()
	queue_free()

func _play_hit_animation():
	"""Play hit animation (override in child scenes)"""
	pass

func destroy():
	"""Destroy obstacle"""
	is_active = false
	queue_free()
