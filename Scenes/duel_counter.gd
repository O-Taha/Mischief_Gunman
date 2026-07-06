extends RichTextLabel

func _physics_process(_delta: float) -> void:
	text = str(roundf($Timer.time_left))
#timer.start(20)
	#timer.timeout.connect(turn_opponent_after_countdown)
