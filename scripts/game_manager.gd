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
var ai_teams: Array[int] = [1, 2, 3]
var ai_decks: Array = [[], [], [], []]
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
	timer.running = false
	load_decks()
	setup()
	timer.running = true


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
			try_place_card(selected_card, get_global_mouse_position())
	else:
		if event.is_action_pressed('select'):
			var local_position = get_local_mouse_position()
			var mouse_coords = map_manager.local_to_map(local_position)
			if map_manager.building_map.keys().has(mouse_coords):
				var building = map_manager.building_map[mouse_coords]
				popup_manager.initalize_building_popup(building.data, battle_ui.get_local_mouse_position())

func load_decks():
	var day = SessionManager.session["day"]
	var deck_data = SessionManager.session["deck"]
	for key in deck_data.keys():
		for i in deck_data[key]:
			var card_data = CollectionManager.get_card_data(key)
			deck.data.append(card_data)

	APIManager.get_http("/opponents", {"day": day}, _on_request_completed)
	await APIManager._on_temp_request_completed  # Wait for data to be ready
	
	for team in ai_teams:
		for card in ai_decks[team]:
			print(Data.BUILDING_NAME_TO_STRING[card.building_name])

func setup():
	
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
	
	add_ducats(0)
	add_wood(0)
	add_stone(0)
	timestamp()
	
	#SoundManager.play("penis_music", -15)


func get_segmented_timestamp() -> float:
	var ts = timer.time_length - timer.remaining_time
	return floor(ts / TIMELINE_INTERVAL) * TIMELINE_INTERVAL


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


func try_place_card(card: CardData, global_pos: Vector2, team: int = 0):
	var result = false
	if not card:
		return result
	
	var coords = map_manager.local_to_map(map_manager.to_local(global_pos))
	var checks = true
	
	if coords.x < 0 or coords.x >= map_manager.map_size.x or coords.y < 0 or coords.y >= map_manager.map_size.y:
		print("Tile out of bounds")
		selected_card = null
		build_cursor.visible = false
		return
	
		# Check if it's a valid floor tile
	if not map_manager.build_map[coords.x][coords.y] && not card.keywords.has(Data.BuildingKeyword.ZONED):
		print("Invalid floor tile")
		checks = false
	
		# Check if tile is claimed by the team
	if map_manager.claim_map[coords.x][coords.y] != team && not card.keywords.has(Data.BuildingKeyword.VANGUARD):
		print("Tile not owned by team " + str(team))
		checks = false
	
	if not map_manager.floor_map[coords.x][coords.y] && not card.keywords.has(Data.BuildingKeyword.WATER):
		print('Must be placed on floor tile')
		checks = false
	
	# Check if you can afford it
	if ducats[team] < card.cost:
		print("Not enough ducats")
		checks = false
	
	#if wood[team] < card.wood_cost:
		#print("Not enough wood")
		#checks = false
	
	#if stone[team] < card.stone_cost:
		#print("Not enough stone")
		#checks = false
	
	var radius = 0 if card.keywords.has(Data.BuildingKeyword.ZONED) else 1
	if map_manager.get_buildings_radius(coords, radius).filter(func (el): return not el.data.keywords.has(Data.BuildingKeyword.ZONED)).size() > 0:
		print("Too close to other buildings")
		checks = false
	
	# All checks passed, deduct and build
	if checks:
		add_ducats(-card.cost, team)
		#if card.has("wood_cost"):
			#add_wood(-card.wood_cost, team)
		#if card.has("stone_cost"):
			#add_stone(-card.stone_cost, team)
		cards[team] += 1
		var t = get_segmented_timestamp()
		card_timeline[team][t] = cards[team]
		map_manager.spawn_building(coords, card, team)
		if team == 0:
			deck.discard(card_index)
		else:
			ai_decks[team].erase(card)
		result = true
	
	if (team == 0):
		selected_card = null
		build_cursor.visible = false
	
	return result


func get_valid_tiles_for_card(card: CardData, team: int) -> Array:
	var valid := []
	var map_size = map_manager.map_size
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var coords = Vector2i(x, y)
			
			# Must be owned
			if map_manager.claim_map[x][y] != team and not card.keywords.has(Data.BuildingKeyword.VANGUARD):
				continue
			
			# Must have valid floor
			if not map_manager.floor_map[x][y] and not card.keywords.has(Data.BuildingKeyword.WATER):
				continue

				
			
			var radius = 0 if card.keywords.has(Data.BuildingKeyword.ZONED) else 1
			if map_manager.get_buildings_radius(coords, radius).filter(func (el): return not el.data.keywords.has(Data.BuildingKeyword.ZONED)).size() > 0:
				continue

			valid.append(coords)

	return valid


func ai_take_turn(team: int) -> void:
	if not running:
		return
	
	var deck = ai_decks[team]
	if deck.is_empty():
		return
	
	var affordable = deck.filter(func(c): return ducats[team] > c.cost)
	if affordable.is_empty():
		return
	
	affordable.shuffle()
	
	for card in affordable:
		var valid_tiles = get_valid_tiles_for_card(card, team)
		if valid_tiles.is_empty():
			continue
		
		var success
		
		for i in range(10):
			var coords = valid_tiles[randi() % valid_tiles.size()]
			var global_pos = map_manager.to_global(map_manager.map_to_local(coords))
			success = try_place_card(card, global_pos, team)
			if success:
				break
		if success:
			deck.erase(card)
			break


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
	SoundManager.stop("penis_music")


func _on_pause_button_pressed() -> void:
	if running:
		if current_speed != Data.Speed.PAUSED:
			last_speed = current_speed
			current_speed = Data.Speed.PAUSED
		else:
			current_speed = last_speed
			battle_ui.time_buttons[last_speed].button_pressed = true


func _on_speed_one_pressed() -> void:
	if running:
		current_speed = Data.Speed.NORMAL


func _on_speed_two_pressed() -> void:
	if running:
		current_speed = Data.Speed.X2


func _on_speed_three_pressed() -> void:
	if running:
		current_speed = Data.Speed.X4


func _on_speed_four_pressed() -> void:
	if running:
		current_speed = Data.Speed.X8


func _on_ai_timer_timeout() -> void:
	for team in ai_teams:
		ai_take_turn(team)


func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		push_error("Failed to load opponent decks. Code: %s" % response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_ARRAY:
		push_error("Invalid opponent deck response format.")
		return

	var i = 1
	for team in json:
		for card_id in team["deck"].keys():
			var card_data = CollectionManager.get_card_data(int(card_id))
			if card_data != null:
				for _j in team["deck"][card_id]:
					ai_decks[i].append(card_data)
		i += 1
	
	while i <= 3:
		var house = CollectionManager.get_card_data(1)
		var stall = CollectionManager.get_card_data(2)
		ai_decks[i] = [house, house, house, house, stall, stall, stall, stall]
		var day = SessionManager.session["day"]
		for _j in range(day):
			for _k in range(3):
				ai_decks[i].append(CollectionManager.random_card())
		i += 1
	for team in ai_teams:
		print("team " + str(team))
		for card in ai_decks[team]:
			print(Data.BUILDING_NAME_TO_STRING[card.building_name])
