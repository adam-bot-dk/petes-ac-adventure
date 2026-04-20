extends Control

# Vehicle Shop
# Unlock vehicles with earned coins

var coin_value: Label
var unlock_buttons: Array[Button]
var vehicle_costs = ["500", "2000", "5000"]

func _ready():
	# Get references
	coin_value = $Panel/VBoxContainer/CoinDisplay/CoinValue
	unlock_buttons = [$Panel/VBoxContainer/VehicleSection/ScooterItem/UnlockScooterBtn,
					  $Panel/VBoxContainer/VehicleSection/VanItem/UnlockVanBtn,
					  $Panel/VBoxContainer/VehicleSection/TruckItem/UnlockTruckBtn]
	
	# Connect signals
	for btn in unlock_buttons:
		btn.pressed.connect(_on_unlock_pressed)
	$Panel/VBoxContainer/BackBtn.pressed.connect(_on_back_pressed)

	GameManager.coin_updated.connect(_update_ui)
	
	_update_ui()

func _update_ui():
	"""Update shop UI with current coins and unlocked status"""
	coin_value.text = str(GameManager.total_coins_earned)
	
	# Update button states
	_check_unlocks()

func _check_unlocks():
	"""Check and update button states for each vehicle"""
	for i in range(3):
		var cost = int(vehicle_costs[i])
		var unlocked = GameManager.can_unlock_vehicle(vehicle_costs[i].to_lower())
		var btn = unlock_buttons[i]
		
		if unlocked:
			btn.text = "✓ UNLOCKED"
			btn.disabled = true
			btn.modulate = Color(0.5, 1, 0.5)
		else:
			btn.text = str(cost)
			btn.disabled = GameManager.total_coins_earned < cost
			if GameManager.total_coins_earned >= cost:
				btn.modulate = Color(1, 1, 1)
			else:
				btn.modulate = Color(0.5, 0.5, 0.5)

func _on_unlock_pressed():
	"""Handle vehicle unlock attempt"""
	var btn = $Panel/VBoxContainer/VehicleSection/VehicleSection.find_child("UnlockVanBtn").next_sibling()
	if btn == null:
		btn = get_parent().find_child("UnlockVanBtn")
	
	var cost = int(btn.text)
	
	if GameManager.total_coins_earned >= cost:
		# Deduct coins
		GameManager.add_coins(-cost)
		print("Vehicle unlocked!")
		_check_unlocks()
	else:
		print("Not enough fish!")

func _open_shop():
	"""Show shop overlay"""
	visible = true
	modulate.a = 0
	_create_fade_in_animation()

func _create_fade_in_animation():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/runner/TempleRunMain.tscn")


func _close_shop():
	"""Hide shop"""
	visible = false
	modulate.a = 0
