extends Area2D

# Coin collectible - simple pickup

signal collected

const PLACEHOLDER_ICON := preload("res://icon.svg")

var sprite: Sprite2D
var bob_timer: float = 0.0

func _ready():
	sprite = $Sprite2D
	if sprite.texture == null:
		sprite.texture = PLACEHOLDER_ICON
		sprite.scale = Vector2(0.05, 0.05)
		sprite.region_enabled = false
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if GameManager.is_game_running:
		position.x -= GameManager.speed * delta
	bob_timer += delta
	if sprite:
		var bob_y := sin(bob_timer * 8.0) * 3.0
		sprite.position.y = bob_y

func _on_body_entered(body):
	if body.is_in_group("player"):
		collected.emit()
		GameManager.add_coins(1)
		queue_free()
