class_name HealthComponent
extends Node2D

@export var health: float = 1.0

func _on_hit_by(projectile: Node2D):
	if "damage" in projectile: decrease_health(projectile.damage)
	else: decrease_health(1)

func decrease_health(attack: float):
	health -= attack
	var parent = get_parent()
	if health <= 0 and parent.has_method("die"):
		parent.die()
