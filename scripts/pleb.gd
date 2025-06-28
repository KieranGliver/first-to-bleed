extends Sprite2D

class_name Pleb

@export var gm: GameManager
@export var map_manager: MapManager
@export var team: int = 0
@export_range(0, 360, 0.1, "radians_as_degrees") var angle: float = 0
@export_range(0, 128.0, 0.1) var magnitude: float = 64.0


func calculate_linear_velocity() -> Vector2:
	var x_velocity: float = magnitude * cos(angle)
	var y_velocity: float = magnitude * sin(angle)
	return Vector2(x_velocity, y_velocity)


func _ready() -> void:
	angle = deg_to_rad(randi_range(0, 360))
	frame_coords = Vector2(0, team)


func _physics_process(delta: float) -> void:
	var velocity = calculate_linear_velocity()
	var time_scaled_velocity = velocity * delta * Data.SPEED_TO_SCALE[gm.current_speed]
	var target_position = global_position + time_scaled_velocity
	
	var cur_tile := map_manager.local_to_map(map_manager.to_local(global_position))
	var next_tile := map_manager.local_to_map(map_manager.to_local(target_position))
	
	if cur_tile != next_tile:
		
		var in_bounds := (
			next_tile.x >= 0 and next_tile.x < map_manager.map_size.x and
			next_tile.y >= 0 and next_tile.y < map_manager.map_size.y
		)
		
		# Bounce off the edge or invalid floor
		if not in_bounds or not map_manager.floor_map[next_tile.y][next_tile.x]:
			bounce_from_tile(next_tile, cur_tile, velocity)
			return
		
		var building_on_tile = map_manager.building_map.has(next_tile)
		
		# Bounce off building
		if building_on_tile:
			bounce_from_tile(next_tile, cur_tile, velocity)
			var building = map_manager.building_map[next_tile]
			if building.team == team:
				building._on_touch(self)
			else:
				building._on_attack(self)
		
		var tile_owner = map_manager.claim_map[next_tile.x][next_tile.y]
		
		# Bounce off neutral and opponent tiles
		if tile_owner != team:
			bounce_from_tile(next_tile, cur_tile, velocity)
			
			if tile_owner == -1:
				map_manager.claim(next_tile, team)
				gm.add_ducats(5, team)
				gm.add_tiles(1, team)
			else:
				map_manager.claim(next_tile, -1)
				gm.add_tiles(-1, tile_owner)
			
			return
	
	# normal movement
	global_position = target_position

func bounce_from_tile(hit_tile: Vector2i, from_tile: Vector2i, velocity: Vector2) -> void:
	var offset_rad = deg_to_rad(randf_range(-15.0, 15.0))
	var normal = Vector2(from_tile - hit_tile).normalized()

	if normal != Vector2.ZERO:
		var reflected = velocity.bounce(normal)
		angle = reflected.angle() + offset_rad
