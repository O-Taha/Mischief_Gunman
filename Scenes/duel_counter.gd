extends RichTextLabel

func _physics_process(delta: float) -> void:
	text = str(roundf($Timer.time_left))
