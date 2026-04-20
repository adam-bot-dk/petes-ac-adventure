extends Node2D

# Background Layer 1 (Far - slowest)
# City skyline silhouette

var sprite: Sprite2D
var scroll_speed: float = 0.1

func _ready():
	sprite = $Background1

func _process(delta):
	# Parallax effect
	if GameManager.is_game_running:
		var speed = GameManager.speed * scroll_speed
		if sprite:
			sprite.position.x -= speed * delta
