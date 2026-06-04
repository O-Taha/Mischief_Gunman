class_name Player 
extends Cowboy

signal collided(vel) # Will be used for screen shake

@export_category("Nodes & Scenes")
@export var bullet_trajectory: Line2D
@export var collision: CollisionShape2D

@export var dash_force: float = speed * 5

var input_types: Dictionary[String, Array] = \
{"movement": ["left", "right", "up", "down"], "special": ["shoot"]}

#region Dash variables
enum DashCheckState {
	IDLE,
	FIRST_INPUT,
	DELAY,
	SECOND_INPUT
}

var dash_check_state: DashCheckState = DashCheckState.IDLE:
	set(value):
		dash_check_state = value
		dir_buffer_counter = 0.0 # Reset the counter to give time again to perform the next operation
const DIR_BUFFER_DELAY := 0.15	# Buffer flushed/emptied after DIR_BUFFER_DELAY
var first_input_dir := Vector2.ZERO
var dir_buffer_counter: float = 0.0

var dash_cooldown_time: float = 1.0
var dash_enable: bool = true:			# NOTE: Automatically sets sprite transparency (setter)
	set(value):
		dash_enable = value
		modulate.a = 1.0 if value else 0.5
#endregion

var acceleration: float # Used to check we just did a dash, since checking dash state isn't enough as it is transient


func _ready() -> void:
	bullet_trajectory.get_node("RayCast2D").add_exception(self)

func _physics_process(delta: float) -> void:
	dir = Input.get_vector("left", "right", "up", "down")
	if dash_enable: check_for_dash(delta)
	move_and_slide()
	_flip_sprite_if_leftward()
	_handle_collisions()

func check_for_dash(delta: float) -> void: # A dash is achieved by pressing a direction
								# releasing, then pressing the same direction.
								# The FSM below checks for this pattern
	dir_buffer_counter += delta
	if dir_buffer_counter >= DIR_BUFFER_DELAY:
		reset_dash_check() # Too bad... Not quick enough !
		return

	match dash_check_state:
		DashCheckState.IDLE:
			if dir != Vector2.ZERO:
				first_input_dir = dir
				dash_check_state = DashCheckState.FIRST_INPUT

		DashCheckState.FIRST_INPUT:
			if dir == Vector2.ZERO:
				dash_check_state = DashCheckState.DELAY

		DashCheckState.DELAY:
			if dir != Vector2.ZERO:
				if dir.is_equal_approx(first_input_dir):
					dash_check_state = DashCheckState.SECOND_INPUT
					$FSM.curr_state.transitioned.emit($FSM.curr_state,"dash")
					reset_dash_check()
				else: # Not the same direction
					reset_dash_check()
		
func reset_dash_check():
	dash_check_state = DashCheckState.IDLE
	#dir_buffer_counter = 0.0 #Already performed through dash_check_state's setter
	first_input_dir = Vector2.ZERO
	
func _flip_sprite_if_leftward():
	if dir:
		sprite.flip_h = dir.x < 0 
		# and get_real_velocity().length() > 100 HACK to fix flickering sprites when running against collisions

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
	velocity = -impulse
