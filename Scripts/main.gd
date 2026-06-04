extends Node

@export_category("Nodes & Scenes")
@export var timer: Timer
@export var opponent: CharacterBody2D

func _ready() -> void:
	timer.start(20)
	timer.timeout.connect(turn_opponent_after_countdown)

func turn_opponent_after_countdown():
	if opponent and opponent.FSM.curr_state.has_method("turn_around"):
		opponent.FSM.curr_state.turn_around()
