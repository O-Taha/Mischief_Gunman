@tool
extends State

const MAX_WANDER_TIME: float = 5.0
@onready var MAX_SPEED: float = owner.speed
var wander_time: float

@export var obstacle_checker: ShapeCast2D
var initial_target: Vector2

signal new_dest(coord: Vector2) # DEBUG

func _ready() -> void:
	initial_target = obstacle_checker.target_position
	assert(initial_target == Vector2(500.0, 0.0))

const WALL_BUFFER: float = 60.0

func randomize_move():
	owner.speed = randf_range(MAX_SPEED/2, MAX_SPEED)

	owner.desired_dir = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()

	obstacle_checker.target_position = initial_target.rotated(owner.desired_dir.angle())
	obstacle_checker.force_shapecast_update()

	var distance := initial_target.length() * obstacle_checker.get_closest_collision_safe_fraction()

	wander_time = (distance - WALL_BUFFER) / owner.speed

	new_dest.emit(distance * owner.desired_dir)  # DEBUG
		
		
func enter():
	randomize_move()

func physics_update(delta: float):
	if wander_time > 0:	
		wander_time -= delta
	else:
		randomize_move()
	owner.dir = owner.dir.slerp(owner.desired_dir, owner.turn_speed * delta).normalized()
	owner.velocity = owner.dir * owner.speed
	if Input.is_action_just_pressed("ui_focus_next"): 
		transitioned.emit(self, "o_hunt") # DEBUG
