extends LightOccluder2D

@export var occluders: Array[OccluderPolygon2D]

func _ready() -> void:
	owner.animatedSprite.frame_changed.connect(update_occluder)
	
func update_occluder():
	occluder = occluders[owner.animatedSprite.frame] if occluders.size() > 1 \
			else occluders[0]
