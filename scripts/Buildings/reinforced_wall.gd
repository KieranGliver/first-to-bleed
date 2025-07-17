extends Building


func _apply_group_effect(group: Array[Building]) -> void:
	for b in group:
		if not b.data.keywords.has(Data.BuildingKeyword.CONCRETE):
			b.current_health += 5
			b.max_health += 5


func _remove_group_effect(group: Array[Building]) -> void:
	for b in group:
		if not b.data.keywords.has(Data.BuildingKeyword.CONCRETE):
			b.max_health -= 5
			b.current_health = min(current_health, max_health)
