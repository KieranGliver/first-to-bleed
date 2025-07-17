extends NinePatchRect

class_name CardUI

signal card_selected(card_data: CardData, index: int)

@export var card_data: CardData
@export var origin : Vector2

@onready var cost_label: Label = $cost
@onready var name_label: Label = $name
@onready var desc_label: Label = $Panel/description

var OFFMAG = 4

enum {IDLE, PLACED, PICKED, DISABLED}
var state = IDLE
var offset : Vector2
var offset_target : Vector2
var pos_target : Vector2
var rotation_target : int

func _ready():
	update()
	pos_target = origin


func _process(delta):
		if state == PICKED:
			pos_target = get_parent().get_local_mouse_position()
		
		if offset != null and offset != offset_target:
			offset = offset.lerp(offset_target,0.2)
		
		if pos_target != null and position != pos_target:
			position = position.lerp(pos_target + offset,0.20)
		
		if rotation_target != null and rotation_target != rotation_degrees:
			rotation_degrees = rotation_degrees + (rotation_target - rotation_degrees)*0.15


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and !event.pressed and state == PICKED:
			visible = true
			place()


func update():
	cost_label.text = str(card_data.cost)
	name_label.text = Data.BUILDING_NAME_TO_STRING[card_data.building_name]
	desc_label.text = card_data.description


func pick():
	move_to_front()
	
	# Set the offset of object to mouse and add offset magnitude to the y
	offset = position - get_parent().get_local_mouse_position()
	offset_target = offset+Vector2(0, -OFFMAG)
	
	state = PICKED


func place():
	pos_target = origin
	offset_target = Vector2.ZERO
	offset = Vector2.ZERO
	state = IDLE


func _on_area_2d_mouse_down(event: InputEventMouseButton) -> void:
		pick()
		card_selected.emit(card_data, (origin.x - 20)/140)


func _on_area_2d_drag(event: InputEventMouseMotion) -> void:
		visible = false
