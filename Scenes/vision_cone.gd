extends Node2D

@export_category("Nodes & Scenes")
@export var pointLight: PointLight2D

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
	else:
		player_in_sight = false
		turn_cone_blue()

func turn_cone_blue():
	pointLight.energy = 0.1
	pointLight.blend_mode = Light2D.BLEND_MODE_SUB

func turn_cone_red():
	pointLight.energy = 10.0
	pointLight.blend_mode = Light2D.BLEND_MODE_MIX
