extends Control

## Wallet fish shop — buy consumables for the next run.

@onready var _wallet_value: Label = $Panel/VBox/WalletRow/WalletValue
@onready var _bag_label: Label = $Panel/VBox/BagLabel
@onready var _items_vbox: VBoxContainer = $Panel/VBox/Scroll/ItemsVBox
@onready var _status_label: Label = $Panel/VBox/StatusLabel

var _buy_buttons: Dictionary = {}
var _owned_labels: Dictionary = {}


func _ready() -> void:
	$Panel/VBox/BackBtn.pressed.connect(_on_back_pressed)
	GameManager.coin_updated.connect(_on_wallet_changed)
	GameManager.shop_inventory_updated.connect(_refresh_all)
	_build_item_rows()
	_refresh_all()


func _build_item_rows() -> void:
	for child in _items_vbox.get_children():
		child.queue_free()
	_buy_buttons.clear()
	_owned_labels.clear()

	for item_id in GameManager.CONSUMABLES:
		var data: Dictionary = GameManager.CONSUMABLES[item_id]
		var row := PanelContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		row.add_child(margin)

		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		margin.add_child(h)

		var text_col := VBoxContainer.new()
		text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_theme_constant_override("separation", 4)
		h.add_child(text_col)

		var name_l := Label.new()
		name_l.text = data["display"]
		name_l.add_theme_font_size_override("font_size", 20)
		text_col.add_child(name_l)

		var desc_l := Label.new()
		desc_l.text = data["description"]
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_l.add_theme_font_size_override("font_size", 14)
		desc_l.add_theme_color_override("font_color", Color(0.78, 0.82, 0.88))
		text_col.add_child(desc_l)

		var owned_l := Label.new()
		owned_l.add_theme_font_size_override("font_size", 13)
		text_col.add_child(owned_l)
		_owned_labels[item_id] = owned_l

		var buy_btn := Button.new()
		buy_btn.custom_minimum_size = Vector2(120, 44)
		var cost: int = int(data["cost"])
		buy_btn.text = "%d fish" % cost
		buy_btn.pressed.connect(_on_buy_pressed.bind(item_id))
		h.add_child(buy_btn)
		_buy_buttons[item_id] = buy_btn

		_items_vbox.add_child(row)


func _refresh_all() -> void:
	_wallet_value.text = str(GameManager.coins)
	_bag_label.text = GameManager.get_inventory_summary()
	_status_label.text = ""
	for item_id in GameManager.CONSUMABLES:
		var btn: Button = _buy_buttons.get(item_id)
		if btn:
			var cost: int = int(GameManager.CONSUMABLES[item_id]["cost"])
			btn.disabled = GameManager.coins < cost
		var owned: Label = _owned_labels.get(item_id)
		if owned:
			var n: int = GameManager.get_inventory_count(item_id)
			owned.text = "Owned: %d" % n if n > 0 else ""


func _on_wallet_changed(_coins: int) -> void:
	_refresh_all()


func _on_buy_pressed(item_id: String) -> void:
	if GameManager.buy_consumable(item_id):
		_status_label.text = "Purchased %s!" % GameManager.CONSUMABLES[item_id]["display"]
	else:
		_status_label.text = "Need more fish in your wallet."
	_refresh_all()


func _on_back_pressed() -> void:
	var path: String = GameManager.shop_return_scene
	if path.is_empty():
		path = "res://scenes/main/MainMenu.tscn"
	get_tree().change_scene_to_file(path)
