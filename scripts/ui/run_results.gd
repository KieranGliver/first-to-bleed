extends Node2D

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var title = $CanvasLayer/UI/VBoxContainer/Title
@onready var stats = $CanvasLayer/UI/VBoxContainer/Stats
@onready var deck_viewer = $CanvasLayer/UI/DeckViewer
@onready var session = SessionManager.session


func _ready():
	SessionManager.delete_session()
	if session["life"] <= 0:
		title.text = "YOU LOSE!"
	deck_viewer.update(session["deck"])
	stats.text = 'Life: ' + str(SessionManager.session["life"]) + ' Crowns: ' + str(SessionManager.session["crown"])


func _on_view_deck_pressed() -> void:
	deck_viewer.visible = not deck_viewer.visible


func _on_quit_pressed() -> void:
	main.switch_scene("menu")
