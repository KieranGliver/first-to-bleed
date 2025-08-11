extends Sprite2D

class_name Pleb

const FORCE_DECAY := 0.75

@export var gm: GameManager
@export var map_manager: MapManager
@export var team: int = 0
@export_range(0, 360, 0.1, "radians_as_degrees") var constant_angle: float = 0
@export_range(0, 128.0, 0.1) var constant_magnitude: float = 64.0
@export_range(0, 360, 0.1, "radians_as_degrees") var external_angle: float = 0
@export var external_magnitude: float = 0

var active_effects: Dictionary = {}

func _ready() -> void:
	constant_angle = deg_to_rad(randi_range(0, 360))
	frame_coords = Vector2(0, team)


func _physics_process(delta: float) -> void:
	if gm and gm.running:
		var velocity = calculate_linear_velocity() + calculate_external_velocity()
		var scaled_delta = delta * Data.SPEED_TO_SCALE[gm.current_speed]
		
		reduce_external_velocity(scaled_delta)
		
		for effect_name in active_effects.keys():
			active_effects[effect_name].time_left -= scaled_delta
			if active_effects[effect_name].time_left <= 0:
				active_effects.erase(effect_name)
		
		var time_scaled_velocity = velocity * scaled_delta
		var target_position = global_position + time_scaled_velocity
		
		var cur_tile := map_manager.local_to_map(map_manager.to_local(global_position))
		var next_tile := map_manager.local_to_map(map_manager.to_local(target_position))
		
		if cur_tile != next_tile:
			
			var in_bounds := (
				next_tile.x >= 0 and next_tile.x < map_manager.map_size.x and
				next_tile.y >= 0 and next_tile.y < map_manager.map_size.y
			)
			
			# Bounce off the edge, invalid floor or cliff
			if not in_bounds or not map_manager.floor_map[next_tile.y][next_tile.x] or map_manager.cliff_map[next_tile.x][next_tile.y]:
				bounce_from_tile(next_tile, cur_tile, velocity)
				return
				
			var yield_on_tile = map_manager.yield_map.has(Vector2(float(next_tile.x), float(next_tile.y)))
			
			if yield_on_tile:
				bounce_from_tile(next_tile, cur_tile, velocity)
				var y = map_manager.yield_map[Vector2(float(next_tile.x), float(next_tile.y))]
				if y:
					y._on_attack(self)
					if active_effects.has(Data.EffectName.EXPLOIT):
						y._on_attack(self)
				return
			
			var building_on_tile = map_manager.building_map.has(next_tile)
			
			# Bounce off building
			if building_on_tile:
				var building = map_manager.building_map[next_tile]
				if building.team == team:
					building._on_touch(self)
					if active_effects.has(Data.EffectName.INDUSTRIAL):
						building._on_touch(self)
				else:
					building._on_attack(self)
					if active_effects.has(Data.EffectName.EXPLOIT):
						building._on_attack(self)
				
				if not building.data.keywords.has(Data.BuildingKeyword.GHOST):
					bounce_from_tile(next_tile, cur_tile, velocity)
					return
			
			var tile_owner = map_manager.claim_map[next_tile.x][next_tile.y]
			
			# Bounce off neutral and opponent tiles
			if tile_owner != team:
				bounce_from_tile(next_tile, cur_tile, velocity)
				
				if tile_owner == -1:
					map_manager.claim(next_tile, team)
					gm.add_ducats(5, team)
				else:
					map_manager.claim(next_tile, -1)
				
				return
		
		# normal movement
		global_position = target_position


func calculate_linear_velocity() -> Vector2:
	var speed_multiplier = 1.0
	if active_effects.has(Data.EffectName.RUSH):
		match active_effects[Data.EffectName.RUSH].stack:
			1:
				speed_multiplier = 1.25
			2:
				speed_multiplier = 1.5
			3:
				speed_multiplier = 2.0
		
	return Vector2(cos(constant_angle), sin(constant_angle)) * constant_magnitude * speed_multiplier


func bounce_from_tile(hit_tile: Vector2i, from_tile: Vector2i, velocity: Vector2) -> void:
	var offset_rad = deg_to_rad(randf_range(-15.0, 15.0))
	var normal = Vector2(from_tile - hit_tile).normalized()
	
	if normal != Vector2.ZERO:
		# Reflect main movement direction
		var reflected = velocity.bounce(normal)
		constant_angle = reflected.angle() + offset_rad
	
		# Reflect external force
		if external_magnitude > 0:
			var external_velocity = calculate_external_velocity()
			var external_reflected = external_velocity.bounce(normal)
			external_angle = external_reflected.angle()
			external_magnitude = external_magnitude * 0.90
	
	gm.add_bounce(1, team)
	
	if (team == 0):
		SoundManager.play("snare", -30)


func calculate_external_velocity() -> Vector2:
	return Vector2(cos(external_angle), sin(external_angle)) * external_magnitude


func reduce_external_velocity(delta: float) -> void:
	external_magnitude -= external_magnitude * FORCE_DECAY * delta
	if external_magnitude <= constant_magnitude:
		external_magnitude = 0


func apply_impulse(dir: float, mag: float):
	var current = Vector2(cos(external_angle), sin(external_angle)) * external_magnitude
	var impulse = Vector2(cos(dir), sin(dir)) * mag
	
	var result = current + impulse
	external_magnitude = result.length()
	
	external_angle = result.angle()


func apply_effect(effect_name: Data.EffectName, duration: float):
	if active_effects.has(effect_name):
		active_effects[effect_name].time_left = max(active_effects[effect_name].time_left, duration)
		if effect_name == Data.EffectName.RUSH:
			active_effects[effect_name].stack = min(3, active_effects[effect_name].stack + 1)
	else:
		active_effects[effect_name] = {
			"time_left": duration,
			"stack": 1
		}
	print('applied effect')


func detonate():
	queue_free()
