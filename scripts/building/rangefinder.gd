extends Building

func _apply_group_effect(group: Array[Building]) -> void:
	for b in group:
		b.range_bonus = 2

func _remove_group_effect(group: Array[Building]) -> void:
	for b in group:
		b.range_bonus = 0
