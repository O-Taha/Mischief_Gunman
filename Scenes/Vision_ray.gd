extends RayCast2D

func _physics_process(delta: float) -> void:
	if is_colliding():
		target_position.limit_length(to_local(get_collision_point()).length())
