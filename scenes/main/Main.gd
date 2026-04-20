extends Node2D

# Main Game Controller
# Orchestrates the game scene, input, and flow

var player: CharacterBody2D
var camera: Camera2D
var hud: Control

func _ready():
	# Initialize game
	GameManager.reset_game()
	
	# Get references
	player = $Player
	camera = $Camera2D
	hud = $CanvasLayer/HUD
	
	# Start first game
	_start_new_game()

func _start_new_game():
	"""Initialize a new game run"""
	GameManager.reset_game()
	GameManager.start_game()
	hud.update_all()

func _input(event):
	if event.is_action_pressed("pause"):
		if GameManager.is_game_running:
			GameManager.pause_game()
			hud.show_pause_menu()

func _process(delta):
	if not GameManager.is_game_running:
		return
	
	# Update game score
	GameManager.update_score(delta)
	
	# Update power-up timers
	GameManager.update_power_up(delta)
	
	# Fixed horizontal lane; vertical stays on the ground line
	if player:
		player.position.x = 100.0

	if camera and player:
		camera.global_position = player.global_position

func _on_game_over():
	"""Called when player dies"""
	hud.show_game_over()

func _on_continue_game():
	"""Called when player chooses to continue"""
	# Add life
	GameManager.add_life()
	# Reset player position
	player.position = Vector2(100, 1156)
	# Resume
	GameManager.is_game_running = true
	hud.hide_pause_menu()
