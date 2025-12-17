extends AnimatedSprite2D

signal animation_ended # Emitted when either animation_finished or animation_looped is emitted

func _ready() -> void:
	play()
	animation_finished.connect(_on_any_animation_end)
	animation_looped.connect(_on_any_animation_end)

func _on_any_animation_end():
	animation_ended.emit()
