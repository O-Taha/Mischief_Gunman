extends Line2D

const LINE_LENGTH: float = 300
var remaining_line_length: float = LINE_LENGTH
var raycast_target: Vector2
var line_points: PackedVector2Array: # PackedVector2Array can't directly be set, line_points is needed for points
	set(value):
		line_points = value
		queue_redraw()
		
var mouse_movement: bool = false
var player_movement: bool = false

func _physics_process(delta: float) -> void:
	if owner: player_movement = true if owner.velocity else false
	
	if mouse_movement or player_movement:
		mouse_movement = false
		_compute_line_of_sight()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = true

func _compute_line_of_sight() -> void:
	_reset_line_of_sight()
	_init_line_of_sight()
	while remaining_line_length >= 0:
		$RayCast2D.target_position = raycast_target.limit_length(remaining_line_length)	
								# raycast_target coordinate system :
								# local to RayCast2D
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			var collision_normal: Vector2 = $RayCast2D.get_collision_normal()
			var is_raycast_inside_collision: bool = not collision_normal.length()
			if is_raycast_inside_collision: $RayCast2D.position = Vector2.ZERO #HACK Should return to previous position, not reset position ?
			var collision_point: Vector2 = $RayCast2D.get_collision_point()	# collision_point coordinate system :
																# global
			line_points.append(to_local(collision_point))
			remaining_line_length -= $RayCast2D.position.distance_to(to_local(collision_point))
			raycast_target = $RayCast2D.to_local(collision_point).bounce($RayCast2D.get_collision_normal())*LINE_LENGTH
			var anti_hit_from_inside_offset: Vector2 = $RayCast2D.get_collision_normal()	
			_place_raycast_origin(to_local(collision_point), anti_hit_from_inside_offset)
		else:
			line_points.append(to_local($RayCast2D.to_global($RayCast2D.target_position)))
			break
	points = line_points

func _reset_line_of_sight() -> void:
	line_points.clear()
	remaining_line_length = LINE_LENGTH
	$RayCast2D.position = Vector2.ZERO
	$RayCast2D.target_position = Vector2.ZERO
	$RayCast2D.force_raycast_update()

func _init_line_of_sight() -> void:
	line_points.append(Vector2.ZERO)
	raycast_target = get_local_mouse_position()

func _place_raycast_origin(new_position: Vector2, offset: Vector2) -> void:
	# Raycast can spawn inside collision for surfaces w/ positive normals (1,0) or (0,1) :
		# maybe caused by rounding errors ?
		# causes normal equal to (0,0) : breaks raycast_target point computation
		# avoided by adding small offset : e.g. the normal itself
	$RayCast2D.position = new_position + offset
	$RayCast2D.force_raycast_update()

func _draw() -> void:
	for p in line_points:
		draw_circle(p, 10, Color.RED)
		draw_string_outline(ThemeDB.fallback_font, p+Vector2.ONE, "%.0f; %.0f" % [p.x, p.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color.RED)
		draw_string(ThemeDB.fallback_font, p, "%.0f; %.0f" % [p.x, p.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.YELLOW)

	draw_circle(to_local($RayCast2D.to_global(raycast_target)), 10, Color.GREEN) 
	draw_string_outline(ThemeDB.fallback_font, raycast_target+Vector2.ONE, "%.0f; %.0f" % [raycast_target.x, raycast_target.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color.GREEN)
	draw_string(ThemeDB.fallback_font, raycast_target, "%.0f; %.0f" % [raycast_target.x, raycast_target.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.LIGHT_BLUE)
