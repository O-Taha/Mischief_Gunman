@tool
extends State

const DECELERATION_DELAY: float = 0.08

func enter():
	await get_tree().create_timer(DECELERATION_DELAY).timeout # await can desync stuff w/ queues...
	#=> DO NOT REMOVE IF STATEMENT BELOW
	if FSM.curr_state.name == self.name: owner.sprite.play(self.name)

func physics_update(delta: float):
	owner.velocity = owner.velocity.lerp(Vector2.ZERO, 0.1)
	_check_for_walk()	#-> Walk
	#check_for_dash()	#-> Dash
	check_for_shoot()	#-> Shoot
	
func _check_for_walk():
	for action in owner.input_types["movement"]:
		if Input.is_action_pressed(action):
			transitioned.emit(self, "walk")


	
