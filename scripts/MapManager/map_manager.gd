extends Node2D

class_name MapManager

signal claim_tile(from: int, to: int)

@onready var initializer: MapInitializer = $MapInitializer
@onready var map: Map = $Map
@onready var build_cursor = $BuildCursor

@export var map_size: Vector2i = Vector2i(17, 17)

var hq = ResourceLoader.load("res://Cards/hq.tres")
var floor_map: Array = []
var cliff_map: Array = []
var claim_map: Array = []
var build_map: Array = []
var building_map: Dictionary = {}
var yield_map: Dictionary = {}

var building_groups: Dictionary = {}

const TILE_SIZE = 64

signal building_placed(building: Building)

func init_map(pattern: int):
	initializer.generate_map(pattern)

func map_to_local(map_coords: Vector2i) -> Vector2:
	return Vector2(map_coords.x * TILE_SIZE + TILE_SIZE / 2, map_coords.y * TILE_SIZE + TILE_SIZE / 2)

func local_to_map(local_pos: Vector2) -> Vector2i:
	var grid_x := int(floor(local_pos.x / TILE_SIZE))
	var grid_y := int(floor(local_pos.y / TILE_SIZE))
	
	return Vector2i(grid_x, grid_y)


func claim(coords: Vector2i, team: int = -1) -> void:
	var from = claim_map[coords.x][coords.y]
	claim_map[coords.x][coords.y] = team
	if team == -1:
		map.claim_layer.set_cell(coords) # Removes cell from tilemap
	else:
		map.claim_layer.set_cell(coords, 0, Vector2(team, 0))
	claim_tile.emit(from, team)


func spawn_building(coords: Vector2i, card_data: CardData, team: int = 0) -> Building:
	if building_map.keys().has(coords):
		building_map.erase(coords)
	var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
	var pre_ready = func(building: Building):
		building.coords = coords
		building.data = card_data
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
	
	var building_instance = map.building_layer.spawn(self, tile_position, Data.BUILDING_NAME_TO_STRING[card_data.building_name], team, pre_ready)
	
	var radius = 0 if card_data.keywords.has(Data.BuildingKeyword.ZONED) else 1
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var t_coords = Vector2i(clamp(coords.x + dx, 0, map_size.x - 1), clamp(coords.y + dy, 0, map_size.y - 1))
			build_map[t_coords.x][t_coords.y] = false
	
	if not floor_map[coords.x][coords.y]:
		floor_map[coords.x][coords.y] = true
	
	building_placed.emit(building_instance)
	return building_instance


func spawn_yield(coords: Vector2, yield_name: String = 'yield') -> void:
	if yield_map.keys().has(coords):
		yield_map[coords].queue_free()
		yield_map.erase(coords)
	var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
	var yield_instance = map.yield_layer.spawn(self, tile_position, yield_name)
	if yield_instance:
		yield_map[coords] = yield_instance


func spawn_pleb(coords: Vector2, team: int = 0, quant: int = 1, pleb_name: String = 'pleb') -> void:
	for i in range(quant):
		var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
		var pleb_instance = map.pleb_layer.spawn(self, tile_position, pleb_name, team)


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
	var radius = 0 if building.data.keywords.has(Data.BuildingKeyword.ZONED) else 0
	
	var coords = building.coords
	
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var t_coords = Vector2(clamp(coords.x + dx, 0, map_size.x), clamp(coords.y + dy, 0, map_size.y))
			var neighbours = get_buildings_radius(t_coords, 1)
			var res = true
			for n in neighbours:
				if not n.data.keywords.has(Data.BuildingKeyword.ZONED):
					res = false
			build_map[t_coords.x][t_coords.y] = res
	
	# If the building was placed on water turn floor back to water
	if building.data.keywords.has(Data.BuildingKeyword.WATER):
		floor_map[coords.x][coords.y] = false
	update_connections(building, true)
	building_map.erase(coords)
	building.queue_free()


func destroy_yield(y: Yield) -> void:
	var coords = yield_map.keys().filter(func (pos): return yield_map[Vector2(float(pos.x), float(pos.y))] == y).pop_back()
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
			map.floor_layer.set_cell(Vector2i(x, y), 0, Vector2(0, 0))  # Your floor tile
		else:
			map.floor_layer.erase_cell(Vector2i(x, y))  # No floor = water


func set_cliff(cells: Array[Vector2i], is_cliff: bool) -> void:
	var ref = cells.filter(func(cell): return cell.x >= 0 and cell.y >= 0 and cell.x < map_size.x and cell.y < map_size.y)
	for cell in ref:
		cliff_map[cell.x][cell.y] = is_cliff
		
	if is_cliff:
		map.cliff_layer.set_cells_terrain_connect(ref, 0, 0)
	else:
		for cell in ref:
			map.cliff_layer.erase_cell(cell)


func update_connections(building: Building, is_removal: bool = false):
	if is_removal:
		_remove_building_from_group(building)
	else:
		_add_building_to_group(building)


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


func init_team(team: int, coords: Vector2i) -> void:
	var radius := 1  
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var pos := coords + Vector2i(dx, dy)
			if pos.x < 0 or pos.y < 0 or pos.x >= map_size.x or pos.y >= map_size.y:
				continue
			
			
			set_floor(pos.x, pos.y, true)
			set_cliff([pos], false)
			
			
			if yield_map.has(pos):
				var y = yield_map[pos]
				destroy_yield(y)
			
			
			claim(pos, team)
	
	
	spawn_building(coords, hq, team)
