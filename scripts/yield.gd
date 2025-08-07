extends Node2D

class_name Yield

@onready var sprite: Sprite2D = $Sprite2D

var gm: GameManager
var map_manager: MapManager
var yield_name: Data.YieldName

@export var max_health: int = 5
@export var gold: Array[int] = []
@export var wood: Array[int] = []
@export var stone: Array[int] = []

var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int = 1) -> void:
	current_health -= amount
	sprite.frame_coords = Vector2(min(sprite.frame_coords.x+1, sprite.hframes - 1), sprite.frame_coords.y)
	if current_health <= 0:
		map_manager.destroy_yield(self)

func _on_attack(_pleb: Node) -> void:
	var i = max_health - current_health
	if gold.size() > i:
		gm.add_ducats(gold[i])
	if wood.size() > i:
		gm.add_wood(wood[i])
	if stone.size() > i:
		gm.add_wood(stone[i])
	take_damage()
