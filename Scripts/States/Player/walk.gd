@tool 
extends State

@onready var is_moving_threshold_vel: float = owner.speed/6 # Minimal speed to consider the player is moving
var last_vel_lenght: float

func physics_update(delta: float):
	if owner.move_enable:
		owner.velocity = owner.velocity.lerp(owner.dir * owner.speed, 0.2)
		
		if owner.sprite.animation != "walk" and owner.velocity.length() >= is_moving_threshold_vel:
			if owner.sprite.animation == "dash": 
				await owner.sprite.animation_finished
			owner.sprite.play(self.name)
			 # Waits for a true movement to play walk, avoids jittering against walls
		
		owner.sprite.speed_scale = owner.get_real_velocity().length()/owner.speed

		#check_for_dash()	# WARNING: Prioritize dash check over idle 
						# for easier dash state entry
		_check_for_idle()
		
func _check_for_idle():
	var player_about_to_stop = owner.velocity.length() <= 100\
				and owner.velocity.length() < last_vel_lenght
	
	owner.acceleration = owner.velocity.length() - last_vel_lenght
	last_vel_lenght = owner.velocity.length()
	
	if player_about_to_stop:
		transitioned.emit(self, "idle")
		
func exit():
	owner.sprite.speed_scale = 1.0
