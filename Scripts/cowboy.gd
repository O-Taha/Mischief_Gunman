class_name Cowboy 
extends CharacterBody2D

signal collided(vel) # Will be used for screen shake
signal died

@export var speed: float = 300
var dir: Vector2 

@export_category("Nodes & Scenes")
@export var bullet: PackedScene
@export var sprite: Node2D

var move_enable: bool = true
var shoot_enable: bool = true
var acceleration: float # Used to check we just did a dash, for prop pushing 
# since checking dash state isn't enough as it is transient
var last_vel_lenght: float
var about_to_stop: bool

func _physics_process(delta: float) -> void:
	about_to_stop = velocity.length() <= 100\
				and velocity.length() < last_vel_lenght
	acceleration = velocity.length() - last_vel_lenght
	last_vel_lenght = velocity.length()

func _handle_collisions():
	for collision in get_slide_collision_count(): # Credits to KidsCanCode (https://kidscancode.org/godot_recipes/4.x/physics/character_vs_rigid/index.html)
		var collision_info: KinematicCollision2D = get_slide_collision(collision)
		var collider: Object = collision_info.get_collider()

		var curr_vel: Vector2 = get_real_velocity()
		var is_dashing_or_pushing: bool = (acceleration > 0 or velocity.length() >= speed)
		
		if collider is RigidBody2D and is_dashing_or_pushing:
			collided.emit(curr_vel)
			_push_prop(collider, -collision_info.get_normal())

func _push_prop(collider: Object, direction: Vector2):
	var impulse_dir = Vector2.from_angle(lerp_angle((direction).angle(), dir.angle(), 0.5))
	var impulse: Vector2 = (impulse_dir*velocity.length())\
							/(collider.mass*1.5)
	_apply_opposite_force_to_self_and_collider(impulse, collider)

func _apply_opposite_force_to_self_and_collider(impulse: Vector2, collider: Object):
	collider.push(impulse)
	velocity = -impulse/2

func die():
	queue_free()
