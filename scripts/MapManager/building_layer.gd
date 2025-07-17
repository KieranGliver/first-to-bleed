extends Node2D

var game
const FOLDER_PATH = "res://Scenes/buildings/"
var names: Array[String] = []
var building_scenes: Dictionary = {}

func _ready() -> void:
	gm = get_tree().get_first_node_in_group('game_manager')
	var building_paths = FileExplorer.traverse_directory(BUILDING_FOLDER_PATH)
	for path in building_paths:
		if path.get_extension().to_lower() == "tscn":
			var scene_name = path.get_file().get_basename().to_lower()
			var packed_scene = ResourceLoader.load(path)
			if packed_scene is PackedScene:
				building_scenes[scene_name] = packed_scene
				building_names.append(scene_name)

func spawn(scene_name: String, position: Vector2, team: int = 0) -> Node:
	if building_scenes.has(scene_name):
		var instance = building_scenes[scene_name].instantiate()
		instance.global_position = position
		instance.team = team
		instance.
		add_child(instance)
		return instance
	else:
		push_warning("Building scene not found: " + scene_name)
		return null

func clear():
	for child in get_children():
		child.queue_free()
