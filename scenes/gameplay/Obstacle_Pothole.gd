extends "res://scenes/gameplay/Obstacle_Base.gd"

# Pothole obstacle - simple jump over

var sprite: Sprite2D

func _ready():
	super._ready()
	sprite = $Sprite2D

func _play_hit_animation():
	# Flash effect
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
