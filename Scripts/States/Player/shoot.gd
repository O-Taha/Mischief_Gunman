@tool
extends State

var state_register_delay: float = 0.0 # Leaves some time for other nodes to 
							# properly detect this state before leaving it

func enter():
	if owner.shoot_enable:
		var aim_direction: Vector2 = owner.bullet_trajectory.points[1] - owner.bullet_trajectory.points[0]
		aim_direction = aim_direction.normalized() * owner.collision.get_shape().get_rect().size.y
		
		var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
		var congregator = get_tree().root.get_node("/root/BulletCongregator")
		congregator.add_child(bullet)
		bullet.owner = congregator

func update(delta: float):
	state_register_delay += delta
	if state_register_delay >= 0.1:
		state_register_delay = 0.0
		transitioned.emit(self, "idle")
