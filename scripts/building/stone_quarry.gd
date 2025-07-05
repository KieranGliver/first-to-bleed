extends Building

func _on_touch(pleb: Pleb):
	gm.add_stone(1, team)
