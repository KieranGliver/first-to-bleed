extends Node2D

class_name MapManager

@onready var floor_layer = $FloorLayer
@onready var claim_layer = $ClaimLayer
@onready var building_layer = $BuildingLayer
@onready var pleb_layer = $PlebLayer
@onready var build_cursor = $BuildCursor

@export var map_size: Vector2i = Vector2i(15, 15)

var floor_map: Array = []
var claim_map: Array = []
var build_map: Array = []
var building_map: Dictionary = {}

const TILE_SIZE = 64

func _ready():
	upkeep()

func _initialize_floor_map() -> void:
	floor_layer.clear()
	floor_map.clear()
	for y in range(map_size.y):
		var row := []
		for x in range(map_size.x):
			var tile_coords = Vector2i(x, y)
			row.append(true) 
			floor_layer.set_cell(tile_coords, 0, Vector2(0, 0))
		floor_map.append(row)

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

func _initialize_building_map() -> void:
	building_layer.clear()
	building_map.clear()

func _initialize_pleb_layer() -> void:
	pleb_layer.clear()

func upkeep() -> void:
	_initialize_floor_map()
	_initialize_claim_map()
	_initialize_build_map()
	_initialize_building_map()
	_initialize_pleb_layer()
	


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
	var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
	var pre_ready = func(building: Building):
		building.keywords = card_data.keywords
		building.building_name = card_data.building_name
		building.rarity = card_data.rarity
		match(build_cursor.facing):
			0:
				building.facing = Vector2.UP
			1:
				building.facing = Vector2.RIGHT
			2:
				building.facing = Vector2.DOWN
			3:
				building.facing = Vector2.LEFT
	
	var building_instance = building_layer.spawn(self, tile_position, Data.BUILDING_NAME_TO_STRING[card_data.building_name], team, pre_ready)
	
	var radius = 0 if card_data.keywords.has(Data.BuildingKeyword.ZONED) else 1
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var t_coords = Vector2(clamp(coords.x + dx, 0, map_size.x), clamp(coords.y + dy, 0, map_size.y))
			build_map[t_coords.x][t_coords.y] = false
	
	if building_instance:
		building_map[coords] = building_instance

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
	# Get the coords from the building map using building
	var coords = building_map.keys().find(func (pos): return building_map[pos] == building)
	
	if coords == null:
		push_error("Building not found in building_map")
		return
		
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var t_coords = Vector2(clamp(coords.x + dx, 0, map_size.x), clamp(coords.y + dy, 0, map_size.y))
			var neighbours = get_buildings_radius(t_coords, 1)
			var res = true
			for n in neighbours:
				if not n.keywords.has(Data.BuildingKeyword.ZONED):
					res = false
			build_map[t_coords.x][t_coords.y] = res
	
	building.queue_free()

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
