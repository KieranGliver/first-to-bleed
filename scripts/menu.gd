extends Node2D

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var label = $CanvasLayer/MenuUI/ButtonContainer/Label
@onready var new_game_confirm = $CanvasLayer/MenuUI/NewGameConfirm
@onready var load_game_button = $CanvasLayer/MenuUI/ButtonContainer/Load


func _ready() -> void:
	if FileAccess.file_exists(SessionManager.LOCATION):
		SessionManager.load_session()
		load_game_button.disabled = false
		label.visible = true
		label.text  = "Day: " + str(int(SessionManager.session["day"])) + " Life: " + str(SessionManager.session["life"])


func _on_new_game_pressed() -> void:
	_on_button_press()
	if FileAccess.file_exists(SessionManager.LOCATION):
		new_game_confirm.popup_centered()
	else:
		main.switch_scene('gm')


func _on_load_pressed() -> void:
	_on_button_press()
	SessionManager.load_session()
	main.switch_scene('gm')


func _on_quit_pressed() -> void:
	_on_button_press()
	get_tree().quit()


func start_new_game():
	SessionManager.session = {
		"day": 0,
		"deck": {Data.BuildingName.HOUSE: 4, Data.BuildingName.STALL: 4},
		"life": 3.0,
		"victories": 0.0,
		"reroll": 3
	}
	SessionManager.save_session()
	main.switch_scene("gm")


func _on_new_game_confirm_confirmed() -> void:
	SoundManager.play("crash", -25)
	start_new_game()


func _on_ui_mouse_entered() -> void:
	SoundManager.play("kick", -25)


func _on_button_press():
	var hithat = ["hithat_one", "hithat_two", "hithat_three"].pick_random()
	SoundManager.play(hithat, -25)
