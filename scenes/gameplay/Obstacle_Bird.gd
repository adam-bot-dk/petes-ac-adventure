extends "res://scenes/gameplay/Obstacle_Base.gd"

# Bird - low flying, must slide under

var sprite: Sprite2D
var flight_offset: float = 0.0

func _ready():
	super._ready()
	sprite = $Sprite2D

func _process(delta):
	# Add slight wing flutter animation
	flight_offset += delta * 10
	if sprite:
		sprite.region_rect.position.y = int(sin(flight_offset)) * 4

func _play_hit_animation():
	# Brown flash for bird
	if sprite:
		sprite.modulate = Color.BROWN
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE
