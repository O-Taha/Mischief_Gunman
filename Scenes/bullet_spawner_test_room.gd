extends Node2D

func _ready() -> void:
	#$BulletSpawner.target_node = $Marker2D
	$BulletSpawner.start()
	var tween := create_tween()
	tween.tween_property(
		$BulletSpawner,
		"target_angle",
		0.0,
		5.0
	).from(PI/2) # Careful, don't forget unit circle is also reversed, just like the Y axis
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"): 
		$BulletSpawner.enable = Input.is_action_pressed("shoot")
		$BulletSpawner.target = get_global_mouse_position()
	if Input.is_action_just_released("shoot"): $BulletSpawner.enable = Input.is_action_pressed("shoot")
	if Input.is_action_just_pressed("up"): 
		$BulletSpawner.start()
	if Input.is_action_just_pressed("down"): 
		$BulletSpawner.stop()
