extends Node2D

class_name MapInitializer

enum PatternNum {
	FIELD,
	LAKE,
	MAZE,
	HIGHLANDS,
	SWAMP,
	WASTELAND,
	FORTRESS,
	DEATHMATCH,
	HILL
}

@onready var map_manager: MapManager = $".."
@onready var map: Map = $"../Map"
@onready var terrain_patterns: Array[Pattern] = [
	$Field, 
	$Lake, 
	$Maze, 
	$Highlands, 
	$Swamp, 
	$Wasteland, 
	$Fortress, 
	$DeathMatch, 
	$Hill
]


func upkeep() -> void:
	_initialize_floor_map()
	_initialize_cliff_map()
	_initialize_claim_map()
	_initialize_build_map()
	_initialize_yield_map()
	_initialize_building_map()
	_initialize_pleb_layer()


func generate_map(pattern: PatternNum) -> void:
	upkeep()  # Clears and resets all map layers
	terrain_patterns[pattern].initalize()


func _initialize_floor_map() -> void:
	map.floor_layer.clear()
	map_manager.floor_map.clear()
	for y in range(map_manager.map_size.y):
		var row := []
		for x in range(map_manager.map_size.x):
			var tile_coords = Vector2i(x, y)
			row.append(true)
			map.floor_layer.set_cell(tile_coords, 0, Vector2(0,0))
		map_manager.floor_map.append(row)


func _initialize_cliff_map() -> void:
	map.cliff_layer.clear()
	map_manager.cliff_map.clear()
	for y in range(map_manager.map_size.y):
		var row := []
		for x in range(map_manager.map_size.x):
			row.append(false)
		map_manager.cliff_map.append(row)


func _initialize_claim_map() -> void:
	map.claim_layer.clear()
	map_manager.claim_map.clear()
	for y in range(map_manager.map_size.y):
		var row := []
		for x in range(map_manager.map_size.x):
			row.append(-1)
		map_manager.claim_map.append(row)


func _initialize_build_map() -> void:
	map_manager.build_map.clear()
	for y in range(map_manager.map_size.y):
		var row := []
		for x in range(map_manager.map_size.x):
			row.append(true)
		map_manager.build_map.append(row)


func _initialize_yield_map() -> void:
	map_manager.yield_map.clear()
	map.yield_layer.clear()


func _initialize_building_map() -> void:
	map.building_layer.clear()
	map_manager.building_map.clear()


func _initialize_pleb_layer() -> void:
	map.pleb_layer.clear()
