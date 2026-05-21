@tool
extends State

const MAX_WANDER_TIME: float = 5.0
@onready var MAX_SPEED: float = owner.speed
var wander_time: float

var middle_ray: RayCast2D
var initial_ray_target: Vector2

signal new_dest(coord: Vector2) # DEBUG

func _ready() -> void:
	middle_ray = $"../../WanderRay"
	initial_ray_target = middle_ray.target_position
	assert(initial_ray_target == Vector2(500.0, 0.0))

const WALL_BUFFER := 80.0


func randomize_move():
	wander_time = 0.0
	owner.dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	owner.speed = randf_range(MAX_SPEED/2, MAX_SPEED)
	while(wander_time < 0.5):
		owner.dir = owner.dir.rotated(PI/8)
		middle_ray.target_position = initial_ray_target.rotated(owner.dir.angle())
		middle_ray.force_raycast_update()
		if middle_ray.is_colliding():
			var distance_to_obstacle: float = middle_ray.to_local(middle_ray.get_collision_point()).length()
			# WARNING : Doesn't detect NonCoverProps
			wander_time = (distance_to_obstacle - WALL_BUFFER) / owner.speed
			new_dest.emit((distance_to_obstacle - WALL_BUFFER)*owner.dir) # DEBUG
		else: 
			wander_time = randf_range(1.0, MAX_WANDER_TIME)
			new_dest.emit(middle_ray.target_position) # DEBUG
		
		
func enter():
	randomize_move()

func physics_update(delta: float):
	if wander_time > 0:	wander_time -= delta
	else:
		randomize_move()
	owner.velocity = owner.dir * (owner.speed)
	
