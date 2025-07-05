extends Building

func _on_timer_timeout():
	var connection_count = map_manager.building_groups[self].size()
	gm.add_ducats(5 * connection_count, team)
