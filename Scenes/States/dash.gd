extends State

func enter():
	if owner.move_enable:
		owner.velocity = owner.dir * owner.dash_force
		
func exit():
	owner.can_dash = false
	var dash_cooldown: Tween = get_tree().create_tween()
	dash_cooldown.tween_callback(func (): owner.can_dash = true).set_delay(owner.dash_cooldown)

func update(delta: float):
	transitioned.emit(self, "walk")
