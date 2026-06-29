extends Cowboy

@export_category("Nodes & Scenes")
@export var FSM: FSM
@export var player: Player
@export var collision: CollisionShape2D

const MAX_ALERT: float = 100.0
var alert_gauge: float = 0.0:
	set(value):
		if alert_gauge == MAX_ALERT: return
		if value >= MAX_ALERT:
			alert_gauge = MAX_ALERT #↓ HACK ↓ : States should be the 
			# only ones to change current state but easier 
			#than checking current state then calling  the state's function...
			FSM.curr_state.transitioned.emit(FSM.curr_state, "o_hunt")
		else: 
			alert_gauge = value
		$AlertGauge.value = alert_gauge
		
var new_dest: Vector2 = position # DEBUG : used for o_passive wandering direction
var audible_props: Array[Prop]

			
func _ready() -> void:
	$FSM/o_passive.new_dest.connect(update_debug_dest)
	$HearingRadius.body_entered.connect(update_audible_prop_list.bind(true))
	$HearingRadius.body_exited.connect(update_audible_prop_list.bind(false))
	if player: player.died.connect(_on_player_died)
	
func _physics_process(delta: float) -> void:
	super(delta)
	queue_redraw()
	if move_enable:
		_handle_collisions()
		move_and_slide()
		$VisionCone.rotation = dir.angle()

func _push_prop(collider: Object, direction: Vector2):
	var impulse_dir = Vector2.from_angle(lerp_angle((direction).angle(), dir.angle()+PI, 0.5))
	var impulse: Vector2 = (impulse_dir*2*velocity.length())\
							/(collider.mass*1.5)
	_apply_opposite_force_to_self_and_collider(impulse, collider)

func update_debug_dest(coord: Vector2):
	new_dest = coord
	queue_redraw()
	
func saw_prop_moved(speed: float):
	alert_gauge += speed/10

func heard_prop_moved(prop_global_position: Vector2, volume: int):
	alert_gauge += (volume * 1000)/(global_position.distance_to(prop_global_position))

func update_audible_prop_list(body:Node2D, add_prop: bool):
	if add_prop: # body_entered
		body.sound_emitted.connect(heard_prop_moved)
	else: # body_exited
		body.sound_emitted.disconnect(heard_prop_moved)
		
func _on_player_died():
	FSM.curr_state.transitioned.emit(FSM.curr_state, "o_win")
	

func die():
	super.die()
	move_enable = false
	died.emit()

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(80, -20), FSM.curr_state.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
	if FSM.curr_state.name == "o_passive": draw_string(ThemeDB.fallback_font, Vector2(0, -50), str(roundf(FSM.curr_state.wander_time)), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.LIGHT_BLUE)
	if FSM.curr_state.name == "o_hunt": 
		draw_string(ThemeDB.fallback_font, Vector2(50, 0), "finished: %s" % $NavigationAgent2D.is_navigation_finished(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
		draw_string(ThemeDB.fallback_font, Vector2(50, 20), "reachable: %s" % $NavigationAgent2D.is_target_reachable(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
		draw_string(ThemeDB.fallback_font, Vector2(50, 40), "reached: %s" % $NavigationAgent2D.is_target_reached(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
	draw_string(ThemeDB.fallback_font, Vector2(-50, -70), "Collision: %s Velocity: %s" % [get_slide_collision_count(), velocity], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
	draw_line(Vector2.ZERO, new_dest, Color.BLUE, 7.0)
