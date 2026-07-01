extends MarginContainer

const OFF_SCREEN_OFFSET: float = 10 # Makes sure a hidden container is off-screen

enum PositionType {TOP, BOTTOM}
@export var position_slot: PositionType
var is_hidden: bool = true

var tween_transition: Tween.TransitionType = Tween.TRANS_BOUNCE
var tween_duration: float = 1.0

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


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("up"): show_container()
	elif Input.is_action_just_pressed("down"): hide_container()


func show_container(instantaneous: bool = false):
	is_hidden = false
	
	var duration = 0.0 if instantaneous else tween_duration
	var visible_y = 0 if position_slot == PositionType.TOP else get_viewport_rect().size.y/2
	
	var pos_tween = get_tree().create_tween().bind_node(self).set_trans(tween_transition).set_ease(Tween.EASE_OUT)
	pos_tween.tween_property(self, "position:y", visible_y, duration)


func hide_container(instantaneous: bool = false):
	is_hidden = true
	
	var duration = 0.0 if instantaneous else tween_duration
	var hidden_y = -size.y - OFF_SCREEN_OFFSET if position_slot == PositionType.TOP else get_viewport_rect().size.y + OFF_SCREEN_OFFSET
	
	var pos_tween = get_tree().create_tween().bind_node(self).set_trans(tween_transition).set_ease(Tween.EASE_IN)
	pos_tween.tween_property(self, "position:y", hidden_y, duration)


func update_position_based_on_window_size():
	if is_hidden: hide_container(true)
	else: show_container(true)
