extends Node2D

# Background Layer 3 (Foreground - fastest)
# Ground and street level

var sprite: Sprite2D
var scroll_speed: float = 0.5

func _ready():
	sprite = $Background3

func _process(delta):
	if GameManager.is_game_running:
		var speed = GameManager.speed * scroll_speed
		if sprite:
			sprite.position.x -= speed * delta
