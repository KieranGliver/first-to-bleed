extends PanelContainer

class_name BuildingPopup

@onready var cost_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Cost
@onready var name_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Name
@onready var desc_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Panel/Description

var card_data: CardData

func _ready() -> void:
	update()


func update():
	cost_label.text = str(card_data.cost)
	name_label.text = Data.BUILDING_NAME_TO_STRING[card_data.building_name]
	desc_label.text = card_data.description
