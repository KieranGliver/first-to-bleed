extends CharacterBody2D

class_name Pleb

@export var claims: TileMapLayer
@export var team: int = 0
@export_range(0, 360, 0.1, "radians_as_degrees") var angle: float = 0
@export_range(0, 128.0, 0.1) var magnitude: float = 0.0

@onready var sprite = $Sprite2D
## Calculates linear velocity components from angle and magnitude.
##
## Returns a Vector2 with x and y components in pixels per second
## based on the given angle (in radians) and magnitude.
func calculate_linear_velocity() -> Vector2:
	var x_velocity: float = magnitude * cos(angle)
	var y_velocity: float = magnitude * sin(angle)
	return Vector2(x_velocity, y_velocity)


func _ready() -> void:
	angle = deg_to_rad(randi_range(0, 360))
	sprite.frame_coords = Vector2(0, team)


func _physics_process(delta: float) -> void:
	var velocity = calculate_linear_velocity()
	var target_position = global_position + velocity * delta
	
	var previous_tile_coords = claims.local_to_map(claims.to_local(global_position))
	var new_tile_coords = claims.local_to_map(claims.to_local(target_position))
	var cell_data = claims.get_cell_tile_data(new_tile_coords)
	var offset_rad = deg_to_rad(randf_range(-15.0, 15.0))
	if cell_data:
		var owner_team = cell_data.get_custom_data("owner")
		if owner_team != team:
			var normal = previous_tile_coords - new_tile_coords
			var reflected_velocity = velocity.bounce(normal)
			angle = reflected_velocity.angle() + offset_rad
			if owner_team != -1:
				claims.set_cell(new_tile_coords, 0, Vector2(0, 0))
			else:
				claims.set_cell(new_tile_coords, 0, Vector2(team+1, 0))
			return
	else:
		var normal = (previous_tile_coords - new_tile_coords)
		var reflected_velocity = velocity.bounce(normal)
		angle = reflected_velocity.angle() + offset_rad
		claims.set_cell(new_tile_coords, 0, Vector2(team+1, 0))
		return
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		var reflected_velocity = velocity.bounce(normal)
		angle = reflected_velocity.angle()
