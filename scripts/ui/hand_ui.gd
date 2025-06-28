extends HBoxContainer

class_name HandUI

@export var card_ui_scene: PackedScene = preload("res://Scenes/UI/card_ui.tscn")
var current_hand: Array[CardData] = []
signal card_chosen(card_data: CardData)

func update(cards: Array[CardData]):
	clear_hand()
	for card in cards:
		var card_instance = card_ui_scene.instantiate()
		card_instance.card_data = card
		card_instance.card_selected.connect(_on_card_selected)
		add_child(card_instance)

func _on_card_selected(card_data: CardData):
	card_chosen.emit(card_data)

func clear_hand():
	for child in get_children():
		child.queue_free()
