@tool
class_name Prop 
extends RigidBody2D

var display_debug_vector: bool = true

const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
const NON_COVER_COMPONENT: int = 4
const IMMOVABLE_COMPONENT: int = 8
var added_components: int = 0

signal moved(distance: Vector2)

func _set_added_components():
	for component in find_children("*Component*"):
		added_components |= get(component.name.to_snake_case().to_upper())
		
func has_component(component_mask: int) -> bool:
	return added_components & component_mask

func _ready() -> void:
	_set_added_components()

func _physics_process(delta: float) -> void:
	if $VelocityVector and display_debug_vector:
		$VelocityVector.target_position = linear_velocity/30

func push(impulse: Vector2):	# Just a wrapper for moving props, 
						# to easily emit the moved signal (
						#since we can hardly modify the position setter...)
	var old_pos = position
	apply_central_impulse(impulse)
	moved.emit(impulse)
	print(impulse)

func die():
	queue_free()
