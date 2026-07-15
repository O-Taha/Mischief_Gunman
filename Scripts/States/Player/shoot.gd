@tool
extends State

var state_register_delay: float    # Leaves some time for other nodes to 
							# properly detect this state before leaving it
							# used by AnimationTree transition expression
							# to detect shooting : FSM.curr_state.name == "shoot"
var shoot_cooldown_enabler: Tween


func enter():
	assert(owner.shoot_enable)
	if owner.shoot_enable and (owner.bullet_trajectory.points.size() >= 2):
		owner.shoot_enable = false
		var aim_direction: Vector2 = owner.bullet_trajectory.points[1] - owner.bullet_trajectory.points[0]
		aim_direction = aim_direction.normalized() * owner.collision.get_shape().get_rect().size.y
		
		var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
		bullet.set_collision_mask_value(9, true) # enables sh	ooting UI for player only, since opponent could sometimes shoot retry button while it appeared during game over animation

		var congregator = get_tree().root.get_node("/root/BulletCongregator")
		congregator.add_child(bullet)
		bullet.owner = congregator
		SfxPlayer.play_sound("TEST", -1, owner.global_position)

func update(delta: float):
	state_register_delay += delta
	if state_register_delay >= 0.1:
		state_register_delay = 0.0
		transitioned.emit(self, "idle")

func exit():
	_enable_shoot_after_cooldown(owner.shoot_cooldown_time) # NEVER CHECK DIED, PLAYER CAN SHOOT WHEN DEAD TO RESTART!!!

func _enable_shoot_after_cooldown(time: float):
	shoot_cooldown_enabler = get_tree().create_tween()
	shoot_cooldown_enabler.tween_callback(func (): owner.shoot_enable = true).set_delay(time)
	
