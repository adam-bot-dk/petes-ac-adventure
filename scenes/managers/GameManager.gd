extends Node

# Game State Singleton — distance score, lives, wallet fish tally, shop consumables.
# "coins" fields store fish count for scoring/shop; UI labels say "fish".

signal score_updated(score: int)
signal coin_updated(coins: int)
signal star_updated(stars: int)
signal lives_updated(lives: int)
signal game_over(won: bool)
signal player_locked_out()
signal shop_inventory_updated()

const CONSUMABLES: Dictionary = {
	"extra_life": {
		"display": "Extra life",
		"description": "Start your next run with 4 lives instead of 3.",
		"cost": 80,
	},
	"shield": {
		"display": "Shield",
		"description": "Ignore the first hit on your next run.",
		"cost": 120,
	},
	"ice_burst": {
		"display": "Ice burst",
		"description": "First 3 seconds of your next run run at half speed.",
		"cost": 100,
	},
	"turbo_vents": {
		"display": "Turbo vents",
		"description": "First 8 seconds of your next run run 15% faster.",
		"cost": 150,
	},
}

const ICE_BURST_DURATION: float = 3.0
const TURBO_VENTS_DURATION: float = 8.0
const TURBO_SPEED_MULT: float = 1.15
const ICE_SPEED_MULT: float = 0.5
const MAX_LIVES: int = 4

var shop_return_scene: String = "res://scenes/main/MainMenu.tscn"
var shop_inventory: Dictionary = {}

# Run-only consumable effects (reset each run)
var run_shield_active: bool = false
var run_ice_burst_timer: float = 0.0
var run_turbo_timer: float = 0.0

func _speed_reset() -> void:
	speed = 300.0
	_target_run_speed = 300.0

# Run state
var score: int = 0
var coins: int = 0
var stars: int = 0
var lives: int = 3
var distance_m: float = 0.0
var speed: float = 300.0
var is_game_running: bool = false
var is_paused: bool = false
var is_player_dead: bool = false

# This run only (for Game Over / stats)
var coins_earned_this_run: int = 0
var stars_collected_this_run: int = 0
var trick_bonus: int = 0

# Lifetime total fish collected (stats); wallet spends use `coins` only
var total_coins_earned: int = 0
var daily_streak: int = 1

var unlocked_vehicles: Array = ["foot"]

var power_up_timer: float = 0.0
var active_power_up: String = ""
var power_up_duration: float = 0.0
var run_time: float = 0.0
var _target_run_speed: float = 300.0
var best_score: int = 0


func _ready() -> void:
	_init_shop_inventory()


func _init_shop_inventory() -> void:
	for item_id in CONSUMABLES:
		if not shop_inventory.has(item_id):
			shop_inventory[item_id] = 0


func reset_game() -> void:
	score = 0
	stars = 0
	stars_collected_this_run = 0
	coins_earned_this_run = 0
	trick_bonus = 0
	lives = 3
	distance_m = 0.0
	speed = 300.0
	_target_run_speed = 300.0
	is_game_running = false
	is_paused = false
	is_player_dead = false
	active_power_up = ""
	run_time = 0.0
	_reset_run_consumable_flags()
	daily_streak = get_current_streak()
	emit_signal("coin_updated", coins)
	emit_signal("lives_updated", lives)
	emit_signal("score_updated", score)
	emit_signal("star_updated", stars)


func _reset_run_consumable_flags() -> void:
	run_shield_active = false
	run_ice_burst_timer = 0.0
	run_turbo_timer = 0.0


func start_game() -> void:
	score = 0
	stars = 0
	stars_collected_this_run = 0
	coins_earned_this_run = 0
	trick_bonus = 0
	distance_m = 0.0
	is_game_running = true
	is_paused = false
	is_player_dead = false
	run_time = 0.0
	_reset_run_consumable_flags()
	_speed_reset()
	emit_signal("score_updated", score)
	emit_signal("star_updated", stars)


func apply_run_consumables() -> void:
	if consume_consumable("extra_life"):
		lives = MAX_LIVES
		emit_signal("lives_updated", lives)
	if consume_consumable("shield"):
		run_shield_active = true
	if consume_consumable("ice_burst"):
		run_ice_burst_timer = ICE_BURST_DURATION
	if consume_consumable("turbo_vents"):
		run_turbo_timer = TURBO_VENTS_DURATION


func get_inventory_count(item_id: String) -> int:
	return int(shop_inventory.get(item_id, 0))


func consume_consumable(item_id: String) -> bool:
	if not CONSUMABLES.has(item_id):
		return false
	var n: int = get_inventory_count(item_id)
	if n <= 0:
		return false
	shop_inventory[item_id] = n - 1
	emit_signal("shop_inventory_updated")
	SaveManager.save_game()
	return true


func spend_wallet_fish(amount: int) -> bool:
	if amount <= 0:
		return false
	if coins < amount:
		return false
	coins -= amount
	emit_signal("coin_updated", coins)
	SaveManager.save_game()
	return true


