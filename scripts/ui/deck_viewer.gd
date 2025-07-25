extends Panel

@export var card_ui_scene: PackedScene = preload("res://Scenes/UI/card_ui.tscn")

var margin := 50
var width := 900:
	set(value):
		width = value
		size.x = value

func update(deck: Dictionary):
	clear_deck()
	
	var total_cards := 0
	for key in deck.keys():
		total_cards += deck[key]
		
	if total_cards == 0:
		return
	
	var inner_width = width - margin * 2
	var spacing = inner_width / max(1, total_cards)
	var x_offset = margin + spacing / 2
	
	var i = 0
	
	for key in deck.keys():
		for j in range(deck[key]):
			var data = CollectionManager.get_card_data(key)
			var card_instance = card_ui_scene.instantiate()
			card_instance.card_data = data
			card_instance.mode = "DECK_VIEWER"
			card_instance.origin = Vector2(i * spacing + x_offset - card_instance.size.x / 2, 20)
			card_instance.position = card_instance.origin
			add_child(card_instance)
			i += 1


func clear_deck():
	for child in get_children():
		child.queue_free()
