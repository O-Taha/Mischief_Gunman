extends Node2D

var current_level_res: Resource = load("res://Scenes/Levels/level_1.tscn")
var current_level: Node2D

const Y_OFFSET_FACTOR: float = 1.75

@onready var start_pos: Vector2 = get_viewport_rect().get_center() * Vector2(1, Y_OFFSET_FACTOR) 
@onready var player: Player = get_tree().get_first_node_in_group("Player")


func _ready() -> void:
	current_level = current_level_res.instantiate()
	current_level.position = Vector2.UP * 2000
	add_child(current_level)
	current_level.owner = self

func show_next_level():
	var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_EXPO)
	var duration: float = 2.0
	current_level.opponent.disable_physics()
	pos_tween.tween_property(current_level, "position:y", 0.0, duration)
	pos_tween.parallel().tween_property(player, "position:y", start_pos.y, duration)
	await pos_tween.finished
	current_level.opponent.enable_physics()
	
func reset_player_pos_game_over():
	var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_EXPO)
	var duration: float = 2.0
	player.disable_physics()
	pos_tween.tween_property(player, "position", start_pos, duration)
	await pos_tween.finished
	player.enable_physics(false)
	
