extends Control


func _ready() -> void:
	$RootPanel/Center/VBox/PlayBtn.pressed.connect(_on_play_pressed)
	$RootPanel/Center/VBox/ShopBtn.pressed.connect(_on_shop_pressed)
	$RootPanel/Center/VBox/HowBtn.pressed.connect(_on_how_pressed)
	$HowPanel/HowCenter/HowVBox/CloseBtn.pressed.connect(_on_how_close)
	var quit_btn: Button = $RootPanel/Center/VBox/QuitBtn
	var desktop := OS.get_name() in ["Windows", "macOS", "Linux", "FreeBSD", "UWP"]
	quit_btn.visible = desktop
	if desktop:
		quit_btn.pressed.connect(func() -> void: get_tree().quit())


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/runner/TempleRunMain.tscn")


func _on_shop_pressed() -> void:
	GameManager.shop_return_scene = "res://scenes/main/MainMenu.tscn"
	get_tree().change_scene_to_file("res://scenes/main/Shop.tscn")


func _on_how_pressed() -> void:
	$HowPanel.visible = true


func _on_how_close() -> void:
	$HowPanel.visible = false
