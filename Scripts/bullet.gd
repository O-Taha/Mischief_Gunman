extends CharacterBody2D

var speed: float = 750.0
const DESPAWN_TIMER_DELAY: int = 30

func _initialize(_position = Vector2.ZERO, _direction = 0) -> Node:
	rotation = _direction
	position = _position
	velocity = Vector2(speed, 0).rotated(rotation)
	return self

func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(die)
	
	var despawn_timer: Tween = get_tree().create_tween()
	despawn_timer.tween_callback(die).set_delay(DESPAWN_TIMER_DELAY)

func _physics_process(delta):
	var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision_info:
		var prop = collision_info.get_collider()
		var has_no_components: bool = not prop.get("added_components")
		var queue_death: bool = false # Allows for freeing *after* checking all conditions
		
		if has_no_components: #Either no components added or isn't a Prop
			die()
			return
		if prop.has_component(prop.HEALTH_COMPONENT):
			prop.get_node("HealthComponent")._on_hit_by(self)
			queue_death = true
		if prop.has_component(prop.RICOCHET_COMPONENT):
			velocity = velocity.bounce(collision_info.get_normal())
			velocity *= prop.get_node("RicochetComponent").bounce_factor
			queue_death = false
		else: queue_death = true
			
		if queue_death: die()

func die():
	queue_free()
