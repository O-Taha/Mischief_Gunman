extends RigidBody2D

func _physics_process(delta: float) -> void:
	$RayCast2D.target_position = linear_velocity/30
