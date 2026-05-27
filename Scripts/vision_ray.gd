extends RayCast2D

var initial_length: float = 500.0
var collider: Object = self # Random ahh default value

func _ready() -> void:
	for non_cover_prop in get_tree().get_nodes_in_group("not_a_cover_prop"):
		print()
		add_exception(non_cover_prop)

func _physics_process(delta: float) -> void:
	if collider.is_connected("moved", owner.owner.saw_this_moved): collider.disconnect("moved", owner.owner.saw_this_moved)
	target_position = target_position.normalized() * initial_length
	force_raycast_update()
	if is_colliding():
		target_position = target_position.limit_length(to_local(get_collision_point()).length())
		collider = get_collider() 
		if collider.has_signal("moved"): collider.moved.connect(owner.owner.saw_this_moved)
