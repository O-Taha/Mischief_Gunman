extends AnimationTree

@onready var last_facing_dir: Vector2 = owner.dir

func _physics_process(delta: float) -> void:
	if owner.dir:
		last_facing_dir = owner.dir
		set("parameters/Player Animation FSM/idle/blend_position", last_facing_dir)
		set("parameters/Player Animation FSM/run/blend_position", last_facing_dir)
		set("parameters/Player Animation FSM/shoot/blend_position", last_facing_dir)
	set("parameters/TimeScale/scale", max(owner.velocity.length()*3/owner.speed, 2))
