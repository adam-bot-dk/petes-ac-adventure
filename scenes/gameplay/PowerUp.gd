extends Area2D

# Power-up collectible - special ability

const PLACEHOLDER_ICON := preload("res://icon.svg")

var power_up_type: String = ""
var sprite: Sprite2D
var rotation_angle: float = 0.0

# Power-up effects and durations
var power_up_data = {
	"ice_burst": { "duration": 3.0, "color": Color.BLUE },
	"turbo_vents": { "duration": 10.0, "color": Color.CYAN },
	"service_van": { "duration": 5.0, "color": Color.WHITE },
	"pete_clone": { "duration": 15.0, "color": Color.YELLOW }
}

func _ready():
	sprite = $Sprite2D
	if sprite.texture == null:
		sprite.texture = PLACEHOLDER_ICON
		sprite.scale = Vector2(0.055, 0.055)
		sprite.region_enabled = false
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if GameManager.is_game_running:
		position.x -= GameManager.speed * delta
	rotation_angle += delta * 3.0
	if sprite:
		sprite.rotation = sin(rotation_angle) * 0.3

func _on_body_entered(body):
	if body.is_in_group("player"):
		_activate_power_up()
		queue_free()

func _activate_power_up():
	"""Activate the power-up effect"""
	if power_up_type in power_up_data:
		var data = power_up_data[power_up_type]
		var duration = data["duration"]
		var color = data["color"]
		
		# Apply power-up to game manager
		if power_up_type == "ice_burst":
			GameManager.set_power_up("ice_burst", duration)
			_freeze_obstacles()
		elif power_up_type == "turbo_vents":
			GameManager.set_power_up("turbo_vents", duration)
		elif power_up_type == "service_van":
			GameManager.set_power_up("service_van", duration)
			_make_player_invincible(duration)
		elif power_up_type == "pete_clone":
			GameManager.set_power_up("pete_clone", duration)
			_double_coins(duration)
		
		# Visual feedback
		print("Power-up activated: ", power_up_type)

func _freeze_obstacles():
	"""Freeze all obstacles (ice burst)"""
	print("Ice Burst! Obstacles frozen for 3 seconds")

func _make_player_invincible(duration: float):
	"""Make player invincible (service van)"""
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.become_invincible(duration)

func _double_coins(duration: float):
	"""Double coins collected (pete clone)"""
	print("Pete Clone! Coins doubled for ", duration, "seconds")
