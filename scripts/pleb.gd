extends Sprite2D

class_name Pleb

const FORCE_DECAY := 50.0
const MIN_FORCE_THRESHOLD := 0.5
const ANGLE_EPSILON := 0.01  

@export var gm: GameManager
@export var map_manager: MapManager
@export var team: int = 0
@export_range(0, 360, 0.1, "radians_as_degrees") var angle: float = 0
@export_range(0, 128.0, 0.1) var magnitude: float = 64.0

var external_forces: Dictionary = {}


func _ready() -> void:
	angle = deg_to_rad(randi_range(0, 360))
	frame_coords = Vector2(0, team)


func _physics_process(delta: float) -> void:
	var velocity = calculate_linear_velocity() + calculate_external_velocity()
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
			var building = map_manager.building_map[next_tile]
			if not building.keywords.has(Data.BuildingKeyword.GHOST):
				bounce_from_tile(next_tile, cur_tile, velocity)
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

func calculate_linear_velocity() -> Vector2:
	return Vector2(cos(angle), sin(angle)) * magnitude

func bounce_from_tile(hit_tile: Vector2i, from_tile: Vector2i, velocity: Vector2) -> void:
	var offset_rad = deg_to_rad(randf_range(-15.0, 15.0))
	var normal = Vector2(from_tile - hit_tile).normalized()

	if normal != Vector2.ZERO:
		# Reflect main movement direction
		var reflected = velocity.bounce(normal)
		angle = reflected.angle() + offset_rad

		# Bounce and decay external forces
		var updated_forces: Dictionary = {}
		for dir_str in external_forces.keys():
			var dir = str_to_vec(dir_str)
			var mag = external_forces[dir_str]

			# Reflect the direction
			var bounced_dir = dir.bounce(normal).normalized()
			var bounced_mag = mag * 0.5  # decay by 50% on bounce

			# Skip weak results
			if bounced_mag < MIN_FORCE_THRESHOLD:
				continue

			var bounced_str = vec_to_str(bounced_dir)
			updated_forces[bounced_str] = bounced_mag

		external_forces = updated_forces


func detonate():
	queue_free()


func calculate_external_velocity() -> Vector2:
	var total_velocity := Vector2.ZERO
	var keys_to_remove := []
	
	for dir_str in external_forces.keys():
		var dir = str_to_vec(dir_str)
		var mag = external_forces[dir_str]
		
		total_velocity += dir * mag
		mag = max(mag - FORCE_DECAY * get_physics_process_delta_time(), 0)
		
		if mag < MIN_FORCE_THRESHOLD:
			keys_to_remove.append(dir_str)
		else:
			external_forces[dir_str] = mag
	
	for key in keys_to_remove:
		external_forces.erase(key)
	
	return total_velocity

func apply_force(direction: Vector2, magnitude: float) -> void:
	if direction == Vector2.ZERO:
		return
	
	var dir_normalized = direction.normalized()
	var dir_key = vec_to_str(dir_normalized)

	# Combine forces in same direction (fuzzy merge)
	for key in external_forces.keys():
		var existing_dir = str_to_vec(key)
		if existing_dir.angle_to(dir_normalized) < ANGLE_EPSILON:
			external_forces[key] += magnitude
			return
	
	# New force
	if external_forces.has(dir_key):
		external_forces[dir_key] += magnitude
	else:
		external_forces[dir_key] = magnitude

# Vector serialization helpers
func vec_to_str(v: Vector2) -> String:
	return "%f,%f" % [v.x, v.y]

func str_to_vec(s: String) -> Vector2:
	var parts = s.split(",")
	return Vector2(parts[0].to_float(), parts[1].to_float())
