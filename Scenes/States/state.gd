@tool
class_name State
extends Node

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
	
func check_for_dash():
	for direction in owner.input_types["movement"]:
		if Input.is_action_just_pressed(direction):
			if owner.dir == owner.dir_input_buffer and owner.dash_enable:
				transitioned.emit(self, "dash")
			owner.dir_input_buffer = owner.dir

func check_for_shoot():
	if Input.is_action_just_pressed('shoot'):
				transitioned.emit(self, "shoot")
