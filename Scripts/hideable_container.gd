extends MarginContainer

const OFF_SCREEN_OFFSET: float = 20 # Makes sure a hidden container is off-screen

enum PositionType {TOP, BOTTOM}
@export var position_slot: PositionType
var is_hidden: bool = false

var tween_transition: Tween.TransitionType = Tween.TRANS_BOUNCE
var tween_duration: float = 1.0

@onready var children: Array[Node] = get_children() 

func _ready() -> void:
	get_viewport().size_changed.connect(update_position_based_on_window_size)
	
	#region Center Container
	position.x = 0.0
	anchor_left = 0.0
	anchor_right = 1.0
	#endregion
	if position_slot == PositionType.TOP:
		anchor_top = 0.0
		anchor_bottom = 0.5
		grow_vertical = GROW_DIRECTION_END
	else: # PositionType.BOTTOM
		anchor_top = 0.5
		anchor_bottom = 1.0
		grow_vertical = GROW_DIRECTION_BEGIN
	hide_container(true)

func _physics_process(delta: float) -> void:
	if name == "UpperContainer": print(position.y)

func show_container(instantaneous: bool = false):
	if not is_hidden: return
	is_hidden = false
	
	var duration = 0.0 if instantaneous else tween_duration
	var visible_y = 0.0 if position_slot == PositionType.TOP else get_viewport_rect().size.y/2
	
	var pos_tween = get_tree().create_tween().bind_node(self).set_trans(tween_transition).set_ease(Tween.EASE_OUT)
	pos_tween.tween_property(self, "position:y", visible_y, duration)
	await pos_tween.finished

func hide_container(instantaneous: bool = false):
	if is_hidden: return
	is_hidden = true
	
	var duration = 0.0 if instantaneous else tween_duration
	var hidden_y = -size.y - OFF_SCREEN_OFFSET if position_slot == PositionType.TOP else get_viewport_rect().size.y + OFF_SCREEN_OFFSET
	
	var pos_tween = get_tree().create_tween().bind_node(self).set_trans(tween_transition).set_ease(Tween.EASE_OUT)
	pos_tween.tween_property(self, "position:y", hidden_y, duration)
	await pos_tween.finished
	

func hide_all_content():
	for child in children:
		if child.has_method("hide_disable"): child.hide_disable()
		else: child.hide()

func update_position_based_on_window_size():
	if is_hidden: hide_container(true)
	else: show_container(true)
