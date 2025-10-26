extends State

func physics_update(delta: float):
	owner.velocity = owner.velocity.lerp(Vector2.ZERO, 0.1)
	_check_if_any_action_pressed()
	for direction in owner.input_types["movement"]:
			if Input.is_action_just_pressed(direction):
				if owner.dir == owner.input_buffer and owner.can_dash:
					transitioned.emit(self, "dash")
				owner.input_buffer = owner.dir

func _check_if_any_action_pressed():
	for action in ["left", "right", "up", "down"]:
		if Input.is_action_pressed(action):
			transitioned.emit(self, "walk")
	
