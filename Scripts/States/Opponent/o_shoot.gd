@tool
extends State

func enter():
	owner.speed /= 2
	if owner.move_enable:
		await get_tree().create_timer(0.8).timeout
		if owner.player: 
			var aim_direction: Vector2 = owner.to_local(owner.player.global_position + owner.player.velocity/5)
			aim_direction = aim_direction.normalized() * (owner.collision.get_shape().get_rect().size.y-10)
			
			var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
			var congregator = get_tree().root.get_node("/root/BulletCongregator")
			congregator.add_child(bullet)
			bullet.owner = congregator

func update(_delta: float):
	transitioned.emit(self, "o_hunt")

func exit():
	owner.speed *= 2
