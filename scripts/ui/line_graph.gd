@tool
extends Panel

class_name LineGraph

@export var update: bool = false:
	set(value):
		update_graph()
@export var team_1_data: Dictionary = {}
@export var team_2_data: Dictionary = {}
@export var team_3_data: Dictionary = {}
@export var team_4_data: Dictionary = {}
var team_1_points: = []
var team_2_points: = []
var team_3_points: = []
var team_4_points: = []

@export_group('Layout Options')
@export var min_x: float = 0.0:
	set(value):
		min_x = value
		update_graph()
@export var max_x: float = 1.0:
	set(value):
		max_x = value
		update_graph()
@export var min_y: float = 0.0:
	set(value):
		min_y = value
		update_graph()
@export var max_y: float = 1.0:
	set(value):
		max_y = value
		update_graph()

@export_group('Size Options')
@export var top_margin: int = 0:
	set(value):
		top_margin = value
		update_size()
@export var right_margin: int = 0:
	set(value):
		right_margin = value
		update_size()
@export var bot_margin: int = 0:
	set(value):
		bot_margin = value
		update_size()
@export var left_margin: int = 0:
	set(value):
		left_margin = value
		update_size()
@export var graph_width: int = 0:
	set(value):
		graph_width = value
		update_size()
@export var graph_height: int = 0:
	set(value):
		graph_height = value
		update_size()

@export_group('Drawing Options')
@export var background_colour: Color = Color(1.0, 1.0, 1.0):
	set(value):
		background_colour = value
		queue_redraw()
@export var line_thickness: float = 3.0:
	set(value):
		line_thickness = value
		queue_redraw()
@export var point_radius: float = 5.0:
	set(value):
		point_radius = value
		queue_redraw()
@export var show_points: bool = true:
	set(value):
		show_points = value
		queue_redraw()
@export_subgroup('Line Colour')
@export var team_1_colour: Color = Color(0.118, 0.655, 0.882):
	set(value):
		team_1_colour = value
		queue_redraw()
@export var team_2_colour: Color = Color(0.886, 0.475, 0.322):
	set(value):
		team_2_colour = value
		queue_redraw()
@export var team_3_colour: Color = Color(0.106, 0.569, 0.302):
	set(value):
		team_3_colour = value
		queue_redraw()
@export var team_4_colour: Color = Color(0.675, 0.722, 0.722):
	set(value):
		team_4_colour = value
		queue_redraw()

@export_group('Label')
@export_subgroup('X Axis')
@export var show_x_labels: bool = true:
	set(value):
		show_x_labels = value
		queue_redraw()
@export var x_label_step: int = 30:
	set(value):
		x_label_step = value
		queue_redraw()
@export var x_label_font: Font:
	set(value):
		x_label_font = value
		queue_redraw()
@export var x_label_colour: Color = Color.BLACK:
	set(value):
		x_label_colour = value
		queue_redraw()
@export var x_label_size: int = 16:
	set(value):
		x_label_size = value
		queue_redraw()
@export_subgroup('Y Axis')
@export var show_y_labels: bool = true:
	set(value):
		show_y_labels = value
		queue_redraw()
@export var y_label_step: int = 10:
	set(value):
		y_label_step = value
		queue_redraw()
@export var y_label_font: Font:
	set(value):
		y_label_font = value
		queue_redraw()
@export var y_label_colour: Color = Color.BLACK:
	set(value):
		y_label_colour = value
		queue_redraw()
@export var y_label_size: int = 16:
	set(value):
		y_label_size = value
		queue_redraw()

@export_group('Grid Lines')
@export var show_grid: bool = true:
	set(value):
		show_grid = value
		queue_redraw()
@export var grid_line_color: Color = Color(0.8, 0.8, 0.8, 0.5):
	set(value):
		grid_line_color = value
		queue_redraw()
@export var grid_line_thickness: float = 2.0:
	set(value):
		grid_line_thickness = value
		queue_redraw()

func _ready():
	update_graph()


