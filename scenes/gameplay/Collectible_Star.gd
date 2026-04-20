extends Area2D

# Star collectible - high value, educational popup

signal collected

const PLACEHOLDER_ICON := preload("res://icon.svg")

var sprite: Sprite2D
var rotation_angle: float = 0.0

func _ready():
	sprite = $Sprite2D
	if sprite.texture == null:
		sprite.texture = PLACEHOLDER_ICON
		sprite.scale = Vector2(0.05, 0.05)
		sprite.region_enabled = false
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if GameManager.is_game_running:
		position.x -= GameManager.speed * delta
	rotation_angle += delta * 2.0
	if sprite:
		sprite.rotation = sin(rotation_angle) * 0.2

func _on_body_entered(body):
	if body.is_in_group("player"):
		collected.emit()
		GameManager.add_stars(1)
		
		# Show AC Tip popup (would be implemented in UI)
		_show_ac_tip()
		
		queue_free()

func _show_ac_tip():
	"""Show educational HVAC tip when star collected"""
	# This would connect to UI popup system
	print("Star collected! Showing HVAC tip...")
	
	# Sample tips (expandable list)
	var tips = [
		"Tip: Change your air filter every 3 months for better efficiency!",
		"Tip: A well-maintained AC can last 15-20 years.",
		"Tip: Set your thermostat to 78°F for optimal cooling.",
		"Tip: Clean outdoor units regularly for best performance.",
		"Tip: Seal your ducts to prevent 30% energy loss!"
	]
	
	var tip = tips[randi() % tips.size()]
	print("HVAC Tip: ", tip)
