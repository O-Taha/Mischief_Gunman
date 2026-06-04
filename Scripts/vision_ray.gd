extends RayCast2D

var initial_length: float = 500.0
var prop: Object = null
@onready var opponent: CharacterBody2D = owner.owner

func _ready() -> void:
	for non_cover_prop in get_tree().get_nodes_in_group("not_a_cover_prop"):
		add_exception(non_cover_prop)

func _physics_process(delta: float) -> void:
	target_position = target_position.normalized() * initial_length
	force_raycast_update()
	if is_colliding():
		target_position = target_position.limit_length(to_local(get_collision_point()).length())
		prop = get_collider() if get_collider() is Prop else null
		if prop and prop.is_moving: opponent.saw_prop_moved(prop.linear_velocity.length())
