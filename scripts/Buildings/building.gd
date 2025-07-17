extends Node2D

class_name Building

@onready var sprite: Sprite2D = $Sprite2D
@onready var projectile_spawner: Spawner = $ProjectileSpawner
@onready var overgrowth_timer: GameTimer = $OvergrowthTimer

var gm: GameManager
var map_manager: MapManager
var data: CardData
var max_health: int = 10
var team: int = 0
var current_health: int
var facing: Vector2 = Vector2.UP
var coords: Vector2i = Vector2i.ZERO
var range_bonus: int = 0
var is_overgrowth: bool = false

@export var pop_val: int = 0

func _ready() -> void:
	map_manager.update_connections(self)
	if data.keywords.has(Data.BuildingKeyword.POPULATE):
		var coords = map_manager.local_to_map(map_manager.to_local(global_position))
		map_manager.spawn_pleb(coords, team, pop_val)
	if data.keywords.has(Data.BuildingKeyword.CONCRETE):
		max_health += 5
	current_health = max_health
	_on_placed()


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


func _apply_group_effect(group: Array[Building]) -> void:
	pass


func _remove_group_effect(group: Array[Building]) -> void:
	pass


func destroy():
	_on_destroyed()
	if data.keywords.has(Data.BuildingKeyword.POPULATE):
		map_manager.destroy_pleb(team, pop_val)
	map_manager.destroy_building(self)


func take_damage(amount: int = 1) -> void:
	current_health -= amount
	if current_health <= 0:
		destroy()


func _spawn_projectile(time: float, final_position: Vector2, max_height: float):
	var pre_ready = func(pro: Projectile):
		pro.total_time = time
		pro.final_position = final_position
		pro.max_height = max_height
	projectile_spawner.spawn(map_manager, Vector2.ZERO, 'projectile', team, pre_ready)


func fire_projectiles(quant: int, radius: int, time: float = 3.0, max_height: float = 50.0):
	var coords = Vector2(map_manager.local_to_map(map_manager.to_local(global_position)))
	var arr: Array[Vector2] = []
	var d_radius = radius + range_bonus
	for dx in range(-d_radius, d_radius + 1):
		for dy in range(-d_radius, d_radius + 1):
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


func get_nearby_plebs(quant: int):
	var plebs = get_tree().get_nodes_in_group('pleb')
	var team_plebs = plebs.filter(func(pleb: Pleb): return pleb.team == team)
	team_plebs.sort_custom(func(a: Pleb, b: Pleb): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	team_plebs.resize(quant)
	return team_plebs


func overgrowth():
	if is_overgrowth:
		map_manager.spawn_yield(Vector2(0, 0), "vine")
	else:
		overgrowth_timer.start()
	is_overgrowth = not is_overgrowth


func _on_overgrowth_timer_timeout() -> void:
	is_overgrowth = false
