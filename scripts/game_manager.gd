extends Node2D

class_name GameManager


@onready var map_manager: MapManager = $MapManager
@onready var ui: UserInterface = $CanvasLayer/UI
@onready var timer: GameTimer = $Timer
@onready var deck: Deck = $CanvasLayer/UI/Deck
@onready var build_cursor: Sprite2D = $MapManager/BuildCursor


var hq = ResourceLoader.load("res://Cards/hq.tres")
var running := true
var last_speed := Data.Speed.NORMAL
var current_speed := Data.Speed.PAUSED
var ducats := [200, 200, 200, 200]
var wood := [0, 0, 0, 0]
var stone := [0, 0, 0, 0]
var tiles := [0, 0, 0, 0]
var selected_card : CardData
var card_index: int = 0


func _ready():
	setup()


func _process(_delta) -> void:
	ui.timer.update(timer.format_time())


func _input(event: InputEvent) -> void:
	if selected_card and selected_card.keywords.has(Data.BuildingKeyword.DIRECTIONAL):
		if event.is_action_pressed("rotate"):
			build_cursor.facing = build_cursor.facing + 1 % 4
		elif event.is_action_pressed("set_north"):
			build_cursor.facing = 0
		elif event.is_action_pressed("set_east"):
			build_cursor.facing = 1
		elif event.is_action_pressed("set_south"):
			build_cursor.facing = 2
		elif event.is_action_pressed("set_west"):
			build_cursor.facing = 3
	
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
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			try_place_card(get_global_mouse_position())


func add_ducats(amount: int, team: int = 0):
	ducats[team] += amount
	if (team == 0):
		ui.ducat.update(ducats[team])


func add_wood(amount: int, team: int = 0):
	wood[team] += amount
	if team == 0:
		ui.wood.update(wood[team])


func add_stone(amount: int, team: int = 0):
	stone[team] += amount
	if team == 0:
		ui.stone.update(stone[team])


func add_tiles(amount: int, team: int = 0):
	tiles[team] += amount
	ui.score.update(tiles)


func setup():
	deck.draw()
	map_manager.generate_map(map_manager.Pattern.LAKE)
	var start_pos: Array[Vector2] = [Vector2(2, 2), Vector2(2, 13), Vector2(13, 13), Vector2(13, 2)]
	
	for i in range(4):
		map_manager.spawn_building(start_pos[i], hq, i)
	
	# Reset data values
	ducats = [20000, 200, 200, 200]
	wood = [0, 0, 0, 0]
	stone = [0, 0, 0, 0]
	tiles = [0, 0, 0, 0]
	selected_card = null


func _on_hand_ui_card_chosen(card_data: CardData, index: int) -> void:
	selected_card = card_data
	card_index = index
	build_cursor.large = selected_card.keywords.has(Data.BuildingKeyword.LARGE)
	if selected_card.keywords.has(Data.BuildingKeyword.DIRECTIONAL):
		build_cursor.frame = 1
	else:
		build_cursor.frame = 0
	build_cursor.facing = 0
	build_cursor.visible = true


func try_place_card(global_pos: Vector2, team: int = 0):
	if not selected_card:
		return
	
	var coords = map_manager.local_to_map(map_manager.to_local(global_pos))
	var checks = true
	
		# Check if it's a valid floor tile
	if not map_manager.build_map[coords.x][coords.y] && not selected_card.keywords.has(Data.BuildingKeyword.ZONED):
		print("Invalid floor tile")
		checks = false
	
		# Check if tile is claimed by the team
	if map_manager.claim_map[coords.x][coords.y] != team && not selected_card.keywords.has(Data.BuildingKeyword.VANGUARD):
		print("Tile not owned by team " + str(team))
		checks = false
	
	if not map_manager.floor_map[coords.x][coords.y] && not selected_card.keywords.has(Data.BuildingKeyword.WATER):
		print('Must be placed on floor tile')
		checks = false
	
	# Check if you can afford it
	if ducats[team] < selected_card.cost:
		print("Not enough ducats")
		checks = false
	
	#if wood[team] < selected_card.wood_cost:
		#print("Not enough wood")
		#checks = false
	
	#if stone[team] < selected_card.stone_cost:
		#print("Not enough stone")
		#checks = false
	
	var radius = 0 if selected_card.keywords.has(Data.BuildingKeyword.ZONED) else 1
	if map_manager.get_buildings_radius(coords, radius).filter(func (el): return not el.keywords.has(Data.BuildingKeyword.ZONED)).size() > 0:
		print("Too close to other buildings")
		checks = false
	
	# All checks passed, deduct and build
	if checks:
		add_ducats(-selected_card.cost, team)
		#if selected_card.has("wood_cost"):
			#add_wood(-selected_card.wood_cost, team)
		#if selected_card.has("stone_cost"):
			#add_stone(-selected_card.stone_cost, team)
	
		map_manager.spawn_building(coords, selected_card, team)
		deck.discard(card_index)
	
	selected_card = null
	build_cursor.visible = false
