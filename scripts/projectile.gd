extends Node2D

class_name Projectile

@onready var timer: GameTimer = $GameTimer
@onready var sprite: Sprite2D = $Sprite2D


var map_manager: MapManager
var team: int = -1
var max_height: float = 50
var total_time: float = 0.0 
var z_offset: float = 0.0
var start_position: Vector2 = Vector2.ZERO
var final_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	position = start_position
	timer.time_length = total_time


func _physics_process(_delta: float) -> void:
	var time = total_time - timer.remaining_time
	var height = _calculate_z_offset(time)
	var ground_pos = _calculate_position(time)
	position = ground_pos + Vector2(0, height)


func _calculate_z_offset(time: float) -> float:
	var progress = clamp(time / total_time, 0.0, 1.0)
	return -(-4 * max_height * (progress - 0.5) * (progress - 0.5) + max_height)


func _calculate_position(time: float):
	var progress = clamp(time / total_time, 0.0, 1.0)
	return start_position.lerp(final_position, progress)


func _on_game_timer_timeout() -> void:
	map_manager.claim(map_manager.local_to_map(map_manager.to_local(to_global(Vector2.ZERO))), team)
	queue_free()
