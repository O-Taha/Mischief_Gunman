@tool
extends State

var state_register_delay: float = 0.0 # Leaves some time for other nodes to 
							# properly detect this state before leaving it

func enter():
	if owner.shoot_enable:
		var aim_direction: Vector2 = owner.bullet_trajectory.points[1] - owner.bullet_trajectory.points[0]
		aim_direction = aim_direction.normalized() * owner.collision.get_shape().get_rect().size.y
		
		var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
		bullet.set_collision_mask_value(9, true) # enables shooting UI for player only, since opponent could sometimes shoot retry button while it appeared during game over animation

		var congregator = get_tree().root.get_node("/root/BulletCongregator")
		congregator.add_child(bullet)
		bullet.owner = congregator

func update(delta: float):
	state_register_delay += delta
	if state_register_delay >= 0.1:
		state_register_delay = 0.0
		transitioned.emit(self, "idle")
