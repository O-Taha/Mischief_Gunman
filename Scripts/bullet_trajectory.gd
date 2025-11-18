extends Line2D

const LENGTH: float = 300
var length_left: float = LENGTH
var end: Vector2
var temp_points: PackedVector2Array:
	set(value):
		temp_points = value
		queue_redraw()
		
var mouse_movement: bool = false
var player_movement: bool = false

func _process(delta: float) -> void:
	if owner: player_movement = true if owner.velocity else false
	if mouse_movement or player_movement:
		mouse_movement = false
		temp_points.clear()
		length_left = LENGTH
		$RayCast2D.position = Vector2.ZERO
		$RayCast2D.target_position = Vector2.ZERO
		$RayCast2D.force_raycast_update()
		temp_points.append(Vector2.ZERO)
		end = get_local_mouse_position()
		while length_left >= 0:
			$RayCast2D.target_position = end.limit_length(length_left) # end is always local to RayCast2D
			$RayCast2D.force_raycast_update()
			if $RayCast2D.is_colliding():
				print($RayCast2D.get_collision_normal())
				if not $RayCast2D.get_collision_normal().length(): 
					$RayCast2D.position = Vector2.ZERO #HACK Should return to previous position, not reset position
				var collision_point: Vector2 = $RayCast2D.get_collision_point()
				temp_points.append(to_local(collision_point))
				length_left -= $RayCast2D.position.distance_to(to_local(collision_point))
				end = $RayCast2D.to_local(collision_point).bounce($RayCast2D.get_collision_normal())
				$RayCast2D.position = to_local(collision_point) + $RayCast2D.get_collision_normal()
				$RayCast2D.force_raycast_update()
			else:
				temp_points.append(to_local($RayCast2D.to_global($RayCast2D.target_position)))
				break
		printt(points)
		points = temp_points

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = true

func _draw() -> void:
	for p in temp_points:
		draw_circle(p, 10, Color.RED)
		draw_string_outline(ThemeDB.fallback_font, p+Vector2.ONE, "%.0f; %.0f" % [p.x, p.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color.RED)
		draw_string(ThemeDB.fallback_font, p, "%.0f; %.0f" % [p.x, p.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.YELLOW)

	draw_circle(to_local($RayCast2D.to_global(end)), 10, Color.GREEN) 
	draw_string_outline(ThemeDB.fallback_font, end+Vector2.ONE, "%.0f; %.0f" % [end.x, end.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 4, Color.GREEN)
	draw_string(ThemeDB.fallback_font, end, "%.0f; %.0f" % [end.x, end.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.LIGHT_BLUE)
