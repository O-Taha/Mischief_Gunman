extends Node2D

func _process(_delta) -> void:
	$HomingNode.target = get_global_mouse_position()
