@tool
extends State

@export_category("Nodes & Scenes")
@export var vision_cone: Node2D
@export var reticle: Node2D

@onready var nav_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var old_dir = owner.get("dir")

func enter():
	nav_agent.velocity_computed.connect(on_avoidance_velocity_computed)
	if owner.player: nav_agent.target_position = owner.player.global_position
	nav_agent.navigation_finished.connect(update_player_target_position)
	create_tween().set_loops().tween_callback(update_player_target_position).set_delay(1.0)

func update_player_target_position():
	if owner.player: nav_agent.target_position = owner.player.global_position

func physics_update(delta: float):
	owner.desired_dir = owner.to_local(nav_agent.get_next_path_position()).normalized()
	owner.dir = owner.dir.slerp(owner.desired_dir, owner.turn_speed * delta).normalized()

	nav_agent.velocity = owner.dir * (owner.speed * max(0.7, abs(deg_to_rad(owner.dir.angle_to(old_dir)))))*1000
	old_dir = owner.dir
	
	owner.shoot_enable = reticle.target_acquired and vision_cone.player_in_sight
	if owner.shoot_enable and not owner.dead: 
		transitioned.emit(self, "o_shoot")

func on_avoidance_velocity_computed(safe_velocity: Vector2):
	owner.velocity = safe_velocity*2

func exit(): # DEBUG
	nav_agent.velocity_computed.disconnect(on_avoidance_velocity_computed)
	nav_agent.navigation_finished.disconnect(update_player_target_position)
