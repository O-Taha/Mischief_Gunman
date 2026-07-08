class_name Player 
extends Cowboy

@export_category("Nodes & Scenes")
@export var bullet_trajectory: Line2D

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
const DIR_BUFFER_DELAY := 0.1	# Buffer flushed/emptied after DIR_BUFFER_DELAY
var first_input_dir := Vector2.ZERO
var dir_buffer_counter: float = 0.0

var dash_cooldown_time: float = 1.0
var dash_enable: bool = true:			# NOTE: Automatically sets sprite transparency (setter)
	set(value):
		dash_enable = value
		modulate.a = 1.0 if value else 0.5
#endregion

func _ready() -> void:
	bullet_trajectory.get_node("RayCast2D").add_exception(self)

func _physics_process(delta: float) -> void:
	super(delta)
	if move_enable: dir = Input.get_vector("left", "right", "up", "down")
	if dash_enable: check_for_dash(delta)
	check_for_shoot()
	move_and_slide()
	_handle_collisions()

func check_for_dash(delta: float) -> void: # A dash is achieved by pressing a direction
								# releasing, then pressing the same direction.
								# The FSM below checks for this pattern
	dir_buffer_counter += delta
	if dir_buffer_counter >= DIR_BUFFER_DELAY:
		reset_dash_FSM() # Too bad... Not quick enough !
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
					fsm.curr_state.transitioned.emit(fsm.curr_state,"dash")
					reset_dash_FSM()
				else: # Not the same direction
					reset_dash_FSM()
					
func check_for_shoot():
	if Input.is_action_just_pressed('shoot'):
		fsm.curr_state.transitioned.emit(fsm.curr_state, "shoot")
		
func reset_dash_FSM():
	dash_check_state = DashCheckState.IDLE
	#dir_buffer_counter = 0.0 #Already performed through dash_check_state's setter
	first_input_dir = Vector2.ZERO
	
func die():
	super.die()
	
