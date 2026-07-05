extends Control

@export_category("Nodes & Scenes")
@export var upper: Container
@export var lower: Container

func _ready() -> void:
	show()

func show_title_screen():
	hide_all()
	$UpperContainer/Title.show()
	$LowerContainer/ShootableStartButton.show_enable()
	show_all()

func show_game_over():
	hide_all()
	$UpperContainer/GameOver.show()
	$LowerContainer/ShootableRetryButton.show_enable()
	show_all()

func show_go():
	hide_all()
	$UpperContainer/Go.show()
	upper.show_container()

func show_counter():
	hide_all()
	$UpperContainer/Counter.show()
	upper.show_container()

func show_all():
	upper.show_container()
	lower.show_container()

func hide_all():
	upper.hide_container()
	await lower.hide_container()
	upper.hide_all_content()
	lower.hide_all_content()
