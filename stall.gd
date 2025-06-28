extends Building

func _on_touch(pleb: Pleb) -> void:
	gm.add_ducats(5, team)
