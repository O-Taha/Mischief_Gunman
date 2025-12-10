extends Node
class_name FSM

@export var init_state: State
var curr_state: State
var states: Dictionary[StringName, State]

func _ready() -> void:
	for child in get_children():
		states[child.name] = child
		child.transitioned.connect(transition)
	
	if init_state:
		curr_state = init_state
		init_state.enter()
		
func _process(delta: float) -> void:
	if curr_state:
		curr_state.update(delta)

func _physics_process(delta: float) -> void:
	if curr_state:
		curr_state.physics_update(delta)
		
		
func transition(curr: State, new_state_name: String):
	if curr != curr_state or new_state_name not in states: # Don't transition based on signals from states other than current
		return
		
	var new: State = states[new_state_name]
	
	if curr:
		curr.exit()
	if new:
		new.enter()
	
	curr_state = new
