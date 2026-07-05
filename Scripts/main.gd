extends Node

@export_category("Nodes & Scenes")
@export var player: Player
@export var world: Node2D
@export var timer: Timer
@export var ui: Control

@onready var opponent: Cowboy = world.current_level.opponent

func _ready() -> void:
	player.move_enable = false
	
	var y_offset: float = 1.8
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
	await ui.show_game_over()

func win():
	ui.show_go()

func start_pressed():
	player.move_enable = true
	ui.show_go()
