extends Node2D

# Background Layer 2 (Middle speed)
# Buildings and HVAC units

var sprite: Sprite2D
var scroll_speed: float = 0.3

func _ready():
	sprite = $Background2

func _process(delta):
	if GameManager.is_game_running:
		var speed = GameManager.speed * scroll_speed
		if sprite:
			sprite.position.x -= speed * delta
