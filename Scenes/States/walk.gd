@tool 
extends State

var last_vel_lenght: float

func enter():
	_end_dash_anim_before_walk_anim()
	
func _end_dash_anim_before_walk_anim():
	if owner.sprite.animation == "dash": await owner.sprite.animation_finished
	owner.sprite.play(name)

func physics_update(delta: float):
	if owner.move_enable:
		owner.velocity = owner.velocity.lerp(owner.dir * owner.speed, 0.1)
		
		var player_decelerated = owner.velocity.length() <= 50\
		and owner.velocity.length() < last_vel_lenght
		
		owner.acceleration = owner.velocity.length() - last_vel_lenght
		last_vel_lenght = owner.velocity.length()
		
		if player_decelerated:
			transitioned.emit(self, "idle")
		
		_check_for_dash()
		_check_for_shoot()
