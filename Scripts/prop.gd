@tool
class_name Prop 
extends RigidBody2D

var display_debug_vector: bool = true

@export_category("Nodes & Scenes")
@export var bullet_detector: RigidBody2D
@export var animatedSprite: AnimatedSprite2D

const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
const NON_COVER_COMPONENT: int = 4
const IMMOVABLE_COMPONENT: int = 8
var added_components: int = 0

var is_moving: bool = false
@onready var initial_scale: Vector2 = $AnimatedSprite2D.scale

@export var sound_name: StringName = "TEST"
@export_range(0.0, 3.0) var sound_volume: int = 1

var spin_tween: Tween

func _set_added_components():
	for component in find_children("*Component*"):
		added_components |= get(component.name.to_snake_case().to_upper())
		
func has_component(component_mask: int) -> bool:
	return added_components & component_mask

func _ready() -> void:
	_set_added_components()
	animatedSprite.frame = randi_range(0, animatedSprite.sprite_frames.get_frame_count("spin"))
	
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
	if has_component(IMMOVABLE_COMPONENT): return
	if sound_name and sound_volume: SfxPlayer.play_sound(sound_name, sound_volume, global_position)
	
	play_spin(impulse.length())
	apply_central_impulse(impulse)

func play_spin(strength: float):
	if spin_tween: spin_tween.kill()
	
	var start_speed: float = sqrt(strength*5/get_tree().get_first_node_in_group("Player").speed)
	var duration: float = start_speed/1.1
	
	prints(start_speed, duration)
	animatedSprite.play()
	animatedSprite.speed_scale = start_speed
	
	spin_tween = create_tween()
	spin_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	spin_tween.tween_property(animatedSprite, "speed_scale", 0.0, duration)


func die():
	queue_free()
