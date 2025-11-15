extends Line2D

const LENGTH: float = 200
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
		temp_points.append(Vector2.ZERO)
		end = get_local_mouse_position()
		while length_left >= 0:
			$RayCast2D.target_position = end.limit_length(length_left)
			$RayCast2D.force_raycast_update()
			if $RayCast2D.is_colliding():
				var collision_point: Vector2 = $RayCast2D.get_collision_point()
				temp_points.append(to_local(collision_point))
				length_left -= $RayCast2D.to_local(collision_point).length()
				while not $RayCast2D.get_collision_normal().length():
					collision_point.move_toward($RayCast2D.position, 1)
					$RayCast2D.target_position.move_toward($RayCast2D.position, 1)
					$RayCast2D.force_raycast_update()
					if not $RayCast2D.is_colliding(): break
				end = $RayCast2D.to_local(collision_point).bounce($RayCast2D.get_collision_normal())
				$RayCast2D.position = to_local(collision_point)
			else:
				temp_points.append(to_local($RayCast2D.to_global($RayCast2D.target_position)))
				break
		print(points)
		points = temp_points
		$RayCast2D.position = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = true

func _draw() -> void:
	for p in temp_points:
		draw_circle(p, 10, Color.RED)
	draw_circle(end, 10, Color.GREEN) 
