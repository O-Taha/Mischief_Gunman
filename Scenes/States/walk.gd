extends State

var last_vel_lenght: float

func physics_update(delta: float):
	if owner.move_enable:
		owner.velocity = owner.velocity.lerp(owner.dir * owner.speed, 0.1)
		
		var player_decelerated = owner.velocity.length() <= 50 and owner.velocity.length() < last_vel_lenght
		last_vel_lenght = owner.velocity.length()
		
		if player_decelerated:
			transitioned.emit(self, "idle")
		
		for direction in owner.input_types["movement"]:
			if Input.is_action_just_pressed(direction):
				if owner.dir == owner.input_buffer and owner.can_dash:
					transitioned.emit(self, "dash")
				owner.input_buffer = owner.dir
