extends Control

var score_label: Label
var stars_label: Label
var coin_run_label: Label
var wallet_label: Label
var coupon_label: Label
var best_label: Label
var result_hint_label: Label

func _ready() -> void:
	score_label = $Panel/VBox/ScoreRow/ScoreValue
	stars_label = $Panel/VBox/StarsRow/StarsValue
	coin_run_label = $Panel/VBox/CoinsRow/CoinValue
	wallet_label = $Panel/VBox/WalletRow/WalletValue
	coupon_label = $Panel/VBox/CouponValue
	best_label = $Panel/VBox/BestRow/BestValue
	result_hint_label = $Panel/VBox/ResultHintLabel
	$Panel/VBox/RedeemBtn.pressed.connect(_on_redeem_pressed)
	$Panel/VBox/ShopBtn.pressed.connect(_on_shop_pressed)
	$Panel/VBox/RestartBtn.pressed.connect(_on_restart_pressed)
	$Panel/VBox/HomeBtn.pressed.connect(_on_home_pressed)
	GameManager.game_over.connect(_on_game_over)

func _on_game_over(_won: bool) -> void:
	visible = true
	score_label.text = str(GameManager.score)
	stars_label.text = str(GameManager.stars_collected_this_run)
	coin_run_label.text = str(GameManager.coins_earned_this_run)
	wallet_label.text = str(GameManager.coins)
	var coupon_value: float = GameManager.get_coupon_value(GameManager.coins)
	coupon_label.text = "Est. value: $%.2f (1000 fish ≈ $1)" % coupon_value
	best_label.text = str(GameManager.best_score)
	result_hint_label.text = "You ran out of lives."

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/Shop.tscn")


func _on_redeem_pressed() -> void:
	var c: int = GameManager.coins
	if c < 1000:
		print("Need at least 1000 wallet fish for a coupon code.")
		return
	var code := GameManager.get_earned_coupon_code(c)
	print("Coupon code: ", code, " — show at Pure Heating & Air.")

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/runner/TempleRunMain.tscn")
