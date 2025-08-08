extends PanelContainer

class_name Deck

@onready var hand_ui = $MarginContainer/VBox/Hand
@onready var minimize_button = $MarginContainer/VBox/HSplitContainer/Minimize
@onready var target_position: Vector2 = position

var data: Array[CardData] = []
var hand_size: int = 5
var hand: Array[CardData] = []
var graveyard: Array[CardData] = []
var is_minimized: bool = false

func _process(delta: float) -> void:
	position = position.lerp(target_position, 8 * delta)


func draw():
	while hand.size() < hand_size and data.size() > 0:
		var index := randi() % data.size()
		var card := data[index]
		hand.append(card)
		data.remove_at(index)
	
	hand_ui.update(hand)


func reroll():
	for card in hand:
		data.append(card)
	hand.clear()
	draw()


func discard(index: int):
	if index >= 0 and index < hand.size():
		var card := hand[index]
		graveyard.append(card)
		hand.remove_at(index)
		draw()


func _on_reroll_pressed() -> void:
	var rerolls = SessionManager.session["reroll"]
	if rerolls > 0:
		reroll()
		SessionManager.session["reroll"] -= 1


func _on_minimize_pressed() -> void:
	if is_minimized:
		minimize_button.text = 'v'
		target_position += Vector2(0, -205)
	else:
		minimize_button.text = '^'
		target_position += Vector2(0, 205)
	is_minimized = not is_minimized
