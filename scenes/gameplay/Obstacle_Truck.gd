extends "res://scenes/gameplay/Obstacle_Base.gd"

# Large Truck - slow moving but big obstacle

var sprite: Sprite2D

func _ready() -> void:
	super._ready()
	speed_scale = 0.68
	sprite = $Sprite2D

func _play_hit_animation():
	# Dark grey flash for truck
	if sprite:
		sprite.modulate = Color.DARK_GRAY
		await get_tree().create_timer(0.15).timeout
		sprite.modulate = Color.WHITE
