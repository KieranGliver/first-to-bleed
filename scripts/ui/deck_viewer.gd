extends PanelContainer

@onready var label = $Label

func update(deck: Dictionary):
	var ret = ""
	for key in deck.keys():
		var card_data = CollectionManager.get_card_data(key)
		var quantity = str(deck[key])
		ret += Data.BUILDING_NAME_TO_STRING[key] + " x " + quantity + "\n"
	label.text = ret
