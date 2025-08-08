extends Pattern

func initialize():
	# Scatter a few yields randomly
	for i in range(10):
		var rx = randi_range(0, map_manager.map_size.x - 1)
		var ry = randi_range(0, map_manager.map_size.y - 1)
		map_manager.spawn_yield(Vector2i(rx, ry), "tree")
	
	for i in range(10):
		var rx = randi_range(0, map_manager.map_size.x - 1)
		var ry = randi_range(0, map_manager.map_size.y - 1)
		map_manager.spawn_yield(Vector2i(rx, ry), "ore")
