extends Node2D

class_name MapInitializer

enum Pattern {
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

var pattern_generators = {
	Pattern.FIELD: _generate_field_pattern,
	Pattern.LAKE: _generate_lake_pattern,
	Pattern.HIGHLANDS: _generate_highlands_pattern
}


func upkeep() -> void:
	_initialize_floor_map()
	_initialize_cliff_map()
	_initialize_claim_map()
	_initialize_build_map()
	_initialize_yield_map()
	_initialize_building_map()
	_initialize_pleb_layer()


func generate_map(pattern: Pattern) -> void:
	upkeep()  # Clears and resets all map layers
	
	if pattern_generators.has(pattern):
		pattern_generators[pattern].call()
	else:
		push_error("Pattern not implemented: " + str(pattern))


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


func _generate_field_pattern() -> void:
	pass


func _generate_lake_pattern() -> void:
	# Carve a big lake in the center (odd width)
	var lake_size = int(min(map_manager.map_size.x, map_manager.map_size.y) * 0.4)  # e.g., 6x6 on a 15x15
	var start = Vector2i((map_manager.map_size.x - lake_size) / 2, (map_manager.map_size.y - lake_size) / 2)
	
	for x in range(start.x, start.x + lake_size):
		for y in range(start.y, start.y + lake_size):
			map_manager.set_floor(x, y, false)  # Remove floor to make water


func _generate_highlands_pattern() -> void:
	var cliff_cells: Array[Vector2i] = []
	
	for x in range(map_manager.map_size.x):
		for y in range(map_manager.map_size.y):
			var cell = Vector2i(x, y)
			# Random chance to have a cliff, higher = more cliffs
			if randi() % 100 < 70:
				cliff_cells.append(cell)
	
	map_manager.set_cliff(cliff_cells, true)
	
	# Optional: Add sparse clearings by removing random cliff clusters
	var clearing_count := 4
	var clearing_radius := 2
	
	for i in range(clearing_count):
		var cx := randi() % map_manager.map_size.x
		var cy := randi() % map_manager.map_size.y
		for dx in range(-clearing_radius, clearing_radius + 1):
			for dy in range(-clearing_radius, clearing_radius + 1):
				var px = clamp(cx + dx, 0, map_manager.map_size.x - 1)
				var py = clamp(cy + dy, 0, map_manager.map_size.y - 1)
				map_manager.set_cliff([Vector2i(px, py)], false)
