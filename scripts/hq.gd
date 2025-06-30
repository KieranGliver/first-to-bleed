extends Building

func _on_touch(pleb: Pleb) -> void:
	super(pleb)
	gm.add_ducats(10, team)
