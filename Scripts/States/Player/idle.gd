@tool
extends State

const DECELERATION_DELAY: float = 0.08

func physics_update(delta: float):
	owner.velocity = owner.velocity.lerp(Vector2.ZERO, 0.1)
	_check_for_walk()	#-> Walk
	
func _check_for_walk():
	for action in owner.input_types["movement"]:
		if Input.is_action_pressed(action):
			transitioned.emit(self, "walk")


	
