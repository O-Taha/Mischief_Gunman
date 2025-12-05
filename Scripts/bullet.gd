extends CharacterBody2D

var speed = 750

func _initialize(_position = Vector2.ZERO, _direction = 0) -> Node:
	rotation = _direction
	position = _position
	velocity = Vector2(speed, 0).rotated(rotation)
	return self

func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		var prop = collision_info.get_collider()
		if not prop.get("components"): return
		if prop.has_component(prop.HEALTH_COMPONENT):
			prop.get_node("HealthComponent")._on_hit(self)
		if not prop.has_component(prop.RICOCHET_COMPONENT): queue_free()
		else: velocity *= prop.get_node("RicochetComponent").bounce

func _on_screen_exited():
	queue_free()
