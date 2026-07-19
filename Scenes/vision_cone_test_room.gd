extends Node2D

func _ready() -> void:
	var props = get_children().filter(func(x): return x is Prop)
	print(props)
	props.any(spin)

func spin(prop): 
	print(prop)
	prop.animatedSprite.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		$Opponent.position += Vector2.UP * 10
	if event.is_action_pressed("down"):
		$Opponent.position += Vector2.DOWN * 10
