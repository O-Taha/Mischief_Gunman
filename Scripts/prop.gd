@tool
class_name Prop 
extends RigidBody2D

var display_debug_vector: bool = true

const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
const NON_COVER_COMPONENT: int = 4
const IMMOVABLE_COMPONENT: int = 8
var added_components: int = 0

signal sound_emitted(global_position: Vector2, volume: int)

var is_moving: bool = false
@export var sfx_name: StringName = "TEST"
@export_range(0.0, 3.0) var sfx_volume: int = 1

func _set_added_components():
	for component in find_children("*Component*"):
		added_components |= get(component.name.to_snake_case().to_upper())
		
func has_component(component_mask: int) -> bool:
	return added_components & component_mask

func _ready() -> void:
	_set_added_components()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"): apply_central_impulse(Vector2.LEFT * 100) # DEBUG
	if $VelocityVector and display_debug_vector:
		$VelocityVector.target_position = linear_velocity/30
	if linear_velocity: is_moving = true
	else: is_moving = false

func push(impulse: Vector2):	# Just a wrapper for moving props, 
						# to easily emit the signals and create setter-like behaviour
	var old_pos = position
	apply_central_impulse(impulse)
	emit_sound()
	
func emit_sound():
	SfxPlayer.play_sfx(sfx_name)
	sound_emitted.emit(global_position, sfx_volume)

func die():
	queue_free()
