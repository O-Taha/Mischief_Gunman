extends Node2D

@export_category("Nodes & Scenes")
@export var opponent: Cowboy

func disable_opponent_physics():
	opponent.set_physics_process(false)
	opponent.collision.set_deferred("disabled", true)

func enable_opponent_physics():
	opponent.set_physics_process(true)
	opponent.collision.set_deferred("disabled", false)
