extends Node

## Persists wallet fish, lifetime total, best score, vehicle unlocks, and shop inventory (user://).

const SAVE_PATH := "user://pete_save.json"


func _ready() -> void:
	load_game()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		GameManager._init_shop_inventory()
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		GameManager._init_shop_inventory()
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		GameManager._init_shop_inventory()
		return
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		GameManager._init_shop_inventory()
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
	var inv: Variant = data.get("inventory")
	if inv is Dictionary:
		for item_id in inv:
			if item_id is String:
				GameManager.shop_inventory[item_id] = int(inv[item_id])
	GameManager._init_shop_inventory()
	GameManager.emit_signal("coin_updated", GameManager.coins)
	GameManager.emit_signal("shop_inventory_updated")


func save_game() -> void:
	var inv_out: Dictionary = {}
	for item_id in GameManager.CONSUMABLES:
		inv_out[item_id] = GameManager.get_inventory_count(item_id)
	var data := {
		"wallet": GameManager.coins,
		"total_fish": GameManager.total_coins_earned,
		"best_score": GameManager.best_score,
		"unlocked": GameManager.unlocked_vehicles.duplicate(),
		"inventory": inv_out,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: could not write save.")
		return
	f.store_string(JSON.stringify(data))
