# CountdownTimer.gd
extends Node

class_name GameTimer

@export var gm: GameManager
@export var starting_time: float = 120.0  # seconds
@export var autostart: bool = false
var is_running: bool
var remaining_time: float

func _ready():
	remaining_time = starting_time
	is_running = autostart

func _process(delta):
	if is_running:
		var scaled_delta = delta * Data.SPEED_TO_SCALE[gm.current_speed]
		if gm.current_speed != Data.Speed.PAUSED:
			remaining_time -= scaled_delta
			remaining_time = max(remaining_time, 0)

func format_time() -> String:
	var seconds = remaining_time
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]
