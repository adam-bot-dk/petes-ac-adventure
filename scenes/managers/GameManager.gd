extends Node

# Game State Singleton — distance score, lives, wallet fish tally, coupons.
# "coins" fields store fish count for scoring/unlocks; UI labels say "fish".

signal score_updated(score: int)
signal coin_updated(coins: int)
signal star_updated(stars: int)
signal lives_updated(lives: int)
signal game_over(won: bool)
signal player_locked_out()

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

# Lifetime wallet (for unlocks); persists for session — hook to save/load later
var total_coins_earned: int = 0
var daily_streak: int = 1

var unlocked_vehicles: Array = ["foot"]

var power_up_timer: float = 0.0
var active_power_up: String = ""
var power_up_duration: float = 0.0
var run_time: float = 0.0
## Smoothed target for difficulty ramp (updated in update_score).
var _target_run_speed: float = 300.0
## Best single-run score (persisted via SaveManager).
var best_score: int = 0

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
	daily_streak = get_current_streak()
	emit_signal("coin_updated", coins)
	emit_signal("lives_updated", lives)
	emit_signal("score_updated", score)
	emit_signal("star_updated", stars)

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
	_speed_reset()
	emit_signal("score_updated", score)
	emit_signal("star_updated", stars)

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
	# GDD: base score from distance (meters); tuned constant feels like “meters” on HUD
	distance_m += speed * delta * 0.12 * fs
	score = int(distance_m) + coins_earned_this_run * 10 + stars_collected_this_run * 100 + trick_bonus
	run_time += delta * fs
	_increase_difficulty(delta * fs)
	emit_signal("score_updated", score)

func add_coins(pickup_count: int = 1) -> void:
	coins += pickup_count
	coins_earned_this_run += pickup_count
	total_coins_earned += pickup_count
	score = int(distance_m) + coins_earned_this_run * 10 + stars_collected_this_run * 100 + trick_bonus
	emit_signal("coin_updated", coins)
	emit_signal("score_updated", score)
	_unlock_vehicles()
	if pickup_count < 0:
		SaveManager.save_game()

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
	if lives < 3:
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

func get_coupon_value(coins_amount: int) -> float:
	return float(coins_amount) / 1000.0

func get_earned_coupon_code(coins_amount: int) -> String:
	if coins_amount < 1000:
		return ""
	var payload := "%d|%d|%d" % [coins_amount, Time.get_unix_time_from_system(), randi()]
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(payload.to_utf8_buffer())
	var digest := ctx.finish()
	return "PURE-%s" % digest.hex_encode().substr(0, 12).to_upper()

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
