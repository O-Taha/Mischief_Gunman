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
			

func _physics_process(_delta: float) -> void:
	if move_enable:
		move_and_slide()
		$VisionCone.rotation = dir.angle()		
