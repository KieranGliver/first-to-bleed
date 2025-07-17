extends Node2D

class_name GameManager

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var map_manager: MapManager = $MapManager
@onready var ui: UserInterface = $CanvasLayer/UI
@onready var timer: GameTimer = $Timer
@onready var deck: Deck = $CanvasLayer/UI/Deck
@onready var popup_manager: PopupManager = $CanvasLayer/UI/PopupManager
@onready var build_cursor: Sprite2D = $MapManager/BuildCursor
@onready var camera: Camera2D = $Camera2D

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
	ui.coords.update(map_manager.local_to_map(get_local_mouse_position()))


func _input(event: InputEvent) -> void:
	if selected_card:
		if selected_card.keywords.has(Data.BuildingKeyword.DIRECTIONAL):
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
		
		if event.is_action_released('select'):
			try_place_card(get_global_mouse_position())
	else:
		if event.is_action_pressed('select'):
			var local_position = get_local_mouse_position()
			var mouse_coords = map_manager.local_to_map(local_position)
			if map_manager.building_map.keys().has(mouse_coords):
				var building = map_manager.building_map[mouse_coords]
				popup_manager.initalize_building_popup(building.data, ui.get_local_mouse_position())
	
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
	var deck_data = SessionManager.session["deck"]
	for key in deck_data.keys():
		for i in deck_data[key]:
			deck.data.append(CollectionManager.get_card_data(key))
	
	deck.draw()
	map_manager.init_map(0)
	ducats = [200, 200, 200, 200]
	wood = [0, 0, 0, 0]
	stone = [0, 0, 0, 0]
	tiles = [0, 0, 0, 0]
	selected_card = null
	
	# Calculate spawn points for each team
	var size: Vector2i = map_manager.map_size
	var margin := 2  # prevents spawns too close to edge
	var start_pos: Array[Vector2] = [
		Vector2(randi_range(margin, margin + 1), randi_range(margin, margin + 1)),  # Top-left
		Vector2(randi_range(margin, margin + 1), randi_range(size.y - margin - 2, size.y - margin - 1)),  # Bottom-left
		Vector2(randi_range(size.x - margin - 2, size.x - margin - 1), randi_range(size.y - margin - 2, size.y - margin - 1)),  # Bottom-right
		Vector2(randi_range(size.x - margin - 2, size.x - margin - 1), randi_range(margin, margin + 1))  # Top-right
	]
	
	for i in range(4):
		map_manager.init_team(i, start_pos[i])
	



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
	
	if coords.x < 0 or coords.x >= map_manager.map_size.x or coords.y < 0 or coords.y >= map_manager.map_size.y:
		print("Tile out of bounds")
		selected_card = null
		build_cursor.visible = false
		return
	
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
	if map_manager.get_buildings_radius(coords, radius).filter(func (el): return not el.data.keywords.has(Data.BuildingKeyword.ZONED)).size() > 0:
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


func _on_restart_pressed() -> void:
	setup()


func _on_map_manager_claim_tile(from: int, to: int) -> void:
	if not from == -1:
		add_tiles(-1, from)
	if not to == -1:
		add_tiles(1, to)


func end():
	SessionManager.session['day'] += 1
	SessionManager.save_session()


func _on_timer_timeout() -> void:
	end()
	main.switch_scene('store')