func update_size():
	set_deferred("size", Vector2(left_margin + graph_width + right_margin, top_margin + graph_height + bot_margin))
	update_graph()


func update_graph():
	team_1_points.clear()
	team_2_points.clear()
	team_3_points.clear()
	team_4_points.clear()

	for i in range(4):
		var team_data = {}
		match i:
			0: team_data = team_1_data
			1: team_data = team_2_data
			2: team_data = team_3_data
			3: team_data = team_4_data

		var points = []
		var keys = team_data.keys()
		keys.sort()
		for key in keys:
			var x: float = key
			var y: float = team_data[key]

			var norm_x = (x - min_x) / max((max_x - min_x), 0.0001)
			var norm_y = (y - min_y) / max((max_y - min_y), 0.0001)

			var px = norm_x * graph_width
			var py = graph_height - (norm_y * graph_height)

			points.append(Vector2(px, py))

		match i:
			0: team_1_points = points
			1: team_2_points = points
			2: team_3_points = points
			3: team_4_points = points

	queue_redraw()


func _draw():
	var margins = Vector2(left_margin, top_margin)
	draw_rect(Rect2(margins, Vector2(graph_width, graph_height)), background_colour)

	draw_labels()
	draw_grid_lines()

	var all_teams = [
		{ "points": team_4_points, "colour": team_4_colour },
		{ "points": team_3_points, "colour": team_3_colour },
		{ "points": team_2_points, "colour": team_2_colour },
		{ "points": team_1_points, "colour": team_1_colour },
	]

	for team in all_teams:
		var points = team["points"]
		var colour = team["colour"]

		if points.size() >= 2:
			for i in range(points.size() - 1):
				draw_line(points[i] + margins, points[i + 1] + margins, colour, line_thickness)

		if show_points:
			for point in points:
				draw_circle(point + margins, point_radius, colour)


func draw_labels():
	draw_x_labels()
	draw_y_labels()


func draw_x_labels():
	if not show_x_labels or x_label_font == null:
		return

	var start = 0
	while start < min_x:
		start += x_label_step

	for t in range(start, int(max_x) + 1, x_label_step):
		var norm_x = (t - min_x) / max((max_x - min_x), 0.0001)
		var px = norm_x * graph_width + left_margin
		var label = "%d:%02d" % [t / 60, int(t) % 60]
		var text_size = x_label_font.get_string_size(label)
		draw_string(x_label_font, Vector2(px - text_size.x / 2, size.y - 5), label, 1, -1, x_label_size, x_label_colour)


func draw_y_labels():
	if not show_y_labels or y_label_font == null:
		return
	
	var start = 0
	while start < min_y:
		start += y_label_step

	for y in range(start, int(max_y) + 1, y_label_step):
		var norm_y = (y - min_y) / max((max_y - min_y), 0.0001)
		var py = graph_height - (norm_y * graph_height) + top_margin
		var label = str(y)
		draw_string(y_label_font, Vector2(5, py), label, 2, left_margin - 10, y_label_size, y_label_colour)


func draw_grid_lines():
	if not show_grid:
		return

	var margins = Vector2(left_margin, top_margin)

	var start_x = 0
	while start_x < min_x:
		start_x += x_label_step

	for x in range(start_x, int(max_x) + 1, x_label_step):
		var norm_x = (x - min_x) / max((max_x - min_x), 0.0001)
		var px = norm_x * graph_width + margins.x
		draw_line(Vector2(px, margins.y), Vector2(px, margins.y + graph_height), grid_line_color, grid_line_thickness)

	var start_y = 0
	while start_y < min_y:
		start_y += y_label_step

	for y in range(start_y, int(max_y) + 1, y_label_step):
		var norm_y = (y - min_y) / max((max_y - min_y), 0.0001)
		var py = graph_height - (norm_y * graph_height) + margins.y
		draw_line(Vector2(margins.x, py), Vector2(margins.x + graph_width, py), grid_line_color, grid_line_thickness)
