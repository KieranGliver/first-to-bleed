extends Control

class_name PopupManager

const OFFSET: Vector2 = Vector2(32, 0)
const BUFFER: int = 64

@onready var gm: GameManager = get_tree().get_first_node_in_group('game_manager')
@onready var building_popup: PackedScene = preload("res://Scenes/UI/building_popup.tscn")
@onready var timer: Timer = $Timer

var hover_building: Building
var hover_coords: Vector2i
var popup: BuildingPopup

func _process(delta: float) -> void:
	var local_position = gm.get_local_mouse_position()
	var new_coords = gm.map_manager.local_to_map(local_position)
	if new_coords != hover_coords:
		hover_coords = new_coords
		if gm.map_manager.building_map.keys().has(hover_coords):
			var building = gm.map_manager.building_map[hover_coords]
			if building != hover_building:
				print('timer start')
				timer.paused = false
				timer.start()
		else:
			timer.paused = true
	
	if popup:
		var zoom_factor = gm.get_viewport().get_camera_2d().zoom
		
		var screen_pos = get_viewport().canvas_transform * (hover_building.position + Vector2(32, 32)) + OFFSET * zoom_factor
		popup.position = screen_pos + Vector2(10, -popup.size.y / 2)
		
		var mouse_screen_pos = get_viewport().get_mouse_position()
		
		var scaled_buffer = BUFFER * zoom_factor
		var popup_rect = popup.get_global_rect().grow(scaled_buffer.x)

		if not popup_rect.has_point(mouse_screen_pos):
			popup.queue_free()
			popup = null
			hover_building = null

func initalize_building_popup(card_data: CardData, local_position: Vector2):
	if popup:
		popup.queue_free()
	popup = building_popup.instantiate()
	popup.card_data = card_data
	add_child(popup)
	popup.position = local_position
	await get_tree().process_frame
	popup.visible = true


func _on_timer_timeout() -> void:
	var zoom_factor = gm.get_viewport().get_camera_2d().zoom
	hover_building = gm.map_manager.building_map[hover_coords]
	print('timeout')
	initalize_building_popup(hover_building.data, get_viewport().canvas_transform * (hover_building.position + Vector2(32, 32)) + OFFSET * zoom_factor)
