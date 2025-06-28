extends Node2D

class_name Building


@onready var sprite: Sprite2D = $Sprite2D

@export var gm: GameManager
@export var map_manager: MapManager
@export var team: int = 0
@export var max_health: int = 10
@export var building_name: Data.BuildingName
@export var rarity: Data.Rarity

var current_health: int

func _ready() -> void:
	current_health = max_health
	_on_placed()

func take_damage(amount: int = 1) -> void:
	current_health -= amount
	if current_health <= 0:
		_on_destroyed()
		queue_free()

func _on_placed() -> void:
	pass

func _on_touch(pleb: Pleb) -> void:
	pass

func _on_attack(pleb: Node) -> void:
	take_damage()

func _on_destroyed() -> void:
	pass
