class_name HomingNode
extends Node2D

enum TT {POS, NODE}
var target_type: TT = TT.POS

@export_category("Graphics")
@export var sprite: Texture
@export var blink_enable: bool = true
@export var blink_min_freq: float	= 0.0
@export var blink_max_freq: float	= 5.0
@export var blink_distance: float	= 100.0 # at which distance the blink starts and speeds up
var blink_time: float = 0.0

@export_category("Target")
@export var target_node: Node2D:
	set(value):
		target_type = TT.NODE
		target_node = value
var target: Vector2 = Vector2.ZERO: # expects global position
	set(value):
		target_type = TT.POS
		target = value

enum HT {LOCK, SMOOTH, WOOZY}
@export var homing_type: HT:
	set(value):
		homing_type = value
		var param: Array = homing_type_values[value]
		speed		= param[0]
		turn_speed	= param[1]
	
var homing_type_values: Dictionary[HT, Array] = {
	HT.LOCK: [100.0, 100.0],
	HT.SMOOTH: [10.0, 100.0],
	HT.WOOZY: [100.0, 1.0]
 }
@export_category("Homing")
@export var speed: float			= 100.0
@export var turn_speed: float		= 1.0
@export var target_acquired_radius: float	= 100.0

var curr_vel: Vector2 = Vector2.ZERO
var target_acquired: bool = false
var display_debug_target_acquired: bool = true


func get_target_position() -> Vector2:
	if target_type == TT.NODE:
		if not is_instance_valid(target_node):
			return global_position
		return target_node.global_position
	return target

func _physics_process(delta: float) -> void:
	await get_tree().process_frame # without it, target_acquired instantly turns true at the start
	
	var current_target: Vector2 = get_target_position()
	var distance: float = global_position.distance_to(current_target)
	if distance <= target_acquired_radius and curr_vel.length() < 100:
		target_acquired = true
	elif distance > target_acquired_radius * 1.1: # hysterisis condition to avoid flicker
		target_acquired = false
	queue_redraw()
	

	var desired_vel: Vector2 = global_position.direction_to(current_target) * distance * speed
	var weight: float = 1.0 - exp(-turn_speed * delta)
	curr_vel = curr_vel.lerp(desired_vel, weight)
	position += curr_vel * delta

	if blink_enable:
		if distance <= blink_distance:
			var proximity: float = 1.0 - clamp(distance/blink_distance, 0.0, 1.0) # 1 = close
			var freq: float = lerp(blink_min_freq, blink_max_freq, proximity)
			blink_time += delta * freq
			
			var pulse: float = (sin(blink_time * TAU) + 1.0) * 0.5
			modulate.a = lerp(0.3, 1.0, pulse)
		elif distance >= blink_distance * 1.1:
			modulate.a = 1.0
	else: modulate.a = 1.0
		

func _draw() -> void:
	var debug_target_acquired: Color = Color.WHITE
	if display_debug_target_acquired: debug_target_acquired = Color.CRIMSON if target_acquired else Color.WHITE # DEBUG
	draw_texture(sprite, -sprite.get_size()/2, debug_target_acquired)
