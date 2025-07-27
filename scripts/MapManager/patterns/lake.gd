extends Pattern

func initialize():
	# Carve a big lake in the center (odd width)
	var lake_size = int(min(map_manager.map_size.x, map_manager.map_size.y) * 0.4)  # e.g., 6x6 on a 15x15
	var start = Vector2i((map_manager.map_size.x - lake_size) / 2, (map_manager.map_size.y - lake_size) / 2)
	
	for x in range(start.x, start.x + lake_size):
		for y in range(start.y, start.y + lake_size):
			map_manager.set_floor(x, y, false)  # Remove floor to make water
