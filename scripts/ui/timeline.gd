extends PanelContainer

class_name Timeline

@onready var gm: GameManager = get_tree().get_first_node_in_group('game_manager')
@onready var line_graph: LineGraph = $VBoxContainer/LineGraphContainer/LineGraph

func update_line_graph(data: Array[Dictionary]) -> void:
	var x_interval := 30.0
	var max_time := gm.timer.time_length
	line_graph.min_x = 0
	line_graph.max_x = max_time

	line_graph.team_1_data = data[0]
	line_graph.team_2_data = data[1]
	line_graph.team_3_data = data[2]
	line_graph.team_4_data = data[3]

	# Determine max y value across all teams
	var max_y := 0.0
	for team_data in data:
		for value in team_data.values():
			max_y = max(max_y, float(value))

	# Compute best rounded max_y and y_label_step
	var nice_steps = [1, 5, 10, 25, 50, 100, 250]
	var best_step := 25
	for step in nice_steps:
		if max_y / step <= 10:
			best_step = step
			break

	var rounded_max_y = ceil(max_y / best_step) * best_step

	line_graph.min_y = min(-best_step/10, -0.5)
	line_graph.max_y = max(rounded_max_y, 6.0)
	line_graph.y_label_step = best_step

	# Always fixed x interval
	line_graph.x_label_step = 30

	line_graph.update_graph()


func _on_tiles_pressed() -> void:
	update_line_graph(gm.tile_timeline)


func _on_ducats_pressed() -> void:
	update_line_graph(gm.ducat_timeline)


func _on_wood_pressed() -> void:
	update_line_graph(gm.wood_timeline)


func _on_stone_pressed() -> void:
	update_line_graph(gm.stone_timeline)


func _on_bounces_pressed() -> void:
	update_line_graph(gm.bounce_timeline)


func _on_cards_pressed() -> void:
	update_line_graph(gm.card_timeline)
