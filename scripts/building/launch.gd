extends Building

func _on_touch(pleb: Pleb):
	pleb.apply_impulse(facing.angle(), 200)
	pleb.constant_angle = facing.angle() + randf_range(-deg_to_rad(30), deg_to_rad(30))
