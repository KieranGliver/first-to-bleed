extends Node2D

class_name Building

@onready var sprite: Sprite2D = $Sprite2D
@onready var projectile_spawner: Spawner = $ProjectileSpawner

var gm: GameManager
var map_manager: MapManager
var keywords: Array[Data.BuildingKeyword]
var rarity: Data.Rarity
var building_name: Data.BuildingName
var max_health: int = 10
var team: int = 0
var current_health: int
var facing: Vector2 = Vector2.UP

@export var pop_val: int = 0

func _ready() -> void:
	if keywords.has(Data.BuildingKeyword.POPULATE):
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

func _spawn_projectile(time: float, final_position: Vector2, max_height: float):
	var pre_ready = func(pro: Projectile):
		pro.total_time = time
		pro.final_position = final_position
		pro.max_height = max_height
	projectile_spawner.spawn(map_manager, Vector2.ZERO, 'projectile', team, pre_ready)


func fire_projectiles(quant: int, radius: int, time: float = 3.0, max_height: float = 50.0):
	var coords = Vector2(map_manager.local_to_map(map_manager.to_local(global_position)))
	var arr: Array[Vector2] = []
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var new_coords = Vector2(coords.x + dx, coords.y + dy)
			if 0 <= new_coords.x and new_coords.x < map_manager.map_size.x and 0 <= new_coords.y and new_coords.y < map_manager.map_size.y:
				if map_manager.claim_map[new_coords.x][new_coords.y] != team and map_manager.floor_map[new_coords.x][new_coords.y]:
					arr.append(Vector2(new_coords.x, new_coords.y))
	if arr.size() > 0:
		for i in range(quant):
			var pos = arr.pick_random()
			arr.erase(pos)
			_spawn_projectile(time, (pos - coords) * map_manager.TILE_SIZE, max_height)
			if arr.size() == 0:
				return


func _on_placed() -> void:
	pass


func _on_touch(pleb: Pleb) -> void:
	pass


func _on_attack(pleb: Node) -> void:
	take_damage()


func _on_destroyed() -> void:
	pass


func _on_timer_timeout() -> void:
	pass
