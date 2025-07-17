extends Building

func _on_timer_timeout():
	gm.add_ducats(20, team)
