extends "res://scenes/gameplay/Obstacle_Base.gd"

# Traffic Cone - small obstacle, can jump or dodge

var sprite: Sprite2D

func _ready():
	super._ready()
	sprite = $Sprite2D

func _play_hit_animation():
	# Orange flash for cone
	if sprite:
		sprite.modulate = Color.ORANGE
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
