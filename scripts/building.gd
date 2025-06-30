extends Node2D

class_name Building

@onready var sprite: Sprite2D = $Sprite2D

var gm: GameManager
var map_manager: MapManager
var keywords: Array[Data.BuildingKeyword]
var rarity: Data.Rarity
var building_name: Data.BuildingName
var max_health: int = 10
var team: int = 0

@export var pop_val: int = 0

var current_health: int
var facing: Vector2 = Vector2.UP

func _ready() -> void:
	current_health = max_health
	for key in keywords:
		print(str(key))
	if keywords.has(Data.BuildingKeyword.POPULATE):
		print('spawn')
		var coords = map_manager.local_to_map(map_manager.to_local(global_position))
		map_manager.spawn_pleb(coords, team, pop_val)
	if keywords.has(Data.BuildingKeyword.CONCRETE):
		max_health += 5
	current_health = max_health
	_on_placed()

func take_damage(amount: int = 1) -> void:
	current_health -= amount
	if current_health <= 0:
		_on_destroyed()
		if keywords.has(Data.BuildingKeyword.POPULATE):
			map_manager.destroy_pleb(team, pop_val)
		map_manager.destroy_building(self)

func _on_placed() -> void:
	pass

func _on_touch(pleb: Pleb) -> void:
	pass

func _on_attack(pleb: Node) -> void:
	take_damage()

func _on_destroyed() -> void:
	pass
