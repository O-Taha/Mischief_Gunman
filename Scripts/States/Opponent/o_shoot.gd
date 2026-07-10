@tool
extends State

var shoot_cooldown_enabler: Tween
var shoot_reaction_time: float = 0.8

func enter():
	owner.speed /= 20
	assert(owner.shoot_enable)
	await get_tree().create_timer(shoot_reaction_time).timeout # WARNING Leave it 
	# here instead of inside the if clause to allow died to update in time, or else
	# will enter if then die, making it shoot even when dead
	if owner.shoot_enable and not owner.dead: # line may be superfluous
		owner.shoot_enable = false
		if owner.player: 
			var aim_direction: Vector2 = owner.to_local(owner.player.global_position + owner.player.velocity/5)
			aim_direction = aim_direction.normalized() * (owner.collision.get_shape().get_rect().size.y-10)
			
			var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
			var congregator = get_tree().root.get_node("/root/BulletCongregator")
			congregator.add_child(bullet)
			bullet.owner = congregator
			SfxPlayer.play_sound("TEST", -1, owner.global_position)


func update(_delta: float):
	transitioned.emit(self, "o_hunt")

func exit():
	owner.speed *= 20
	if not owner.dead: _enable_shoot_after_cooldown(owner.shoot_cooldown_time)

func _enable_shoot_after_cooldown(time: float):
	shoot_cooldown_enabler = get_tree().create_tween()
	shoot_cooldown_enabler.tween_callback(func (): owner.shoot_enable = true).set_delay(time)
	
