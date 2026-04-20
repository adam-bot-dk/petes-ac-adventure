extends Node3D

const _TIPS: Array[String] = [
	"Tip: Change your HVAC filter every 1–3 months for cleaner air.",
	"Tip: Seasonal tune-ups help avoid surprise breakdowns.",
	"Tip: Red jump blocks — jump. Teal low blocks — slide.",
	"Tip: Collect fish snacks for wallet rewards and score.",
]


func _ready() -> void:
	GameManager.reset_game()
	GameManager.start_game()
	var hud: Control = get_node_or_null("CanvasLayer/HUD")
	if hud and hud.has_method("update_all"):
		hud.update_all()
	_add_run_tip()


func _add_run_tip() -> void:
	var cl: CanvasLayer = get_node_or_null("CanvasLayer")
	if cl == null:
		return
	var tip := Label.new()
	tip.text = _TIPS[randi() % _TIPS.size()]
	tip.position = Vector2(20.0, 1188.0)
	tip.size = Vector2(680.0, 72.0)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0, 0.72))
	cl.add_child(tip)


func _process(delta: float) -> void:
	if GameManager.is_game_running:
		var fs: float = 1.0
		var p: Node = get_node_or_null("Player")
		if p and p.has_method("get_forward_scale"):
			fs = p.get_forward_scale()
		GameManager.update_score(delta, fs)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameManager.is_game_running:
		GameManager.pause_game()
		var hud: Control = get_node_or_null("CanvasLayer/HUD")
		if hud and hud.has_method("show_pause_menu"):
			hud.show_pause_menu()
