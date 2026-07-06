extends AnimationTree

@onready var last_facing_dir: Vector2 = Vector2.UP
var aim_direction: Vector2 = Vector2.UP

func _physics_process(_delta: float) -> void:
	if owner.dir:
		last_facing_dir = owner.dir
		set("parameters/Player Animation FSM/idle/blend_position", last_facing_dir)
		set("parameters/Player Animation FSM/run/blend_position", last_facing_dir)
		set("parameters/Player Animation FSM/shoot/blend_position", last_facing_dir)
	elif owner.bullet_trajectory.fade_gauge:
		if owner.bullet_trajectory.points: aim_direction = owner.bullet_trajectory.points[1] - owner.bullet_trajectory.points[0]
		last_facing_dir = aim_direction
		set("parameters/Player Animation FSM/idle/blend_position", last_facing_dir)
		set("parameters/Player Animation FSM/run/blend_position", last_facing_dir)
		set("parameters/Player Animation FSM/shoot/blend_position", last_facing_dir)
		
	set("parameters/TimeScale/scale", max(owner.velocity.length()*3/owner.speed, 2))
