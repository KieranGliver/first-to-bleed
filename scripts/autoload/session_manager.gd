extends Node

const LOCATION = "user://session.save"

var session: Dictionary = {
	"day": 0,
	"deck": {Data.BuildingName.HOUSE: 4, Data.BuildingName.STALL: 4},
	"life": 3.0,
	"victories": 0.0,
	"rerolls": 3
}


func save_session():
	var save_file = FileAccess.open(LOCATION, FileAccess.WRITE)
	if save_file == null:
		push_error("Failed to open file for saving session.")
		return
	
	var json_string = JSON.stringify(session)
	save_file.store_line(json_string)
	save_file.close()


func load_session():
	if not FileAccess.file_exists(LOCATION):
		push_warning("No session file found to load.")
		return

	var save_file = FileAccess.open(LOCATION, FileAccess.READ)
	if save_file == null:
		push_error("Failed to open file for reading session.")
		return
	

	var json_string = save_file.get_line()
	save_file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("JSON Parse Error: %s in %s at line %d" % [
			json.get_error_message(), json_string, json.get_error_line()
		])
		return

	session = json.data
	
	if session.has("deck"):
			var new_deck := {}
			for key in session["deck"].keys():
				var int_key = int(key)
				new_deck[int_key] = session["deck"][key]
			session["deck"] = new_deck


func upload_deck():
	APIManager.post_http("/upload", session)


func add_card(card_name: int, amount: int = 1):
	if not session.has("deck"):
		session["deck"] = {}
	
	if session["deck"].has(card_name):
		session["deck"][card_name] += amount
	else:
		session["deck"][card_name] = amount