func buy_consumable(item_id: String) -> bool:
	if not CONSUMABLES.has(item_id):
		return false
	var cost: int = int(CONSUMABLES[item_id]["cost"])
	if not spend_wallet_fish(cost):
		return false
	shop_inventory[item_id] = get_inventory_count(item_id) + 1
	emit_signal("shop_inventory_updated")
	SaveManager.save_game()
	return true


func get_inventory_summary() -> String:
	var parts: PackedStringArray = []
	for item_id in CONSUMABLES:
		var n: int = get_inventory_count(item_id)
		if n > 0:
			parts.append("%s ×%d" % [CONSUMABLES[item_id]["display"], n])
	if parts.is_empty():
		return "In your bag: nothing yet — buy boosts for your next run."
	return "In your bag: " + ", ".join(parts)


func update_run_boosts(delta: float) -> void:
	if run_ice_burst_timer > 0.0:
		run_ice_burst_timer = maxf(0.0, run_ice_burst_timer - delta)
	if run_turbo_timer > 0.0:
		run_turbo_timer = maxf(0.0, run_turbo_timer - delta)


func get_run_forward_multiplier() -> float:
	var m: float = 1.0
	if run_turbo_timer > 0.0:
		m *= TURBO_SPEED_MULT
	if run_ice_burst_timer > 0.0:
		m *= ICE_SPEED_MULT
	return m


func stop_game(won: bool = false) -> void:
	is_game_running = false
	is_player_dead = true
	run_time += 1.0
	if score > best_score:
		best_score = score
	emit_signal("game_over", won)
	SaveManager.save_game()


func update_score(delta: float, forward_scale: float = 1.0) -> void:
	if not is_game_running:
		return
	var fs: float = clampf(forward_scale, 0.0, 1.0)
	distance_m += speed * delta * 0.12 * fs
	score = int(distance_m) + coins_earned_this_run * 10 + stars_collected_this_run * 100 + trick_bonus
	run_time += delta * fs
	update_run_boosts(delta * fs)
	_increase_difficulty(delta * fs)
	emit_signal("score_updated", score)


func add_coins(pickup_count: int = 1) -> void:
	if pickup_count <= 0:
		return
	coins += pickup_count
	coins_earned_this_run += pickup_count
	total_coins_earned += pickup_count
	score = int(distance_m) + coins_earned_this_run * 10 + stars_collected_this_run * 100 + trick_bonus
	emit_signal("coin_updated", coins)
	emit_signal("score_updated", score)
	_unlock_vehicles()


func add_stars(amount: int = 1) -> void:
	stars += amount
	stars_collected_this_run += amount
	score = int(distance_m) + coins_earned_this_run * 10 + stars_collected_this_run * 100 + trick_bonus
	emit_signal("star_updated", stars)
	emit_signal("score_updated", score)


func lose_life() -> void:
	if lives > 0:
		lives -= 1
		emit_signal("lives_updated", lives)
		if lives <= 0:
			emit_signal("player_locked_out")
			stop_game(false)


func add_life() -> void:
	if lives < MAX_LIVES:
		lives += 1
		emit_signal("lives_updated", lives)


func _unlock_vehicles() -> void:
	if total_coins_earned >= 500 and not "scooter" in unlocked_vehicles:
		unlocked_vehicles.append("scooter")
	if total_coins_earned >= 2000 and not "van" in unlocked_vehicles:
		unlocked_vehicles.append("van")
	if total_coins_earned >= 5000 and not "truck" in unlocked_vehicles:
		unlocked_vehicles.append("truck")
	if total_coins_earned >= 10000 and not "drone" in unlocked_vehicles:
		unlocked_vehicles.append("drone")


func _increase_difficulty(delta: float) -> void:
	if run_time > 210.0:
		_target_run_speed = 540.0
	elif run_time > 150.0:
		_target_run_speed = 480.0
	elif run_time > 90.0:
		_target_run_speed = 410.0
	elif run_time > 45.0:
		_target_run_speed = 345.0
	else:
		_target_run_speed = 300.0
	speed = move_toward(speed, _target_run_speed, 45.0 * delta)


func get_current_streak() -> int:
	return 1


func can_unlock_vehicle(vehicle: String) -> bool:
	return vehicle in unlocked_vehicles


func get_vehicle_cost(vehicle: String) -> int:
	match vehicle:
		"scooter":
			return 500
		"van":
			return 2000
		"truck":
			return 5000
		"drone":
			return 10000
		_:
			return 0


func pause_game() -> void:
	is_paused = true


func resume_game() -> void:
	is_paused = false


func set_power_up(power_name: String, duration: float) -> void:
	active_power_up = power_name
	power_up_duration = duration
	power_up_timer = duration


func update_power_up(delta: float) -> void:
	if active_power_up != "" and power_up_timer > 0.0:
		power_up_timer -= delta
		if power_up_timer <= 0.0:
			active_power_up = ""


func is_power_up_active() -> bool:
	return active_power_up != ""


func add_bonus_score_from_trick(amount: int) -> void:
	if not is_game_running:
		return
	trick_bonus += amount
	score = int(distance_m) + coins_earned_this_run * 10 + stars_collected_this_run * 100 + trick_bonus
	emit_signal("score_updated", score)
