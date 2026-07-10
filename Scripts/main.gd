extends Node

@export_category("Nodes & Scenes")
@export var world: Node2D
@export var timer: Timer
@export var ui: Control
@export var next_level_trigger: Area2D

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var opponent: Cowboy = world.current_level.opponent

enum GameState{TITLE, PLAYING, GO, GAMEOVER}
var game_state: GameState:
	set(value):
		next_level_trigger.set_deferred("monitoring", (value == GameState.GO))
		game_state = value
		match value:
			GameState.TITLE:
				player.move_enable = false
				player.shoot_enable = true
				player.dead = false
				
				opponent.move_enable = false
				opponent.shoot_enable = false
				opponent.dead = true
				
			GameState.PLAYING:
				player.move_enable = true
				player.shoot_enable = true
				player.dead = false
				
				opponent.move_enable = true
				opponent.shoot_enable = true
				opponent.dead = false
				
			GameState.GO:
				player.move_enable = true
				player.shoot_enable = true
				player.dead = false
				
				opponent.move_enable = false
				opponent.shoot_enable = false
				opponent.dead = true
				
			GameState.GAMEOVER:
				player.move_enable = false
				player.shoot_enable = true
				player.dead = true
				
				opponent.move_enable = true
				opponent.shoot_enable = false
				opponent.dead = true
			

func _ready() -> void:
	game_state = GameState.TITLE # DO NOT REMOVE, USED DO TRIGGER game_state's SETTER, 
							# HAS TO BE IN READY AND NOT @ONREADY
	
	var reticle_texture: CompressedTexture2D = load("res://Assets/Placeholder/cursor1.png")
	Input.set_custom_mouse_cursor(reticle_texture, Input.CURSOR_ARROW, reticle_texture.get_size()/2)
	
	player.position = world.start_pos
	
	ui.show_title_screen()
	player.died.connect(game_over)
	opponent.died.connect(win)
	$UI/LowerContainer/ShootableStartButton.function = start_pressed
	
#func _physics_process(_delta: float) -> void:
	#var statenames = ["TITLE", "PLAYING", "GO", "GAMEOVER"]
	#print(statenames[game_state])
	#print(game_state == GameState.GO, next_level_trigger.monitoring)

func turn_opponent_after_countdown():
	if opponent and opponent.fsm.curr_state.has_method("turn_around"):
		opponent.fsm.curr_state.turn_around()

func game_over():
	ui.show_game_over()
	world.reset_player_pos_game_over()
	game_state = GameState.GAMEOVER

func win():
	if game_state == GameState.GAMEOVER: return # to avoid player winning because of a stray bullet before dying
	ui.show_go()
	game_state = GameState.GO

func start_pressed():
	ui.show_go()
	game_state = GameState.GO

func transition_next_level(body: Node2D):
	if body is Player:
		ui.hide_all()
		game_state = GameState.PLAYING
		world.show_next_level()
