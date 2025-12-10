@tool
class_name Prop 
extends RigidBody2D

var display_debug_vector: bool = true

const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
var added_components: int = 0

func _set_added_components():
	for component in find_children("*Component"):
		added_components |= get(component.name.to_snake_case().to_upper())
		
func has_component(component_mask: int) -> bool:
	return added_components & component_mask

func _ready() -> void:
	_set_added_components()

func _physics_process(delta: float) -> void:
	if $VelocityVector and display_debug_vector:
		$VelocityVector.target_position = linear_velocity/30

func die():
	queue_free()
