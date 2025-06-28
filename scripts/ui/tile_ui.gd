extends HBoxContainer

@onready var team_labels: Array[Label] = [$team_1, $team_2, $team_3, $team_4]

func update(tiles: Array) -> void:
	for i in range(4):
		team_labels[i].text = str(tiles[i])
