extends Node2D

class_name GameManager

@onready var map_manager: MapManager = $MapManager
@onready var ui: UserInterface = $CanvasLayer/UI
@onready var timer: GameTimer = $Timer

var running := true
var last_speed := Data.Speed.NORMAL
var current_speed := Data.Speed.PAUSED
var ducats := [200, 200, 200, 200]
var tiles := [0, 0, 0, 0]

func add_ducats(amount: int, team: int = 0):
	ducats[team] += amount
	if (team == 0):
		ui.ducat.update(ducats[team])

func add_tiles(amount: int, team: int = 0):
	tiles[team] += amount
	ui.score.update(tiles)

func setup():
	map_manager.upkeep()
	var start_pos: Array[Vector2] = [Vector2(2, 2), Vector2(2, 13), Vector2(13, 13), Vector2(13, 2)]
	
	for i in range(4):
		# Spawns plebs on the map
		map_manager.spawn_pleb(start_pos[i] + Vector2(1, 0), i, 4)
		map_manager.spawn_building(start_pos[i], i, 'hq')
	
	# Reset data values
	ducats = [200, 200, 200, 200]
	tiles = [0, 0, 0, 0]

func _ready():
	setup()


func _process(_delta) -> void:
	ui.timer.update(timer.format_time())

func _input(event):
	if running:
		if event.is_action_pressed("ui_pause"):
			if current_speed != Data.Speed.PAUSED:
				last_speed = current_speed
				current_speed = Data.Speed.PAUSED
			else:
				current_speed = last_speed
		elif event.is_action_pressed("ui_speed_1"):
			current_speed = Data.Speed.NORMAL
		elif event.is_action_pressed("ui_speed_2"):
			current_speed = Data.Speed.X2
		elif event.is_action_pressed("ui_speed_3"):
			current_speed = Data.Speed.X4
		elif event.is_action_pressed("ui_speed_4"):
			current_speed = Data.Speed.X8
