extends Node2D

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var new_game_confirm = $CanvasLayer/MenuUI/NewGameConfirm
@onready var load_game_button = $CanvasLayer/MenuUI/ButtonContainer/Load


func _ready() -> void:
	if FileAccess.file_exists(SessionManager.LOCATION):
		load_game_button.disabled = false


func _on_new_game_pressed() -> void:
	if FileAccess.file_exists(SessionManager.LOCATION):
		new_game_confirm.popup_centered()
	else:
		main.switch_scene('gm')


func _on_load_pressed() -> void:
	SessionManager.load_session()
	main.switch_scene('gm')


func _on_encyclopedia_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func start_new_game():
	SessionManager.session = {
		"day": 0,
		"deck": {Data.BuildingName.HOUSE: 4, Data.BuildingName.STALL: 4},
		"life": 3.0,
		"victories": 0.0
	}
	SessionManager.save_session()
	main.switch_scene("gm")


func _on_new_game_confirm_confirmed() -> void:
	start_new_game()
