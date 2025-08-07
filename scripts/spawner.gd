extends Node2D

class_name Spawner

@onready var gm : GameManager = get_tree().get_first_node_in_group('game_manager')
@export var folder_path = "res://Scenes/"
var names: Array[String] = []
var scenes: Dictionary = {}

func _ready() -> void:
	var paths = FileExplorer.traverse_directory(folder_path)
	for path in paths:
		if path.get_extension().to_lower() == "tscn":
			var scene_name = path.get_file().get_basename().to_lower()
			var packed_scene = ResourceLoader.load(path)
			if packed_scene is PackedScene:
				scenes[scene_name] = packed_scene
				names.append(scene_name)


func spawn(map_manager: MapManager, local_pos: Vector2, scene_name: String, team: int = 0, pre_ready: Callable = func(_n: Node): return ) -> Node:
	if scenes.has(scene_name):
		var instance = scenes[scene_name].instantiate()
		instance.global_position = local_pos
		var props : Array[Dictionary] = instance.get_property_list()
		var prop_names = props.map(func(el): return str(el.name))
		if prop_names.has("team"):
			instance.team = team
		if prop_names.has("map_manager"):
			instance.map_manager = map_manager
		if prop_names.has("gm"):
			instance.gm = gm
		pre_ready.call(instance)
		add_child(instance)
		return instance
	else:
		push_warning("Scene not found: " + scene_name)
		return null

func clear():
	for child in get_children():
		child.queue_free()
