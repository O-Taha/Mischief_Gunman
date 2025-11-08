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
		if value >= DIR_BUFFER_DELAY:
			dir_buffer_counter = 0
			dir_input_buffer = Vector2.ZERO
#endregion

var dash_cooldown_time: float = 1
var dash_enable: bool = true:			# NOTE: Automatically sets sprite transparency (setter)
	set(value):
		dash_enable = value
		modulate.a = 1 if value else 0.5

func _physics_process(delta: float) -> void:
	print_debug($FSM.curr_state, velocity.length(), dir_input_buffer, dir)
	dir = Input.get_vector("left", "right", "up", "down")
	move_and_slide()
	
	for i in get_slide_collision_count(): # Credits to KidsCanCode (https://kidscancode.org/godot_recipes/4.x/physics/character_vs_rigid/index.html)
		var collision_info = get_slide_collision(i)
		var curr_vel: Vector2 = get_real_velocity()
		var collider: Object = collision_info.get_collider()
		if collider is RigidBody2D and (velocity.length() >= speed):
			collided.emit(curr_vel)
			
			var impulse: Vector2 = (-collision_info.get_normal()*velocity.length())\
										/(collider.mass*1.5)
			collider.apply_central_impulse(impulse)
			velocity = -impulse
			

	dir_buffer_counter += delta # Regularly reset (every DIR_BUFFER_DELAY) by his setter
		
	
