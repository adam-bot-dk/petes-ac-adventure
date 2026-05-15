extends Control

# HUD Controller — score, fish, lives, pause (runner + legacy 2D main)

const PAUSE_OVERLAY_SCENE := preload("res://scenes/ui/PauseOverlay.tscn")

var score_label: Label
var coin_label: Label
var star_label: Label
var heart_labels: Array[Label]
var pause_button: Button
var _pause_overlay: Control
var _lives_count_label: Label


func _ready() -> void:
	score_label = $TopBar/StatsColumn/ScoreRow/ScoreValue
	coin_label = $TopBar/StatsColumn/CoinRow/CoinValue
	star_label = $TopBar/StatsColumn/StarRow/StarValue
	heart_labels = [
		$TopBar/LivesColumn/LivesRow/Heart1,
		$TopBar/LivesColumn/LivesRow/Heart2,
		$TopBar/LivesColumn/LivesRow/Heart3,
		$TopBar/LivesColumn/LivesRow/Heart4,
	]
	_lives_count_label = $TopBar/LivesColumn/LivesCountLabel
	pause_button = $TopBar/PauseButton
	pause_button.pressed.connect(_on_pause_button_pressed)
	_apply_mouse_ignore_except_pause(self)

	GameManager.score_updated.connect(_on_score_updated)
	GameManager.coin_updated.connect(_on_coin_updated)
	GameManager.star_updated.connect(_on_star_updated)
	GameManager.lives_updated.connect(_on_lives_updated)
	GameManager.game_over.connect(_on_game_over)

	update_all()


func _apply_mouse_ignore_except_pause(n: Node) -> void:
	if n is Control:
		var ctrl := n as Control
		if ctrl != pause_button:
			ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in n.get_children():
		_apply_mouse_ignore_except_pause(child)


func _on_pause_button_pressed() -> void:
	var root := get_tree().current_scene
	if root and root.has_method("request_pause_menu"):
		root.request_pause_menu()
		return
	if GameManager.is_game_running and not GameManager.is_paused:
		GameManager.pause_game()
		show_pause_menu()


func update_all() -> void:
	score_label.text = str(GameManager.score)
	coin_label.text = str(GameManager.coins)
	star_label.text = str(GameManager.stars)
	update_lives()


func update_lives() -> void:
	var max_lives: int = GameManager.MAX_LIVES
	for i in range(heart_labels.size()):
		var c := Color(1, 0.28, 0.32, 1) if i < GameManager.lives else Color(0.5, 0.12, 0.14, 1)
		heart_labels[i].add_theme_color_override("font_color", c)
	if _lives_count_label:
		_lives_count_label.text = "LIVES %d/%d" % [GameManager.lives, max_lives]


func _on_score_updated(new_score: int) -> void:
	score_label.text = str(new_score)


func _on_coin_updated(new_coins: int) -> void:
	coin_label.text = str(new_coins)


func _on_star_updated(new_stars: int) -> void:
	star_label.text = str(new_stars)


func _on_lives_updated(_new_lives: int) -> void:
	update_lives()


func _on_game_over(_won: bool) -> void:
	pass


func hide_pause_menu() -> void:
	if _pause_overlay:
		_pause_overlay.queue_free()
		_pause_overlay = null


func show_pause_menu() -> void:
	hide_pause_menu()
	var overlay: Control = PAUSE_OVERLAY_SCENE.instantiate() as Control
	_pause_overlay = overlay
	overlay.resume_pressed.connect(_on_pause_overlay_resume)
	overlay.restart_pressed.connect(_on_pause_overlay_restart)
	add_child(overlay)
	overlay.move_to_front()


func _on_pause_overlay_resume() -> void:
	GameManager.resume_game()
	hide_pause_menu()


func _on_pause_overlay_restart() -> void:
	GameManager.resume_game()
	hide_pause_menu()
	get_tree().reload_current_scene()
