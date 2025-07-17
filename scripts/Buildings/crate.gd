extends Building

func _on_placed():
	gm.add_ducats(50, team)
