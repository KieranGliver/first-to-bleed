extends Sprite2D

@onready var map_manager: MapManager = get_parent()

enum Direction {NORTH, EAST, SOUTH, WEST}

var large_icon: Texture2D = preload("res://Sprites/Sheets/tile_hover_large.png")
var icon: Texture2D = preload("res://Sprites/Sheets/tile_hover.png")

var large: bool = false:
	set(value):
		large = value
		if value:
			texture = large_icon
		else:
			texture = icon

var facing: Direction = Direction.NORTH:
	set(value):
		facing = value
		match (value):
			Direction.NORTH:
				rotation = 0
			Direction.EAST:
				rotation = PI / 2 
			Direction.SOUTH:
				rotation = PI
			Direction.WEST:
				rotation = -PI / 2

func _process(delta: float) -> void:
	position = Vector2(32, 32) + Vector2(map_manager.local_to_map(map_manager.to_local(get_global_mouse_position()))) * map_manager.TILE_SIZE
