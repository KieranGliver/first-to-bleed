extends Button

func update(card: CardData) -> void:
	text = "%s (%s)\nCost: %d\n%s" % [
		Data.BUILDING_NAME_TO_STRING[card.building_name],
		card.rarity,
		card.cost,
		card.description
	]
