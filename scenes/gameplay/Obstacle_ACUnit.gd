extends "res://scenes/gameplay/Obstacle_Base.gd"

# AC Unit - high obstacle, must jump over

var sprite: Sprite2D

func _ready():
	super._ready()
	sprite = $Sprite2D

func _play_hit_animation():
	# Grey flash for metal AC unit
	if sprite:
		sprite.modulate = Color.GRAY
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
