extends ColorRect
var function: Callable

func _ready() -> void:
	$ButtonCollision.hit.connect(_on_hit)
	
func _on_hit():
	function.call()
	queue_free()
