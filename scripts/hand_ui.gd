extends Panel

@export var gm : GameManager
@export var deck : Deck
@export var card_ui_scene: PackedScene = preload("res://Scenes/UI/card_ui.tscn")
signal card_chosen(card_data: CardData)

func update(cards: Array[CardData]):
	clear_hand()
	for i in range(cards.size()):
		var card_instance = card_ui_scene.instantiate()
		card_instance.card_data = cards[i]
		card_instance.origin = Vector2(20 + 140 * i, 20)
		card_instance.position = card_instance.origin
		card_instance.card_selected.connect(gm._on_hand_ui_card_chosen)
		add_child(card_instance)

func clear_hand():
	for child in get_children():
		child.queue_free()
