extends RayCast2D

var initial_length: float = 500.0
var prop: Object = null

var player: Object = null
@export var alert_by_distance_curve: Curve
var player_seen_gauge_fill_rate: float = 1000:
	get:
		player_seen_gauge_fill_rate *= 2
		return player_seen_gauge_fill_rate

@onready var opponent: Cowboy = owner.owner

func _ready() -> void:
	for non_cover_prop in get_tree().get_nodes_in_group("not_a_cover_prop"):
		add_exception(non_cover_prop)

func _physics_process(delta: float) -> void:
	target_position = target_position.normalized() * initial_length
	force_raycast_update()
	if is_colliding():
		target_position = target_position.limit_length(to_local(get_collision_point()).length())
		prop = get_collider() if get_collider() is Prop else null
		player = get_collider() if get_collider() is Player else null
		if player: 
			var distance_to_player: float = opponent.to_local(player.global_position).length()/get_viewport_rect().size.y
			opponent.saw_something_moved((delta * player_seen_gauge_fill_rate) * alert_by_distance_curve.sample_baked(distance_to_player))
			if opponent.fsm.curr_state.name == "o_hunt": opponent.fsm.curr_state.transitioned.emit(opponent.fsm.curr_state, "o_shoot")
		if prop and prop.is_moving: opponent.saw_something_moved(prop.linear_velocity.length() * delta)
