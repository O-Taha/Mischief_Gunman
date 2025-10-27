@tool
extends State

func physics_update(delta: float):
	owner.velocity = owner.velocity.lerp(Vector2.ZERO, 0.1)
	_check_if_any_action_pressed()#-> Walk
	_check_for_dash()			#-> Dash
	
func _check_if_any_action_pressed():
	for action in ["left", "right", "up", "down"]:
		if Input.is_action_pressed(action):
			transitioned.emit(self, "walk")
			
func _check_for_dash():
	for direction in owner.input_types["movement"]:
			if Input.is_action_just_pressed(direction):
				if owner.dir == owner.dir_input_buffer and owner.dash_enable:
					transitioned.emit(self, "dash")
				owner.dir_input_buffer = owner.dir

	
