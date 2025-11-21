extends CharacterBody2D

var speed = 750

func _initialize(position, direction, shooter):
	rotation = direction
	position = position
	owner = shooter
	velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		if collision.get_collider().has_method("hit"):
			collision.get_collider().hit()

func _on_VisibilityNotifier2D_screen_exited():
	# Deletes the bullet when it exits the screen.
	queue_free()
