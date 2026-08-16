extends Node2D

@export_category("Nodes & Scenes")
@export var pointLight: PointLight2D
@onready var opponent: Cowboy = owner

@export var alert_by_distance_curve: Curve

var player_seen_by_ray: Array[bool] = [false, false, false, false, false]
var player_in_sight: bool

func _ready() -> void:
	for i in get_child_count():
		var ray = get_child(i)
		if "ray_id" in ray:
			ray.ray_id = i

func _physics_process(_delta: float) -> void:
	if player_seen_by_ray.any(func(x): return x):
		player_in_sight = true
		turn_cone_red()
		if opponent.fsm.curr_state.name == "o_hunt" and opponent.shoot_enable and not opponent.dead: 
				opponent.fsm.curr_state.transitioned.emit(opponent.fsm.curr_state, "o_shoot")
	else:
		player_in_sight = false
		turn_cone_blue()
		

func turn_cone_blue():
	pointLight.energy = 0.1
	pointLight.blend_mode = Light2D.BLEND_MODE_SUB

func turn_cone_red():
	pointLight.energy = 10.0
	pointLight.blend_mode = Light2D.BLEND_MODE_MIX
