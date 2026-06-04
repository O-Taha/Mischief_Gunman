@tool
extends State

@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var old_dir = owner.get("dir")

func enter():
	nav_agent.velocity_computed.connect(on_avoidance_velocity_computed)
	nav_agent.target_position = owner.player.global_position
	nav_agent.navigation_finished.connect(update_player_target_position)
	#if owner.move_enable:
		#var aim_direction: Vector2 = owner.bullet_trajectory.points[1] - owner.bullet_trajectory.points[0]
		#aim_direction = aim_direction.normalized() * owner.collision.get_shape().get_rect().size.y
		#
		#var bullet = owner.bullet.instantiate()._initialize(owner.global_position+aim_direction, aim_direction.angle())
		#var congregator = get_tree().root.get_node("/root/BulletCongregator")
		#congregator.add_child(bullet)
		#bullet.owner = congregator

func update_player_target_position():
	nav_agent.target_position = owner.player.global_position

func physics_update(delta: float):
	owner.dir = owner.to_local(nav_agent.get_next_path_position()).normalized()
	nav_agent.velocity = owner.dir * (owner.speed * max(0.7, abs(deg_to_rad(owner.dir.angle_to(old_dir)))))*1000
	#print(max(0.7, abs(deg_to_rad(dir.angle_to(old_dir)))))
	old_dir = owner.dir
	if Input.is_action_just_pressed("ui_focus_next"): 
		transitioned.emit(self, "o_passive") # DEBUG
	
func on_avoidance_velocity_computed(safe_velocity: Vector2):
	owner.velocity = safe_velocity*2

func exit(): # DEBUG
	nav_agent.velocity_computed.disconnect(on_avoidance_velocity_computed)
