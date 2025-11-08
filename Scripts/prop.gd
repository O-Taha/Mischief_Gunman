extends RigidBody2D

func _physics_process(delta: float) -> void:
	if $VelocityVector:
		$VelocityVector.target_position = linear_velocity/30
