extends Building

func _on_touch(pleb: Pleb):
	pleb.constant_angle = facing.angle() + randf_range(-deg_to_rad(45), deg_to_rad(45))
