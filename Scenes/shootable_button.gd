@tool
extends RichTextLabel
var function: Callable

@export_category("Nodes & Scenes")
@export var collision: RigidBody2D
@export var collision_shape: CollisionShape2D

func _ready() -> void:
	if not Engine.is_editor_hint(): collision.hit.connect(_on_hit)
	
	var button_shape = RectangleShape2D.new()
	button_shape.size = size
	collision_shape.shape = button_shape
	collision.position = size/2
	
func _on_hit():
	function.call()
	queue_free()
