extends Node

## Persists wallet fish, lifetime total, best score, and vehicle unlocks (user://).

const SAVE_PATH := "user://pete_save.json"


func _ready() -> void:
	load_game()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		return
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return
	GameManager.coins = int(data.get("wallet", GameManager.coins))
	GameManager.total_coins_earned = int(data.get("total_fish", GameManager.total_coins_earned))
	GameManager.best_score = int(data.get("best_score", GameManager.best_score))
	var u: Variant = data.get("unlocked")
	if u is Array:
		GameManager.unlocked_vehicles.clear()
		for x in u:
			if x is String and x not in GameManager.unlocked_vehicles:
				GameManager.unlocked_vehicles.append(x)
	if GameManager.unlocked_vehicles.is_empty() or not "foot" in GameManager.unlocked_vehicles:
		GameManager.unlocked_vehicles = ["foot"]
	GameManager.emit_signal("coin_updated", GameManager.coins)


func save_game() -> void:
	var data := {
		"wallet": GameManager.coins,
		"total_fish": GameManager.total_coins_earned,
		"best_score": GameManager.best_score,
		"unlocked": GameManager.unlocked_vehicles.duplicate(),
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: could not write save.")
		return
	f.store_string(JSON.stringify(data))
