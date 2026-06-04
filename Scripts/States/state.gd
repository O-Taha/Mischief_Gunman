@tool
class_name State 
extends Node

@export var FSM: FSM = get_parent()
signal transitioned(curr_state: State, new_state_name: String)

func _ready() -> void:
	name = get_script().resource_path.get_file().get_basename() # To name the node after the script

func enter():
	pass

func exit():
	pass

func update(delta: float):
	pass

func physics_update(delta: float):
	pass
	
func check_for_shoot():
	if Input.is_action_just_pressed('shoot'):
				transitioned.emit(self, "shoot")
