extends MarginContainer

class_name TeamStats

enum Colour {BLUE, RED, GREEN, GREY}

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TeamLabel
@onready var tile_box: StatBox = $PanelContainer/VBoxContainer/TileBox
@onready var gold_box: StatBox = $PanelContainer/VBoxContainer/GoldBox
@onready var bounce_box: StatBox = $PanelContainer/VBoxContainer/BounceBox
@onready var card_box: StatBox = $PanelContainer/VBoxContainer/CardBox

@export var title: String = '':
	set(value):
		title = value
		_update_labels()
@export var tile: int = 0:
	set(value):
		tile = value
		_update_labels()
@export var ducat: int = 0:
	set(value):
		ducat = value
		_update_labels()
@export var bounce: int = 0:
	set(value):
		bounce = value
		_update_labels()
@export var card: int = 0:
	set(value):
		card = value
		_update_labels()
@export var bg_colour: Colour = Colour.BLUE:
	set(value):
		bg_colour = value
		panel.add_theme_stylebox_override("panel", colour_resource[value])

var colour_resource = [load("res://Resources/blue.tres"), load("res://Resources/red.tres"), load("res://Resources/green.tres"), load("res://Resources/grey.tres")]

func _ready() -> void:
	tile_box.title = 'Total Tiles:'
	gold_box.title = 'Total Ducats:'
	bounce_box.title = 'Total Bounces:'
	card_box.title = 'Total Cards Played:'
	_update_labels()


func _update_labels():
	title_label.text = title
	tile_box.data = str(tile)
	gold_box.data = str(ducat)
	bounce_box.data = str(bounce)
	card_box.data = str(card)
