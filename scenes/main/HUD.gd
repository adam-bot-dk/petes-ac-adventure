extends Control

# HUD Controller
# Manages score, fish tally (GameManager.coins), lives display

var score_label: Label
var coin_label: Label
var star_label: Label
var heart_labels: Array[Label]
var pause_button: Button
var _pause_overlay: Control
var _lives_count_label: Label

func _ready():
	# Get references
	score_label = $VBoxContainer/ScoreContainer/ScoreValue
	coin_label = $VBoxContainer/CoinContainer/CoinValue
	star_label = $VBoxContainer/StarContainer/StarValue
	heart_labels = [$VBoxContainer/LivesContainer/Heart1, 
					$VBoxContainer/LivesContainer/Heart2, 
					$VBoxContainer/LivesContainer/Heart3]
	pause_button = $VBoxContainer/PauseButton
	_lives_count_label = Label.new()
	_lives_count_label.text = "LIVES 3/3"
	_lives_count_label.position = Vector2(500, 52)
	_lives_count_label.add_theme_font_size_override("font_size", 16)
	_lives_count_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.9))
	add_child(_lives_count_label)
	_apply_mouse_ignore_except_pause(self)

	# Connect signals
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.coin_updated.connect(_on_coin_updated)
	GameManager.star_updated.connect(_on_star_updated)
	GameManager.lives_updated.connect(_on_lives_updated)
	GameManager.game_over.connect(_on_game_over)
	
	# Initial update
	update_all()


func _apply_mouse_ignore_except_pause(n: Node) -> void:
	if n is Control:
		var ctrl := n as Control
		if ctrl != pause_button:
			ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in n.get_children():
		_apply_mouse_ignore_except_pause(child)


func update_all():
	"""Update all HUD elements"""
	score_label.text = str(GameManager.score)
	coin_label.text = str(GameManager.coins)
	star_label.text = str(GameManager.stars)
	update_lives()

func update_lives():
	"""Update heart icons"""
	for i in range(3):
		var c := Color(1, 0, 0, 1) if i < GameManager.lives else Color(0.5, 0, 0, 1)
		heart_labels[i].add_theme_color_override("font_color", c)
	if _lives_count_label:
		_lives_count_label.text = "LIVES %d/3" % GameManager.lives

func _on_score_updated(new_score):
	score_label.text = str(new_score)

func _on_coin_updated(new_coins):
	coin_label.text = str(new_coins)

func _on_star_updated(new_stars):
	star_label.text = str(new_stars)

func _on_lives_updated(new_lives):
	update_lives()

func _on_game_over(_won):
	pass

func hide_pause_menu() -> void:
	if _pause_overlay:
		_pause_overlay.queue_free()
		_pause_overlay = null

func show_pause_menu():
	"""Show pause overlay"""
	hide_pause_menu()
	_pause_overlay = create_pause_panel()
	add_child(_pause_overlay)

func create_pause_panel():
	"""Create pause menu overlay"""
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", create_dark_stylebox())
	panel.position = Vector2(0, 0)
	panel.size = Vector2(720, 1280)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.position = Vector2(100, 200)
	vbox.size = Vector2(520, 500)
	panel.add_child(vbox)
	
	var brand = Label.new()
	brand.text = "Pure Heating & Air"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 22)
	brand.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0))
	vbox.add_child(brand)

	var subtitle = Label.new()
	subtitle.text = "Pete's AC Adventure"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	vbox.add_child(subtitle)

	var title = Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	var resume_btn = Button.new()
	resume_btn.text = "▶ RESUME"
	resume_btn.pressed.connect(_on_resume_pressed)
	vbox.add_child(resume_btn)
	
	var restart_btn = Button.new()
	restart_btn.text = "🔄 RESTART"
	restart_btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_btn)
	
	return panel

func _on_resume_pressed():
	GameManager.resume_game()
	get_tree().reload_current_scene()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func create_dark_stylebox():
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0.8)
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color(1, 1, 1, 0.3)
	return stylebox
