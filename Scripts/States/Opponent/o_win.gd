@tool
extends State

func physics_update(delta: float) -> void:
	owner.velocity = owner.velocity.lerp(Vector2.ZERO, delta * 2)
