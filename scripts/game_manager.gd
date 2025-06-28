extends Node2D

class_name GameManager

@onready var map_manager: MapManager = $MapManager
@onready var ui: UserInterface = $CanvasLayer/UI
@onready var timer: GameTimer = $Timer

var house = ResourceLoader.load("res://Cards/house.tres")
var stall = ResourceLoader.load("res://Cards/stall.tres")

var running := true
var last_speed := Data.Speed.NORMAL
var current_speed := Data.Speed.PAUSED
var ducats := [200, 200, 200, 200]
var tiles := [0, 0, 0, 0]
var selected_card : CardData
var hand : Array[CardData] = [house, stall]


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
	selected_card = null

func _ready():
	ui.hand.update(hand)
	setup()


func _process(_delta) -> void:
	ui.timer.update(timer.format_time())

func _input(event: InputEvent) -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print('click')
			try_place_card(get_global_mouse_position())

func _on_hand_ui_card_chosen(card_data: CardData) -> void:
	selected_card = card_data

func try_place_card(global_pos: Vector2, team: int = 0):
	if not selected_card:
		return

	var coords = map_manager.local_to_map(map_manager.to_local(global_pos))
	
	# Check if you can afford it
	if ducats[team] < selected_card.cost:
		print("Not enough ducats")
		return
	
	# You could also check for terrain, enemies, etc. here
	if map_manager.building_map.has(coords):
		print("Already a building here")
		return

	# All checks passed, deduct and build
	add_ducats(-selected_card.cost, team)
	map_manager.spawn_building(coords, team, Data.BUILDING_NAME_TO_STRING[selected_card.building_name])
	selected_card = null
