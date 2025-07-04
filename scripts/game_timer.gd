# CountdownTimer.gd
extends Node

class_name GameTimer


@export var time_length: float = 120.0:  # seconds
	set(value):
		time_length = value
		remaining_time = value
@export var autostart: bool = false

@onready var gm: GameManager = get_tree().get_first_node_in_group('game_manager')
var running: bool
var remaining_time: float

signal timeout()

func _ready():
	remaining_time = time_length
	running = autostart

func _process(delta):
	if running:
		var scaled_delta = delta * Data.SPEED_TO_SCALE[gm.current_speed]
		if gm.current_speed != Data.Speed.PAUSED:
			remaining_time -= scaled_delta
		if remaining_time <= 0:
			reset()

func format_time() -> String:
	var seconds = remaining_time
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func reset() -> void:
	timeout.emit()
	remaining_time = time_length
