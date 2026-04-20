extends Node2D

# Background hook — add ParallaxBackground children here when art is ready.

var parallax_bg: ParallaxBackground
var speed: float = 0.0

func _ready():
	parallax_bg = get_node_or_null("ParallaxBackground") as ParallaxBackground
	if parallax_bg:
		parallax_bg.motion_scale = 1.0

func _process(delta):
	if GameManager.is_game_running:
		speed = GameManager.speed * 0.5 * delta
		if parallax_bg:
			parallax_bg.motion_scale = 1.0 + (speed / 300.0)
