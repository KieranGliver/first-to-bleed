extends Node2D

class_name GameManager

const TIMELINE_INTERVAL := 0.5

@onready var main: Main = get_tree().get_nodes_in_group('main').pop_front()
@onready var map_manager: MapManager = $MapManager
@onready var battle_ui: BattleUI = $CanvasLayer/BattleUI
@onready var result_ui: ResultUI = $CanvasLayer/ResultUI
@onready var timer: GameTimer = $Timer
@onready var deck: Deck = $CanvasLayer/BattleUI/Deck
@onready var popup_manager: PopupManager = $CanvasLayer/BattleUI/PopupManager
@onready var build_cursor: Sprite2D = $MapManager/BuildCursor
@onready var camera: Camera2D = $Camera2D

var running := true
var last_speed := Data.Speed.NORMAL
var current_speed := Data.Speed.PAUSED
var selected_card : CardData
var card_index: int = 0
var ducats := [200, 200, 200, 200]
var total_ducats := [200, 200, 200, 200]
var wood := [0, 0, 0, 0]
var total_wood := [0, 0, 0, 0]
var stone := [0, 0, 0, 0]
var total_stone := [0, 0, 0, 0]
var tiles := [0, 0, 0, 0]
var bounce := [0, 0, 0, 0]
var cards := [0, 0, 0, 0]

var tile_timeline: Array[Dictionary] = [{}, {}, {}, {}]
var ducat_timeline: Array[Dictionary] = [{}, {}, {}, {}]
var wood_timeline: Array[Dictionary] = [{}, {}, {}, {}]
var stone_timeline: Array[Dictionary] = [{}, {}, {}, {}]
var bounce_timeline: Array[Dictionary] = [{}, {}, {}, {}]
var card_timeline: Array[Dictionary] = [{}, {}, {}, {}]

func _ready():
	setup()


func _process(_delta) -> void:
	battle_ui.timer.update(timer.format_time())
	battle_ui.coords.update(map_manager.local_to_map(get_local_mouse_position()))


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
				popup_manager.initalize_building_popup(building.data, battle_ui.get_local_mouse_position())
	
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


func setup():
	var deck_data = SessionManager.session["deck"]
	for key in deck_data.keys():
		for i in deck_data[key]:
			deck.data.append(CollectionManager.get_card_data(key))
	
	deck.draw()
	map_manager.init_map(0)
	ducats = [200, 200, 200, 200]
	total_ducats = [200, 200, 200, 200]
	wood = [0, 0, 0, 0]
	total_wood = [0, 0, 0, 0]
	stone = [0, 0, 0, 0]
	total_stone = [0, 0, 0, 0]
	tiles = [0, 0, 0, 0]
	bounce = [0, 0, 0, 0]
	cards = [0, 0, 0, 0]
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
	
	timestamp()


func get_segmented_timestamp() -> float:
	var timestamp = timer.time_length - timer.remaining_time
	return floor(timestamp / TIMELINE_INTERVAL) * TIMELINE_INTERVAL


func timestamp():
	var t = get_segmented_timestamp()
	for team in range(4):
		tile_timeline[team][t] = tiles[team]
		ducat_timeline[team][t] = total_ducats[team]
		wood_timeline[team][t] = total_wood[team]
		stone_timeline[team][t] = total_stone[team]
		bounce_timeline[team][t] = bounce[team]
		card_timeline[team][t] = cards[team]


func add_ducats(amount: int, team: int = 0):
	ducats[team] += amount
	if amount > 0:
		total_ducats[team] += amount
		var t = get_segmented_timestamp()
		ducat_timeline[team][t] = total_ducats[team]
	
	if team == 0:
		battle_ui.ducat.update(ducats[team])

func add_wood(amount: int, team: int = 0):
	wood[team] += amount
	if amount > 0:
		total_wood[team] += amount
		var t = get_segmented_timestamp()
		wood_timeline[team][t] = wood[team]
	
	if team == 0:
		battle_ui.wood.update(wood[team])


func add_stone(amount: int, team: int = 0):
	stone[team] += amount
	if amount > 0:
		total_stone[team] += amount
		var t = get_segmented_timestamp()
		stone_timeline[team][t] = stone[team]
	
	if team == 0:
		battle_ui.stone.update(stone[team])


func add_tiles(amount: int, team: int = 0):
	tiles[team] += amount
	var t = get_segmented_timestamp()
	tile_timeline[team][t] = tiles[team]
	battle_ui.score.update(tiles)


func add_bounce(amount: int, team: int = 0):
	bounce[team] += amount
	var t = get_segmented_timestamp()
	bounce_timeline[team][t] = bounce[team]


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
		cards[team] += 1
		var t = get_segmented_timestamp()
		card_timeline[team][t] = cards[team]
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


func exit():
	SessionManager.session['day'] += 1
	SessionManager.save_session()
	main.switch_scene('store')


func get_team_tile_ranking() -> Array:
	var teams := []
	for i in range(tiles.size()):
		teams.append({ "team": i, "tiles": tiles[i] })
	
	teams.sort_custom(func(a, b): return b["tiles"] < a["tiles"])
	
	return teams.map(func(e): return e["team"])


func _on_timer_timeout() -> void:
	battle_ui.visible = false
	var i = 0
	var teams = get_team_tile_ranking()
	for team in teams:
		result_ui.team_stats[i].bg_colour = team
		result_ui.team_stats[i].title = "team " + str(team + 1)
		result_ui.team_stats[i].tile = tiles[team]
		result_ui.team_stats[i].ducat = total_ducats[team]
		result_ui.team_stats[i].bounce = bounce[team]
		result_ui.team_stats[i].card = cards[team]
		i += 1 
	result_ui.timeline.update_line_graph(tile_timeline)
	result_ui.result_title.text = "Team " + str(teams[0] + 1) + " wins!"
	result_ui.visible = true
	timestamp()
	running = false
