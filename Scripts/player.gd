extends Cowboy

@export var dash_force: float = speed * 5

var input_types: Dictionary[String, Array] = {"movement": ["left", "right", "up", "down"], "special": ["shoot"]}

var dir_input_buffer: Vector2			# Holds last direction input to check for double taps
const DIR_BUFFER_DELAY: float = 0.7	# Buffer flushed/emptied after DIR_BUFFER_DELAY
var dir_buffer_counter: float = 0:		# Counter that will loop until DIR_BUFFER_DELAY
	set(value):
		if value >= DIR_BUFFER_DELAY:
			dir_buffer_counter = 0
			dir_input_buffer = Vector2.ZERO
		
var dir: Vector2 = Input.get_vector("left", "right", "up", "down")
var dash_cooldown_time: float = 1

var dash_enable: bool = true:
	set(value):
		dash_enable = value
		modulate.a = 1 if value else 0.5

func _physics_process(delta: float) -> void:
	print($FSM.curr_state, velocity.length(), dir_input_buffer, dir)
	dir = Input.get_vector("left", "right", "up", "down")
	move_and_slide()
	dir_buffer_counter += delta # Regularly reset (every DIR_BUFFER_DELAY) by his setter
		
	
