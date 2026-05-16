extends Label

func _physics_process(delta: float) -> void:
	text = str(roundf(get_parent().time_left))
