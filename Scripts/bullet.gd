class_name Bullet
extends CharacterBody2D

var speed: float = 750.0
const DESPAWN_TIMER_DELAY: int = 30
const PROPHURTBOX_LAYER: int = 6

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
		var col = collision_info.get_collider() # Buttons, Cowboys, BulletDetectors
		print(col)
		if col.has_method("die"): # kills Cowboys, triggers shootable buttons
			if not col.get("dead"): # Calls die only if doesn't have dead property (eg: button) or isn't dead
				col.die()
			self.die()
		elif col.get_collision_layer_value(PROPHURTBOX_LAYER):
			var prop: Prop = col.owner # if it's a prop, get Prop instead of BulletDetector 
			col._on_body_entered(self) # RigidBody's default collision response is colliding
								# this means it never enters BulletDetector's area,
								# Its callback has to be called manually like this
								# WARNING: Can't replace BulletDetector w/ Area2D or
								# you'll loose get_collider() & get_normal()
			if prop.has_component(prop.RICOCHET_COMPONENT):
				velocity = velocity.bounce(collision_info.get_normal())
				velocity *= prop.get_node("RicochetComponent").bounce_factor

func die():
	queue_free()
