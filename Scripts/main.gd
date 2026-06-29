extends Node

@export_category("Nodes & Scenes")
@export var player: Player
@export var opponent: CharacterBody2D
@export var timer: Timer

func _ready() -> void:
	timer.start(20)
	timer.timeout.connect(turn_opponent_after_countdown)
	player.died.connect(game_over)
	opponent.died.connect(win)
	$ShootableButton.function = button_pressed
	
func turn_opponent_after_countdown():
	if opponent and opponent.FSM.curr_state.has_method("turn_around"):
		opponent.FSM.curr_state.turn_around()

func game_over():
	print("LOSER")

func win():
	print("GO")

func button_pressed():
	print("NRPPPP")
