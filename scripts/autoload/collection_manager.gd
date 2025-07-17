extends Node

@export var folder_path = "res://Cards/"
var cards: Dictionary = {}


func _ready() -> void:
	var paths = FileExplorer.traverse_directory(folder_path, false)
	for path in paths:
		if path.get_extension().to_lower() == "tres":
			var res_name = path.get_file().get_basename().to_lower()
			var res = ResourceLoader.load(path)
			if res is Resource:
				cards[res_name] = res


func get_card_data(card_index: int) -> CardData:
	return cards[Data.BUILDING_NAME_TO_STRING[card_index]]


func random_card() -> CardData:
	return cards[Data.BUILDING_NAME_TO_STRING[randi_range(0, cards.size()-1)]]
