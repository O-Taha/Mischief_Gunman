@tool
class_name Bullet
extends CharacterBody2D

const DEFAULT_LIFETIME: int = 10
const PROPHURTBOX_LAYER: int = 6

var speed: float = 750.0
var lifetime: float = DEFAULT_LIFETIME
var editor_lifetime: float = 0.0
var shooter: PhysicsBody2D # Since owner is BulletCongregator

func _initialize(_position = Vector2.ZERO, _direction = 0, _shooter: PhysicsBody2D = null, _lifetime = DEFAULT_LIFETIME) -> Node:
	rotation = _direction
	global_position = _position
	shooter = _shooter
	lifetime = _lifetime
	editor_lifetime = _lifetime
	velocity = Vector2(speed, 0).rotated(rotation)
	
	if shooter != null:
		set_collision_mask_value(shooter.collision_layer, false)
		$ShooterExitDetector.body_exited.connect(_enable_collision_with_shooter)
	return self


func _ready() -> void:
	if Engine.is_editor_hint(): return
	modulate.a = 0.2 # DEBUG
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(die)
	var despawn_timer: Tween = get_tree().create_tween()
	despawn_timer.tween_callback(die).set_delay(lifetime)


func _enable_collision_with_shooter(body: Node2D) -> void:
	if not is_instance_valid(shooter): return
	set_collision_mask_value(shooter.collision_layer, true)
	$ShooterExitDetector.queue_free()
	modulate = Color.REBECCA_PURPLE # DEBUG


func _physics_process(delta):
	if Engine.is_editor_hint():
		global_position += velocity * delta

		editor_lifetime -= delta
		
		var is_root_node: bool = self == get_tree().current_scene
		if editor_lifetime <= 0.0 and is_root_node:
			queue_free()
	else:
		var collision_info: KinematicCollision2D = move_and_collide(velocity * delta)

		if collision_info:
			var col = collision_info.get_collider() # Buttons, Cowboys, BulletDetectors
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
