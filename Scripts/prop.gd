@tool
extends RigidBody2D

var display_debug_vector: bool = true

const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
var components: int = 0

func _get_components():
	for component in find_children("*Component"):
		components |= get(component.name.to_snake_case().to_upper())
		
func has_component(component_mask: int) -> bool:
	return components & component_mask

func _ready() -> void:
	_get_components()

func _physics_process(delta: float) -> void:
	if $VelocityVector and display_debug_vector:
		$VelocityVector.target_position = linear_velocity/30



func die():
	queue_free()
