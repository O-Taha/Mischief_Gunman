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

func update(delta: float):
	transitioned.emit(self, "idle")
