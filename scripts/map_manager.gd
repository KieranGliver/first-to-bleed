extends Node2D

class_name MapManager

@onready var floor_layer = $FloorLayer
@onready var claim_layer = $ClaimLayer
@onready var building_layer = $BuildingLayer
@onready var pleb_layer = $PlebLayer

@export var map_size: Vector2i = Vector2i(15, 15)

var floor_map: Array = []
var claim_map: Array = []
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

func _initialize_building_map() -> void:
	building_layer.clear()
	building_map.clear()

func _initialize_pleb_layer() -> void:
	pleb_layer.clear()

func upkeep() -> void:
	_initialize_floor_map()
	_initialize_claim_map()
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

func spawn_building(coords: Vector2i, team: int = 0, name: String = 'building') -> void:
	if not floor_map[coords.x][coords.y]:
		push_warning("Cannot place building on non-floor tile at " + str(coords))
		return
	
	if building_map.has(coords):
		push_warning("Tile already has a building at " + str(coords))
		return
	
	var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
	var building_instance = building_layer.spawn(self, tile_position, name, team)
	if building_instance:
		building_map[coords] = building_instance

func spawn_pleb(coords: Vector2, team: int = 0, quant: int = 1, name: String = 'pleb') -> void:
	for i in range(quant):
		var tile_position: Vector2 = Vector2(coords) * TILE_SIZE
		var pleb_instance = pleb_layer.spawn(self, tile_position, name, team)
