class_name Cowboy 
extends CharacterBody2D

@export var speed: float = 300

@export_category("Nodes & Scenes")
@export var bullet: PackedScene
@export var sprite: Node2D
var move_enable: bool = true

func shoot() -> Node2D:
	return null

func die():
	queue_free()
