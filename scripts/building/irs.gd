extends Building

func _on_placed():
	map_manager.building_placed.connect(on_building_placed)

func on_building_placed(building: Building):
	gm.add_ducats(50, team)
	
