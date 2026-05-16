extends Cowboy

@export_category("Nodes & Scenes")
@export var FSM: FSM

const MAX_ALERT: float = 100.0
var alert_gauge: float = 0.0:
	set(value):
		if alert_gauge == MAX_ALERT: return
		if value >= MAX_ALERT:
			alert_gauge = MAX_ALERT #↓ HACK ↓ : States should be the 
			# only ones to change current state but easier 
			#than checking current state then calling  the state's function...
			FSM.curr_state.transitioned.emit(FSM.curr_state, "o_hunt")
		else: alert_gauge = value
		
var new_dest: Vector2 = position # DEBUG
			
			
func _ready() -> void:
	$FSM/o_passive.new_dest.connect(draw_debug)

func _physics_process(_delta: float) -> void:
	queue_redraw() 
	if move_enable:
		move_and_slide()
		$VisionCone.rotation = dir.angle()

func draw_debug(coord: Vector2):
	new_dest = coord
	queue_redraw()
		
func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(80, -20), FSM.curr_state.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.LIGHT_BLUE)
	if FSM.curr_state.name == "o_passive": draw_string(ThemeDB.fallback_font, Vector2(0, -50), str(roundf(FSM.curr_state.wander_time)), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.LIGHT_BLUE)
	draw_line(Vector2.ZERO, new_dest, Color.BLUE, 7.0)
