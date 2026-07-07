extends Cowboy

@export_category("Nodes & Scenes")
@export var fsm: FSM
@export var collision: CollisionShape2D

@onready var player: Player = get_tree().get_first_node_in_group("Player")

const MAX_ALERT: float = 100.0
var alert_gauge: float = 0.0:
	set(value):
		if not move_enable: return # is probably waiting outside of screen waiting for next level to be loaded
		if alert_gauge == MAX_ALERT: return
		if value >= MAX_ALERT:
			alert_gauge = MAX_ALERT #↓ HACK ↓ : States should be the 
			# only ones to change current state but easier 
			#than checking current state then calling  the state's function...
			fsm.curr_state.transitioned.emit(fsm.curr_state, "o_hunt")
		else: 
			alert_gauge = value
		$AlertGauge.value = alert_gauge
@export var hearing_radius: Curve

var new_dest: Vector2 = position # DEBUG : used for o_passive wandering direction


func _ready() -> void:
	$FSM/o_passive.new_dest.connect(update_debug_dest)
	SfxPlayer.sound_emitted.connect(heard_something)
	if player: player.died.connect(_on_player_died) # if allows this scene to be used standalone for debug
	
func _physics_process(delta: float) -> void:
	super(delta)
	queue_redraw()
	if move_enable:
		move_and_slide()
		_handle_collisions()
		#for i in get_slide_collision_count():
			#var collision = get_slide_collision(i)
			#print("Collided with: ", collision.get_collider().name)
		$VisionCone.rotation = dir.angle()

func _push_prop(collider: Object, direction: Vector2):
	var impulse_dir = Vector2.from_angle(lerp_angle((direction).angle(), dir.angle()+PI, 0.5))
	var impulse: Vector2 = (impulse_dir*2*velocity.length())\
							/(collider.mass*1.5)
	_apply_opposite_force_to_self_and_collider(impulse, collider)

func update_debug_dest(coord: Vector2):
	new_dest = coord
	queue_redraw()
	
func saw_something_moved(move_speed: float):
	alert_gauge += move_speed/10

func heard_something(volume: int, sound_global_position: Vector2):
	if volume == -1: 
		alert_gauge = MAX_ALERT
		return
	var distance: float = global_position.distance_to(sound_global_position)
	alert_gauge += (volume * 100)*(hearing_radius.sample(distance))
		
func _on_player_died():
	fsm.curr_state.transitioned.emit(fsm.curr_state, "o_win")	

func die():
	super.die()

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(80, -20), fsm.curr_state.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
	if fsm.curr_state.name == "o_passive": draw_string(ThemeDB.fallback_font, Vector2(0, -50), str(roundf(fsm.curr_state.wander_time)), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.LIGHT_BLUE)
	if fsm.curr_state.name == "o_hunt": 
		draw_string(ThemeDB.fallback_font, Vector2(50, 0), "finished: %s" % $NavigationAgent2D.is_navigation_finished(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
		draw_string(ThemeDB.fallback_font, Vector2(50, 20), "reachable: %s" % $NavigationAgent2D.is_target_reachable(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
		draw_string(ThemeDB.fallback_font, Vector2(50, 40), "reached: %s" % $NavigationAgent2D.is_target_reached(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
	draw_string(ThemeDB.fallback_font, Vector2(-50, -70), "Collision: %s Velocity: %s" % [get_slide_collision_count(), velocity], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.BLACK)
	draw_line(Vector2.ZERO, new_dest, Color.BLUE, 7.0)
