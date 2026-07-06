@tool
class_name Prop 
extends RigidBody2D

var display_debug_vector: bool = true

const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
const NON_COVER_COMPONENT: int = 4
const IMMOVABLE_COMPONENT: int = 8
var added_components: int = 0


var is_moving: bool = false
@onready var initial_scale: Vector2 = $AnimatedSprite2D.scale

signal sound_emitted(global_position: Vector2, volume: int)
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
	if not Engine.is_editor_hint():
		if $VelocityVector and display_debug_vector: # DEBUG
			$VelocityVector.target_position = linear_velocity/30
			
		var speed: float= linear_velocity.length()
		if speed > 50.0:
			is_moving = true
			var target_skew: float = clamp(linear_velocity.normalized().x/5, -PI/4, PI/4)
			var stretch: float = clamp(abs(linear_velocity.y)/(1000.0*target_skew), 0.0, initial_scale.x/4)
			var target_scale: Vector2 = Vector2(initial_scale.x-stretch, initial_scale.y+stretch) # Volume Conservation
			$AnimatedSprite2D.scale = $AnimatedSprite2D.scale.lerp(target_scale, delta * 10.0)
			$AnimatedSprite2D.skew = lerp($AnimatedSprite2D.skew, target_skew, delta * 10.0)
		else: 
			is_moving = false
			$AnimatedSprite2D.scale = $AnimatedSprite2D.scale.lerp(initial_scale, delta * 10.0)
			$AnimatedSprite2D.skew = lerp($AnimatedSprite2D.skew, 0.0, delta * 10.0)
	
func push(impulse: Vector2):	# Just a wrapper for moving props, 
						# to easily emit the signals and create setter-like behaviour
	apply_central_impulse(impulse)
	emit_sound()
	
func emit_sound():
	SfxPlayer.play_sound(sfx_name)
	sound_emitted.emit(global_position, sfx_volume)

func die():
	queue_free()
