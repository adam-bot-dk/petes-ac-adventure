extends Node2D

# Spawns obstacles and collectibles ahead of the player (camera-relative).

var obstacle_scenes := {
	"pothole": preload("res://scenes/gameplay/Obstacle_Pothole.tscn"),
	"hot_puddle": preload("res://scenes/gameplay/Obstacle_HotPuddle.tscn"),
	"ac_unit": preload("res://scenes/gameplay/Obstacle_ACUnit.tscn"),
	"bird": preload("res://scenes/gameplay/Obstacle_Bird.tscn"),
	"cone": preload("res://scenes/gameplay/Obstacle_Cone.tscn"),
	"truck": preload("res://scenes/gameplay/Obstacle_Truck.tscn")
}

var coin_scene := preload("res://scenes/gameplay/Collectible_Coin.tscn")
var star_scene := preload("res://scenes/gameplay/Collectible_Star.tscn")
var powerup_scene := preload("res://scenes/gameplay/PowerUp.tscn")

var obstacle_timer: float = 0.35
var collectible_timer: float = 0.5

var spawn_x_ahead: float = 420.0

var obstacle_weights := {
	"pothole": 30,
	"hot_puddle": 25,
	"ac_unit": 15,
	"bird": 15,
	"cone": 10,
	"truck": 5
}

var power_up_types: Array = ["ice_burst", "turbo_vents", "service_van", "pete_clone"]

func _ready() -> void:
	await get_tree().create_timer(0.15).timeout
	GameManager.score_updated.connect(_on_score_updated)

func _get_player() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("player") as CharacterBody2D

func _spawn_x() -> float:
	var p := _get_player()
	if p:
		return p.global_position.x + spawn_x_ahead
	return 700.0

func _ground_y() -> float:
	var p := _get_player()
	if p:
		return p.global_position.y
	return 1156.0

func _process(delta: float) -> void:
	if not GameManager.is_game_running:
		return
	obstacle_timer -= delta
	collectible_timer -= delta
	if obstacle_timer <= 0.0:
		_spawn_obstacle()
		obstacle_timer = randf_range(0.85, 1.65) * (350.0 / maxf(50.0, GameManager.speed))
	if collectible_timer <= 0.0:
		_spawn_collectible()
		collectible_timer = randf_range(0.45, 1.1)
	_remove_old_objects()

func _pick_obstacle_type() -> String:
	var total := 0
	for w in obstacle_weights.values():
		total += w as int
	var r := randf_range(0.0, float(total))
	var acc := 0
	for type_name in obstacle_weights:
		acc += obstacle_weights[type_name] as int
		if r <= float(acc):
			return type_name
	return "pothole"

func _spawn_y_for_type(type_name: String, py: float) -> float:
	match type_name:
		"bird":
			return py - 88.0
		"ac_unit":
			return py - 130.0
		"truck":
			return py + randf_range(-10.0, 8.0)
		_:
			return py + randf_range(-22.0, 12.0)

func _spawn_obstacle() -> void:
	var type_name := _pick_obstacle_type()
	if not type_name in obstacle_scenes:
		return
	var py := _ground_y()
	var y := _spawn_y_for_type(type_name, py)
	var obs: Node2D = obstacle_scenes[type_name].instantiate() as Node2D
	obs.position = Vector2(_spawn_x(), y)
	add_child(obs)

func _spawn_collectible() -> void:
	var py := _ground_y()
	var sx := _spawn_x()
	var roll := randi() % 100
	if roll < 58:
		_spawn_coins(py, sx)
	elif roll < 86:
		_spawn_star(py, sx)
	else:
		_spawn_power_up(py, sx)

func _spawn_coins(py: float, sx: float) -> void:
	var n := randi_range(4, 8)
	for i in range(n):
		var coin: Node2D = coin_scene.instantiate() as Node2D
		coin.position = Vector2(sx + float(i) * 36.0, py + randf_range(-18.0, 8.0))
		add_child(coin)

func _spawn_star(py: float, sx: float) -> void:
	var star: Node2D = star_scene.instantiate() as Node2D
	star.position = Vector2(sx, py - 95.0)
	add_child(star)

func _spawn_power_up(py: float, sx: float) -> void:
	var power_up = powerup_scene.instantiate()
	power_up.power_up_type = power_up_types[randi() % power_up_types.size()]
	power_up.position = Vector2(sx, py - 40.0)
	add_child(power_up)

func _on_score_updated(_new_score: int) -> void:
	pass

func _remove_old_objects() -> void:
	var px: float = 0.0
	var p := _get_player()
	if p:
		px = p.global_position.x
	for child in get_children():
		if child is Node2D and child.position.x < px - 420.0:
			child.queue_free()
