@tool
extends RigidBody2D

var display_debug_vector: bool = true

func _physics_process(delta: float) -> void:
	if $VelocityVector and display_debug_vector:
		$VelocityVector.target_position = linear_velocity/30

func die():
	queue_free()
