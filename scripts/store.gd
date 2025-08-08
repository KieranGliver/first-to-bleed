extends Node2D

class_name Store

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var buttons: Array[Button] = [$CanvasLayer/UI/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ShopButton1, $CanvasLayer/UI/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ShopButton2, $CanvasLayer/UI/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ShopButton3]
@onready var deck_viewer = $CanvasLayer/UI/DeckViewer
@onready var bucks_ui = $CanvasLayer/UI/Bucks

var stock: Array[CardData] = []
var bucks: int = 10:
	set(value):
		bucks = value
		if bucks_ui:
			bucks_ui.text = str(value) + " Bucks"


func _ready() -> void:
	bucks = bucks
	reroll()


func _on_next_day_button_pressed() -> void:
	SessionManager.save_session()
	SessionManager.upload_deck()
	main.switch_scene('gm')


func reroll():
	stock.clear()
	for button in buttons:
		button.disabled = false
	for i in range(3):
		var card = CollectionManager.random_card()
		stock.append(card)
		buttons[i].update(card)


func _on_shop_button_pressed(index: int) -> void:
	if bucks >= 3:
		SessionManager.add_card(stock[index].building_name)
		bucks -= 3
		buttons[index].disabled = true
		deck_viewer.update(SessionManager.session["deck"])


func _on_deck_button_pressed() -> void:
	deck_viewer.update(SessionManager.session["deck"])
	deck_viewer.visible = not deck_viewer.visible


func _on_reroll_pressed() -> void:
	var rerolls = SessionManager.session["reroll"]
	if rerolls > 0:
		reroll()
		SessionManager.session["reroll"] -= 1


func _on_buy_reroll_button_pressed() -> void:
	if bucks >= 2:
		SessionManager.session["reroll"] += 1
		bucks -= 2
