extends RigidBody2D

@export_category("Nodes & Scenes")
@export var hurtbox: CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	print(body)
	if body is not Bullet: return
	
	var has_no_components: bool = not owner.get("added_components")
	var queue_bullet_death: bool = false # Allows for freeing *after* checking all conditions
	
	if has_no_components:
		owner.die()
	if owner.has_component(owner.HEALTH_COMPONENT):
		owner.get_node("HealthComponent")._on_hit_by(self)
		queue_bullet_death = true
	if owner.has_component(owner.RICOCHET_COMPONENT):
		queue_bullet_death = false
	else: queue_bullet_death = true
		
	if queue_bullet_death: body.die()
