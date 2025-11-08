class_name Player 
extends Cowboy

signal collided(vel) # Will be used for screen shake

@export var dash_force: float = speed * 5

var input_types: Dictionary[String, Array] = \
{"movement": ["left", "right", "up", "down"], "special": ["shoot"]}

var dir: Vector2 = Input.get_vector("left", "right", "up", "down") # holds inputed direction for comparison with dir_input_buffer
@onready var curr_state: StringName = $FSM.curr_state.name

#region Dash buffer-related variables
var dir_input_buffer: Vector2			# Holds last direction input to check for double taps
const DIR_BUFFER_DELAY: float = 0.5	# Buffer flushed/emptied after DIR_BUFFER_DELAY
var dir_buffer_counter: float = 0:		# Counter that will WARNING loop automatically (setter) until DIR_BUFFER_DELAY
	set(value):
		dir_buffer_counter = value
		if value >= DIR_BUFFER_DELAY:
			dir_input_buffer = Vector2.ZERO
			print('a')
			dir_buffer_counter = 0
#endregion

var dash_cooldown_time: float = 1
var dash_enable: bool = true:			# NOTE: Automatically sets sprite transparency (setter)
	set(value):
		dash_enable = value
		modulate.a = 1.0 if value else 0.5

func _physics_process(delta: float) -> void:
	printt(curr_state, dir_buffer_counter, dir_input_buffer, dir, dir_input_buffer == dir)
	dir = Input.get_vector("left", "right", "up", "down")
	move_and_slide()
	
	sprite.flip_h = get_real_velocity().x < 0 and get_real_velocity().length() > 100 # HACK to fix flickering sprites when running against collisions
	
	for i in get_slide_collision_count(): # Credits to KidsCanCode (https://kidscancode.org/godot_recipes/4.x/physics/character_vs_rigid/index.html)
		var collision_info: KinematicCollision2D = get_slide_collision(i)
		var curr_vel: Vector2 = get_real_velocity()
		var collider: Object = collision_info.get_collider()
		if collider is RigidBody2D and (velocity.length() >= speed):
			collided.emit(curr_vel)
			_apply_opposite_force_to_self_and_collider(collision_info, collider)
			

	dir_buffer_counter += delta # Regularly reset (every DIR_BUFFER_DELAY) by his setter
		
	
func _apply_opposite_force_to_self_and_collider(collision_info: KinematicCollision2D, collider: Object):
	var impulse: Vector2 = (-collision_info.get_normal()*velocity.length())\
										/(collider.mass*1.5)
	collider.apply_central_impulse(impulse)
	velocity = -impulse
