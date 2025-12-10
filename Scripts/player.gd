class_name Player 
extends Cowboy

signal collided(vel) # Will be used for screen shake

@export_category("Nodes & Scenes")
@export var bullet_trajectory: Line2D
@export var collision: CollisionShape2D

@export var dash_force: float = speed * 5

var input_types: Dictionary[String, Array] = \
{"movement": ["left", "right", "up", "down"], "special": ["shoot"]}

var dir: Vector2 = Input.get_vector("left", "right", "up", "down") # holds inputed direction for comparison with dir_input_buffer

#region Dash buffer-related variables
var dir_input_buffer: Vector2			# Holds last direction input to check for double taps
const DIR_BUFFER_DELAY: float = 0.5	# Buffer flushed/emptied after DIR_BUFFER_DELAY
var dir_buffer_counter: float = 0:		# Counter that will WARNING loop automatically (setter) until DIR_BUFFER_DELAY
	set(value):
		dir_buffer_counter = value
		if value >= DIR_BUFFER_DELAY:
			dir_input_buffer = Vector2.ZERO
			dir_buffer_counter = 0
#endregion

var acceleration: float

var dash_cooldown_time: float = 1
var dash_enable: bool = true:			# NOTE: Automatically sets sprite transparency (setter)
	set(value):
		dash_enable = value
		modulate.a = 1.0 if value else 0.5


func _ready() -> void:
	bullet_trajectory.get_node("RayCast2D").add_exception(self)

func _physics_process(delta: float) -> void:
	#printt("%0.2f"%dir_buffer_counter, dir_input_buffer, dir, dir == dir_input_buffer and dir)
	dir = Input.get_vector("left", "right", "up", "down")
	move_and_slide()
	_flip_sprite_if_leftward()
	_handle_collisions()

	dir_buffer_counter += delta # Regularly reset (every DIR_BUFFER_DELAY) by his setter

func _flip_sprite_if_leftward():
	sprite.flip_h = get_real_velocity().x < 0 and get_real_velocity().length() > 100 # HACK to fix flickering sprites when running against collisions

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
	collider.apply_central_impulse(impulse)
	velocity = -impulse
