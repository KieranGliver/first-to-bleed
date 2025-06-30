extends PanelContainer

class_name Deck

@export var deck: Array[CardData] = []
@export var hand_size: int = 5
var hand: Array[CardData] = []
var graveyard: Array[CardData] = []


@onready var hand_ui = $MarginContainer/VBox/Hand

func draw():
	while hand.size() < hand_size and deck.size() > 0:
		var index := randi() % deck.size()
		var card := deck[index]
		hand.append(card)
		deck.remove_at(index)
	
	hand_ui.update(hand)

func reroll():
	for card in hand:
		deck.append(card)
	hand.clear()
	draw()

func discard(index: int):
	if index >= 0 and index < hand.size():
		var card := hand[index]
		graveyard.append(card)
		hand.remove_at(index)
		draw()

func _on_reroll_pressed() -> void:
	reroll()
