@tool
extends State

func enter():
	if owner.move_enable:
		var aim_direction: Vector2 = owner.bullet_trajectory.points[1] - owner.bullet_trajectory.points[0]
		aim_direction = aim_direction.normalized() * owner.collision.get_shape().get_rect().size.y
		
		var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
		var congregator = get_tree().root.get_node("/root/BulletCongregator")
		congregator.add_child(bullet)
		bullet.owner = congregator
		
#func exit():
	#owner.dash_enable = false
	#_enable_dash_after_cooldown(owner.dash_cooldown_time)

func update(delta: float):
	transitioned.emit(self, "idle")

#func _enable_dash_after_cooldown(time: float):
	#var dash_cooldown_enabler: Tween = get_tree().create_tween()
	#dash_cooldown_enabler.tween_callback(func (): owner.dash_enable = true).set_delay(time)
