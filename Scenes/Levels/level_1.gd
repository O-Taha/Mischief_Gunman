extends Node2D

@export_category("Nodes & Scenes")
@export var opponent: Cowboy

func _ready() -> void:
	opponent.move_enable = false
	opponent.shoot_enable = false
