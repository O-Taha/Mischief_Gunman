@tool 
extends State

@onready var is_moving_threshold_vel: float = owner.speed/6 # Minimal speed to consider the player is moving

func physics_update(delta: float):
	if owner.move_enable:
		owner.velocity = owner.velocity.lerp(owner.dir * owner.speed, 0.2)
		_check_for_idle()

func _check_for_idle():
	if owner.about_to_stop:
		transitioned.emit(self, "idle")
		
func exit():
	owner.sprite.speed_scale = 1.0
