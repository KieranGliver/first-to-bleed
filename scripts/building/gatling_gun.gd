extends Building

func _on_timer_timeout() -> void:
	var connection_count = map_manager.building_groups[self].size()
	fire_projectiles(connection_count, 3)
