extends Building

func _on_touch(pleb: Pleb):
	pleb.apply_effect(Data.EffectName.RUSH, 3.0)
