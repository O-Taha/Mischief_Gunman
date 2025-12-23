@tool
extends State

const MIN_LENGTH_WITHOUT_OBSTACLE: float = 256.0

const MAX_WANDER_TIME: float = 2.0
var wander_time: float

var middle_ray: RayCast2D
var initial_ray_target: Vector2

func _ready() -> void:
	middle_ray = owner.get_node("VisionCone/VisionRay1")
	initial_ray_target = middle_ray.target_position
	assert(initial_ray_target == Vector2(500.0, 0.0))

func randomize_move():
	owner.dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, MAX_WANDER_TIME)
	
	middle_ray.target_position = initial_ray_target
	middle_ray.target_position =middle_ray.target_position.rotated(owner.dir.angle())
	middle_ray.force_raycast_update()
	if middle_ray.is_colliding():
		var distance_to_obstacle: float = middle_ray.to_local(middle_ray.get_collision_point()).length()
		if distance_to_obstacle < MIN_LENGTH_WITHOUT_OBSTACLE:
			# WARNING : Doesn't detect NonCoverProps
			wander_time = distance_to_obstacle/owner.speed

func enter():
	randomize_move()

func update(delta: float):
	if wander_time > 0:	wander_time -= delta
	else:
		randomize_move()
		middle_ray.target_position = initial_ray_target

func physics_update(_delta: float):
	owner.velocity = owner.velocity.lerp(owner.dir * (owner.speed + randf_range(-150, 0)), 0.1)
	print(owner.velocity.length())
