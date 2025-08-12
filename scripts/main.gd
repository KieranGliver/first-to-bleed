extends Node
class_name Main

@onready var scene_node: Node = $Scenes

@export var folder_path = "res://Scenes/"
var names: Array[String] = []
var scenes: Dictionary = {}

func _ready() -> void:
	var paths = FileExplorer.traverse_directory(folder_path, false)
	for path in paths:
		if path.get_extension().to_lower() == "remap":
			path = path.trim_suffix(".remap")
		if path.get_extension().to_lower() == "tscn":
			var scene_name = path.get_file().get_basename().to_lower()
			var packed_scene = ResourceLoader.load(path)
			if packed_scene is PackedScene:
				scenes[scene_name] = packed_scene
				names.append(scene_name)


func switch_scene(scene_name: String) -> Node:
	for child in scene_node.get_children():
		child.queue_free()
	if scenes.has(scene_name):
		var instance = scenes[scene_name].instantiate()
		scene_node.add_child(instance)
		return instance
	else:
		push_warning("Scene not found: " + scene_name)
		return null
