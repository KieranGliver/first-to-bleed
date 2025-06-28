extends PanelContainer
class_name CardUI

signal card_selected(card_data: CardData)

@export var card_data: CardData

@onready var cost_label: Label = $MarginContainer/VBoxContainer/cost
@onready var name_label: Label = $MarginContainer/VBoxContainer/name
@onready var desc_label: Label = $MarginContainer/VBoxContainer/description

func _ready():
	cost_label.text = str(card_data.cost)
	name_label.text = Data.BUILDING_NAME_TO_STRING[card_data.building_name]
	desc_label.text = card_data.description


func _on_button_pressed() -> void:
	card_selected.emit(card_data)
