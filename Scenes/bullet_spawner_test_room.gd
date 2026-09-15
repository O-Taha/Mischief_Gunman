extends Node2D

func _ready() -> void:
	$BulletSpawner.target_node = $Marker2D
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"): $BulletSpawner.target = get_global_mouse_position()
	if Input.is_action_just_pressed("up"): $BulletSpawner.start()
	if Input.is_action_just_pressed("down"): $BulletSpawner.stop()
