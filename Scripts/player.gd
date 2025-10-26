extends Cowboy

@export var dash_force: float = speed * 5

var input_types: Dictionary[String, Array] = {"movement": ["left", "right", "up", "down"], "special": ["shoot"]}

var input_buffer: Vector2
var buffer_delay: float = 0.7
var buffer_count: float = 0
var dir: Vector2 = Input.get_vector("left", "right", "up", "down")
var dash_cooldown: float = 1

var can_dash: bool = true

func _physics_process(delta: float) -> void:
	print($FSM.curr_state, velocity.length(), input_buffer, dir)
	dir = Input.get_vector("left", "right", "up", "down")
	move_and_slide()
	buffer_count += delta
		
	if buffer_count >= buffer_delay:
			buffer_count = 0
			input_buffer = Vector2.ZERO
