extends RichTextLabel

func _physics_process(_delta: float) -> void:
	text = str(roundf($Timer.time_left))
