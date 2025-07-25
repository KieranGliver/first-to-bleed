@tool
extends Control

class_name Scorebar

const X_BUFFER = 13
const Y_BUFFER = 6

@onready var segments: Array[TextureRect] = [
	$Team1,
	$Team2,
	$Team3,
	$Team4
]
@onready var background: NinePatchRect = $Background 

@export_group('Team Scores')
@export var team_1_score := 0:
	set(value):
		team_1_score = value
		_on_score_update()
@export var team_2_score := 0:
	set(value):
		team_2_score = value
		_on_score_update()
@export var team_3_score := 0:
	set(value):
		team_3_score = value
		_on_score_update()
@export var team_4_score := 0:
	set(value):
		team_4_score = value
		_on_score_update()
@export_group('Bar Size')
@export var y_offset := 0:
	set(value):
		y_offset = value
		_on_size_update()
@export var width := 0:
	set(value):
		width = value
		_on_size_update()


func _on_score_update():
	var scores = [team_1_score, team_2_score, team_3_score, team_4_score]
	var total_score = scores.reduce(func(a, b): return a + b)

	if total_score == 0:
		for segment in segments:
			segment.size.x = 0
		return

	var current_x = -width / 2
	for i in range(segments.size()):
		var proportion = float(scores[i]) / total_score
		var segment_width = proportion * width
		segments[i].position = Vector2(current_x, y_offset + Y_BUFFER)
		segments[i].size = Vector2(segment_width, segments[i].size.y)
		current_x += segment_width


func _on_size_update():
	if background:
		background.position = Vector2(-(width / 2) - X_BUFFER, y_offset)
		background.size = Vector2(width + (X_BUFFER * 2), background.size.y)


func update(score: Array):
	if score.size() >= 4:
		team_1_score = score[0]
		team_2_score = score[1]
		team_3_score = score[2]
		team_4_score = score[3]
