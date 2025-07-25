extends HBoxContainer

class_name StatBox

@onready var title_label = $Title
@onready var data_label = $Data

@export var title: String = '':
	set(value):
		title = value
		_update_labels()
@export var data: String = '':
	set(value):
		data = value
		_update_labels()


func _ready():
	_update_labels()


func _update_labels():
	title_label.text = title
	data_label.text = data
