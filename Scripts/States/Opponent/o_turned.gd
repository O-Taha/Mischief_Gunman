@tool
extends State

func enter():
	owner.dir = Vector2.UP

func turn_around(hunt: bool = false):
	if hunt:
		transitioned.emit(self, "o_hunt")
	else:
		transitioned.emit(self, "o_passive")
