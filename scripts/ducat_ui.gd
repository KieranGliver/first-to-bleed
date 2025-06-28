extends HBoxContainer

@onready var label = $Label

func update(value: int):
	label.text = str(value)
