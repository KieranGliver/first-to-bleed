extends Pattern

func initialize():
	var cliff_cells: Array[Vector2i] = []
	
	for x in range(map_manager.map_size.x):
		for y in range(map_manager.map_size.y):
			var cell = Vector2i(x, y)
			# Random chance to have a cliff, higher = more cliffs
			if randi() % 100 < 70:
				cliff_cells.append(cell)
	
	map_manager.set_cliff(cliff_cells, true)
	
	# Optional: Add sparse clearings by removing random cliff clusters
	var clearing_count := 4
	var clearing_radius := 2
	
	for i in range(clearing_count):
		var cx := randi() % map_manager.map_size.x
		var cy := randi() % map_manager.map_size.y
		for dx in range(-clearing_radius, clearing_radius + 1):
			for dy in range(-clearing_radius, clearing_radius + 1):
				var px = clamp(cx + dx, 0, map_manager.map_size.x - 1)
				var py = clamp(cy + dy, 0, map_manager.map_size.y - 1)
				map_manager.set_cliff([Vector2i(px, py)], false)
