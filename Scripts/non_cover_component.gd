class_name CoverComponent
extends Node2D
# This component allows prop to pass rays from the opponent's vision cone which doesn't
# make them a proper cover :
	# Used for objects that wouldn't block the view (eg. a hole, a bottle, ...)

func _ready() -> void:
	var parent = get_parent()
	if parent:
		parent.add_to_group("not_a_cover_prop", true)
