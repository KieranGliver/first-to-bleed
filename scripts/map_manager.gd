extends Node2D

class_name MapManager

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

@onready var floor_layer = $FloorLayer
@onready var claim_layer = $ClaimLayer
@onready var building_layer = $BuildingLayer
@onready var cliff_layer = $CliffLayer
@onready var yield_layer = $YieldLayer
@onready var pleb_layer = $PlebLayer
@onready var build_cursor = $BuildCursor

@export var map_size: Vector2i = Vector2i(15, 15)

var floor_map: Array = []
var cliff_map: Array = []
var claim_map: Array = []
var build_map: Array = []
var building_map: Dictionary = {}
var yield_map: Dictionary = {}
var pattern_generators = {
	Pattern.FIELD: _generate_field_pattern,
	Pattern.LAKE: _generate_lake_pattern,
	Pattern.HIGHLANDS: _generate_highlands_pattern
}
var building_groups: Dictionary = {}

const TILE_SIZE = 64

signal building_placed(building: Building)

func _initialize_floor_map() -> void:
	floor_layer.clear()
	floor_map.clear()
	for y in range(map_size.y):
		var row := []
		for x in range(map_size.x):
			var tile_coords = Vector2i(x, y)
			row.append(true)
			floor_layer.set_cell(tile_coords, 0, Vector2(0,0))
		floor_map.append(row)


func _initialize_cliff_map() -> void:
	cliff_layer.clear()
	cliff_map.clear()
	for y in range(map_size.y):
		var row := []
		for x in range(map_size.x):
			row.append(false)
		cliff_map.append(row)


func _initialize_claim_map() -> void:
	claim_layer.clear()
	claim_map.clear()
	for y in range(map_size.y):
		var row := []
		for x in range(map_size.x):
			row.append(-1)
		claim_map.append(row)


func _initialize_build_map() -> void:
	build_map.clear()
	for y in range(map_size.y):
		var row := []
		for x in range(map_size.x):
			row.append(true)
		build_map.append(row)


func _initialize_yield_map() -> void:
	yield_map.clear()
	yield_layer.clear()


func _initialize_building_map() -> void:
	building_layer.clear()
	building_map.clear()


func _initialize_pleb_layer() -> void:
	pleb_layer.clear()


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


func local_to_map(local_pos: Vector2) -> Vector2i:
	var grid_x := int(floor(local_pos.x / TILE_SIZE))
	var grid_y := int(floor(local_pos.y / TILE_SIZE))
	
	return Vector2i(grid_x, grid_y)


func claim(coords: Vector2i, team: int = -1) -> void:
	claim_map[coords.x][coords.y] = team
	if team == -1:
		claim_layer.set_cell(coords) # Removes cell from tilemap
	else:
		claim_layer.set_cell(coords, 0, Vector2(team, 0))


func spawn_building(coords: Vector2i, card_data: CardData, team: int = 0) -> void:
	if building_map.keys().has(coords):
		building_map.erase(coords)
	var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
	var pre_ready = func(building: Building):
		building.keywords = card_data.keywords
		building.building_name = card_data.building_name
		building.rarity = card_data.rarity
		building.coords = coords
		match(build_cursor.facing):
			0:
				building.facing = Vector2.UP
			1:
				building.facing = Vector2.RIGHT
			2:
				building.facing = Vector2.DOWN
			3:
				building.facing = Vector2.LEFT
		building_map[coords] = building
	
	var building_instance = building_layer.spawn(self, tile_position, Data.BUILDING_NAME_TO_STRING[card_data.building_name], team, pre_ready)
	
	var radius = 0 if card_data.keywords.has(Data.BuildingKeyword.ZONED) else 1
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var t_coords = Vector2i(clamp(coords.x + dx, 0, map_size.x - 1), clamp(coords.y + dy, 0, map_size.y - 1))
			build_map[t_coords.x][t_coords.y] = false
	
	if not floor_map[coords.x][coords.y]:
		floor_map[coords.x][coords.y] = true
	
	building_placed.emit(building_instance)


func spawn_yield(coords: Vector2, name: String = 'yield') -> void:
	if yield_map.keys().has(coords):
		yield_map.erase(coords)
	var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
	var yield_instance = yield_layer.spawn(self, tile_position, name)
	if yield_instance:
		yield_map[coords] = yield_instance


func spawn_pleb(coords: Vector2, team: int = 0, quant: int = 1, name: String = 'pleb') -> void:
	for i in range(quant):
		var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
		var pleb_instance = pleb_layer.spawn(self, tile_position, name, team)


func destroy_pleb(team: int = 0, quant: int = 1, _name: String = 'pleb') -> void:
	var plebs = get_tree().get_nodes_in_group('pleb')
	var i = 0
	for pleb in plebs:
		if i >= quant:
			return
		if pleb.team == team:
			pleb.detonate()
			i += 1
	push_warning("Failed to destroy plebs on team " + str(team))


func destroy_building(building: Building) -> void:
	var radius = 0 if building.keywords.has(Data.BuildingKeyword.ZONED) else 0

	var coords = building.coords
	
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var t_coords = Vector2(clamp(coords.x + dx, 0, map_size.x), clamp(coords.y + dy, 0, map_size.y))
			var neighbours = get_buildings_radius(t_coords, 1)
			var res = true
			for n in neighbours:
				if not n.keywords.has(Data.BuildingKeyword.ZONED):
					res = false
			build_map[t_coords.x][t_coords.y] = res
	
	# If the building was placed on water turn floor back to water
	if building.keywords.has(Data.BuildingKeyword.WATER):
		floor_map[coords.x][coords.y] = false
	update_connections(building, true)
	building_map.erase(coords)
	building.queue_free()


