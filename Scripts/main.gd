extends Node

@export_category("Nodes & Scenes")
@export var player: Player
@export var world: Node2D
@export var opponent: CharacterBody2D
@export var timer: Timer
@export var ui: Control

func _ready() -> void:
	player.move_enable = false
	
	var y_offset: float = 1.7
	player.position = world.get_viewport_rect().get_center() * Vector2(1, y_offset) 
	await get_tree().create_timer(1.0).timeout
	ui.show_title_screen()
	player.died.connect(game_over)
	opponent.died.connect(win)
	$UI/LowerContainer/ShootableStartButton.function = start_pressed
	
func turn_opponent_after_countdown():
	if opponent and opponent.FSM.curr_state.has_method("turn_around"):
		opponent.FSM.curr_state.turn_around()

func game_over():
	ui.show_game_over()

func win():
	ui.show_go()

func start_pressed():
	player.move_enable = true
	await ui.hide_all()
	ui.show_go()
