extends CharacterBody2D

var speed = 750

func _initialize(position = Vector2.ZERO, direction = 0, shooter = get_parent()) -> CharacterBody2D:
	rotation = direction
	position = position
	owner = shooter
	velocity = Vector2(speed, 0).rotated(rotation)
	
	return self

func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		if collision_info.get_collider().has_method("hit"):
			collision_info.get_collider().hit()

func _on_screen_exited():
	queue_free()
