@tool
extends State

func enter():
	owner.sprite.play(name)

func physics_update(delta: float):
	owner.velocity = owner.velocity.lerp(Vector2.ZERO, 0.1)
	_check_for_walk()	#-> Walk
	_check_for_dash()	#-> Dash
	_check_for_shoot()	#-> Shoot
	
func _check_for_walk():
	for action in owner.input_types["movement"]:
		if Input.is_action_pressed(action):
			transitioned.emit(self, "walk")


	
