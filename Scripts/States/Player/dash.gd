@tool
extends State

func enter():
	assert(owner.dash_enable, "You didn't check dash_enable was valid before transitioning to dash state !")
	if owner.move_enable:
		owner.velocity = owner.dir * owner.dash_force
		
func exit():
	owner.dash_enable = false
	_enable_dash_after_cooldown(owner.dash_cooldown_time)

func update(delta: float):
	transitioned.emit(self, "walk")

func _enable_dash_after_cooldown(time: float):
	var dash_cooldown_enabler: Tween = get_tree().create_tween()
	dash_cooldown_enabler.tween_callback(func (): owner.dash_enable = true).set_delay(time)
