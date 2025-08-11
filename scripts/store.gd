extends Node2D

class_name Store

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var shop_buttons: Array[Button] = [$CanvasLayer/UI/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ShopButton1, $CanvasLayer/UI/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ShopButton2, $CanvasLayer/UI/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ShopButton3]
@onready var remove_buttons: Array[Button] = [$CanvasLayer/UI/HBoxContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Button, $CanvasLayer/UI/HBoxContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Button2,  $CanvasLayer/UI/HBoxContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Button3]
@onready var deck_viewer = $CanvasLayer/UI/DeckViewer
@onready var bucks_ui = $CanvasLayer/UI/Bucks

var stock: Array[CardData] = []
var discard_stock: Array[CardData] = []
var bucks: int = 10:
	set(value):
		bucks = value
		if bucks_ui:
			bucks_ui.text = str(value) + " Bucks"


func _ready() -> void:
	SoundManager.play("top_garage", -30, true)
	bucks = bucks
	reroll()
	reroll_delete()


func _on_next_day_button_pressed() -> void:
	SoundManager.stop_all()
	SessionManager.save_session()
	SessionManager.upload_deck()
	main.switch_scene('gm')


func reroll():
	stock.clear()
	for button in shop_buttons:
		button.disabled = false
	for i in range(3):
		var card = CollectionManager.random_card()
		stock.append(card)
		shop_buttons[i].update(card)


func reroll_delete():
	discard_stock.clear()
	for button in remove_buttons:
		button.disabled = false
		
	var deck_copy = SessionManager.session["deck"].duplicate()
	if deck_copy.size() == 0:
		for button in remove_buttons:
			button.disabled = true
		return
	
	var deck_keys = deck_copy.keys()
	var total_cards = 0
	
	for key in deck_keys:
		total_cards += deck_copy[key]
	deck_keys.shuffle()
	
	for i in range(remove_buttons.size()):
		var key = deck_keys.pick_random()
		if i < total_cards:
			var card = CollectionManager.get_card_data(key)
			discard_stock.append(card)
			deck_copy[key] -= 1
			var amount = deck_copy[key]
			if amount <= 0:
				deck_keys.erase(key)
			remove_buttons[i].update(card)
		else:
			remove_buttons[i].disabled = true


func _on_shop_button_pressed(index: int) -> void:
	if bucks >= 3:
		SessionManager.add_card(stock[index].building_name)
		bucks -= 3
		SoundManager.play("cha_ching", -25)
		shop_buttons[index].disabled = true
		deck_viewer.update(SessionManager.session["deck"])
	else:
		SoundManager.play("buzzer", -20)


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
		SoundManager.play("cha_ching", -25)
	else:
		SoundManager.play("buzzer", -20)


func _on_discard_button_pressed(index: int) -> void:
	if bucks >= 3:
		var card = discard_stock[index]
		var deck = SessionManager.session["deck"]
		remove_buttons[index].disabled = true
		var amount = deck[card.building_name]
		if amount > 1:
			deck[card.building_name] -= 1
		else:
			deck.erase(card.building_name)
		bucks -= 3
		deck_viewer.update(SessionManager.session["deck"])
		SoundManager.play("cha_ching", -25)
	else:
		SoundManager.play("buzzer", -20)


func _on_reroll_delete_pressed() -> void:
	var rerolls = SessionManager.session["reroll"]
	if rerolls > 0:
		reroll_delete()
		SessionManager.session["reroll"] -= 1
