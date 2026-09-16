@tool
class_name BulletSpawner
extends Marker2D

const EDITOR_BULLET_LIFETIME: int = 2

enum TT {LINE, POS, NODE, ANGLE}
var target_type: TT = TT.LINE

@export_category("Nodes & Scenes")
@export var bullet: PackedScene
@export var timer: Timer
@export var line_of_sight: Line2D

@export var enable: bool = false:
	set(value):
		if enable == value: return
		enable = value

		if not is_inside_tree(): return
		if value:	start()
		else: 	stop()

@export var cooldown_pattern: Array[float]
var cooldown_index: int = 0

@export_category("Target")
@export var target_node: Node2D:
	set(value):
		target_type = TT.NODE
		target_node = value
var target: Vector2 = Vector2.ZERO: # expects global position
	set(value):
		target_type = TT.POS
		target = value

func get_target_position() -> Vector2:
	if target_type == TT.NODE:
		if not is_instance_valid(target_node):
			return global_position
		return target_node.global_position
	return target

func start():
	if not enable: enable = true # to avoid enable's setter (infinite loop)
	cooldown_index = 0
	_start_cooldown(cooldown_pattern[cooldown_index])
	
func stop():
	if enable: enable = false # to avoid enable's setter (infinite loop)
	timer.stop()

func _start_cooldown(time: float) -> void:
	if cooldown_pattern.is_empty(): push_warning("DulletSpawner.cooldown_pattern[] is empty!")
	timer.start(time)

func _on_timer_timeout() -> void:
	if not enable: return

	_fire()
	cooldown_index = (cooldown_index + 1) % cooldown_pattern.size()
	_start_cooldown(cooldown_pattern[cooldown_index])

func _fire() -> void:
	if bullet == null: return

	var aim_direction: Vector2 = line_of_sight.points[1] if target_type == TT.LINE\
							else to_local(get_target_position())
	var new_bullet = bullet.instantiate()

	if Engine.is_editor_hint():
		# Add the bullet to the tree first so it has a parent and a valid transform.
		# Otherwise, setting its global_position in _initialize() before add_child()
		# can cause an offset when the parent's transform is applied afterwards.
		add_child(new_bullet)
		new_bullet = new_bullet._initialize(global_position, aim_direction.angle(), null, EDITOR_BULLET_LIFETIME)

		new_bullet.owner = self

	else:
		var congregator := get_tree().root.get_node("/root/BulletCongregator")
		# Same as above
		congregator.add_child(new_bullet)
		
		var shooter = owner if owner is PhysicsBody2D else null 
		new_bullet = new_bullet._initialize(global_position, aim_direction.angle(), shooter, new_bullet.DEFAULT_LIFETIME)

		new_bullet.owner = congregator

		SfxPlayer.play_sound("TEST", -1, global_position)


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	if not Engine.is_editor_hint():
		line_of_sight.hide()
