class_name ImmovableComponent
extends Node2D

func _ready() -> void:
	var parent = get_parent()
	if parent and parent is Prop:
		parent.freeze = true
		
