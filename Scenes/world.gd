extends Node2D

var current_level_res: Resource = load("res://Scenes/Levels/level_1.tscn")
var current_level: Node2D

func _ready() -> void:
	current_level = current_level_res.instantiate()
	current_level.position = Vector2.UP * get_viewport_rect().size.y/2
	add_child(current_level)
	current_level.owner = self
