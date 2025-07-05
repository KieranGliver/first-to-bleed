extends Building

func _on_timer_timeout():
	var plebs = get_nearby_plebs(2)
	print(str(plebs))
	for pleb in plebs:
		pleb.apply_effect(Data.EffectName.INDUSTRIAL, 5.0)
