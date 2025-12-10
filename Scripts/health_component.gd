class_name HealthComponent
extends Node2D

@export var health: float = 1.0

func _on_hit(body: Node2D):
	if "damage" in body: decrease_health(body.damage)
	else: decrease_health(1)

func decrease_health(attack: float):
	health -= attack
	if health <= 0 and owner.has_method("die"):
		owner.die()