func destroy_yield(y: Yield) -> void:
	var coords = yield_map.keys().find(func (pos): return yield_map[pos] == y)
	yield_map.erase(coords)
	y.queue_free()


func get_buildings_radius(coords: Vector2i = Vector2i.ZERO, radius: int = -1) -> Array[Building]:
	var buildings: Array[Building] = []
	
	if radius < 0:
		# Return all buildings if radius is negative
		for building in building_map.values():
			buildings.append(building)
		return buildings

	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var pos = coords + Vector2i(dx, dy)
			if building_map.has(pos):
				buildings.append(building_map[pos])

	return buildings


func set_floor(x: int, y: int, is_floor: bool) -> void:
	if x >= 0 and y >= 0 and x < map_size.x and y < map_size.y:
		floor_map[x][y] = is_floor
		if is_floor:
			floor_layer.set_cell(Vector2i(x, y), 0, Vector2(0, 0))  # Your floor tile
		else:
			floor_layer.erase_cell(Vector2i(x, y))  # No floor = water


func set_cliff(cells: Array[Vector2i], is_cliff: bool) -> void:
	var ref = cells.filter(func(cell): return cell.x >= 0 and cell.y >= 0 and cell.x < map_size.x and cell.y < map_size.y)
	for cell in ref:
		cliff_map[cell.x][cell.y] = is_cliff
		
	if is_cliff:
		cliff_layer.set_cells_terrain_connect(ref, 0, 0)
	else:
		for cell in ref:
			cliff_layer.erase_cell(cell)


func _generate_field_pattern() -> void:
	pass


func _generate_lake_pattern() -> void:
	# Carve a big lake in the center (odd width)
	var lake_size = int(min(map_size.x, map_size.y) * 0.4)  # e.g., 6x6 on a 15x15
	var start = Vector2i((map_size.x - lake_size) / 2, (map_size.y - lake_size) / 2)
	
	for x in range(start.x, start.x + lake_size):
		for y in range(start.y, start.y + lake_size):
			set_floor(x, y, false)  # Remove floor to make water


func _generate_highlands_pattern() -> void:
	var cliff_cells: Array[Vector2i] = []
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell = Vector2i(x, y)
			# Random chance to have a cliff, higher = more cliffs
			if randi() % 100 < 70:
				cliff_cells.append(cell)
	
	set_cliff(cliff_cells, true)
	
	# Optional: Add sparse clearings by removing random cliff clusters
	var clearing_count := 4
	var clearing_radius := 2
	
	for i in range(clearing_count):
		var cx := randi() % map_size.x
		var cy := randi() % map_size.y
		for dx in range(-clearing_radius, clearing_radius + 1):
			for dy in range(-clearing_radius, clearing_radius + 1):
				var px = clamp(cx + dx, 0, map_size.x - 1)
				var py = clamp(cy + dy, 0, map_size.y - 1)
				set_cliff([Vector2i(px, py)], false)


func update_connections(building: Building, is_removal: bool = false):
	if is_removal:
		_remove_building_from_group(building)
	else:
		_add_building_to_group(building)
	print_building_groups_debug()


func _add_building_to_group(building: Building):
	var coords = building.coords
	
	var connected_groups: Array = []
	
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbour_coords = coords + offset
		if building_map.has(neighbour_coords):
			var neighbour = building_map[neighbour_coords]
			if building_groups.has(neighbour):
				var group = building_groups[neighbour]
				if not connected_groups.has(group):
					connected_groups.append(group)
	
	var new_group: Array[Building] = [building]
	
	for group in connected_groups:
		for b in group:
			if not new_group.has(b):
				new_group.append(b)
	
	for b in new_group:
		building_groups[b] = new_group
	
	for b in new_group:
		b._apply_group_effect(new_group)


func _remove_building_from_group(building: Building) -> void:
	var old_group = building_groups[building]
	for b in old_group:
		b._remove_group_effect(old_group)
	old_group.erase(building)
	building_groups.erase(building)
	var coords = building.coords
	
	var visited: Array[Building] = []
	var subgroups: Array = []

	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbor_coords = coords + offset
		if building_map.has(neighbor_coords):
			var neighbor = building_map[neighbor_coords]
			if not visited.has(neighbor):
				var subgroup = _flood_fill_group(neighbor, visited)
				subgroups.append(subgroup)
	
	for group in subgroups:
		for b in group:
			building_groups[b] = group
	
	for group in subgroups:
		for b in group:
			b._apply_group_effect(group)


func _flood_fill_group(start: Building, visited: Array[Building]) -> Array[Building]:
	var group: Array[Building] = []
	var queue: Array[Building] = [start]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		if visited.has(current):
			continue
		visited.append(current)
		group.append(current)
		
		var coords = current.coords
		
		for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor_coords = coords + offset
			if building_map.has(neighbor_coords):
				var neighbor = building_map[neighbor_coords]
				if not visited.has(neighbor):
					queue.append(neighbor)
	
	return group


func print_building_groups_debug() -> void:
	print("==== BUILDING GROUP DEBUG ====")
	var printed_groups: Array = []
	var group_index := 0
	
	for group in building_groups.values():
		# Avoid printing duplicate groups (since multiple keys may point to the same Array)
		if printed_groups.has(group):
			continue
		printed_groups.append(group)
		
		print("\nGroup %d:" % group_index)
		group_index += 1
		
		for building in group:
			var label = "[%s] (%s) at %s" % [
				building.building_name,
				building.get_class(),
				str(building.coords)
			]
			print("  - " + label)
