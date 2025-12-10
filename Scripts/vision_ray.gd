extends RayCast2D

var initial_length: float = 500.0

func _ready() -> void:
	for non_cover_prop in get_tree().get_nodes_in_group("not_a_cover_prop"):
		print()
		add_exception(non_cover_prop)

func _physics_process(delta: float) -> void:
	target_position = target_position.normalized() * initial_length
	force_raycast_update()
	if is_colliding():
		target_position = target_position.limit_length(to_local(get_collision_point()).length())
		
