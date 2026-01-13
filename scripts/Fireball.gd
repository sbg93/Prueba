extends Node2D

@export var speed := 240.0
@export var radius := 6.0

var _target: Node2D
var _target_position: Vector2
var _time := 0.0
var _damage := 0

func launch(start_pos: Vector2, target: Node2D, damage: int = 0) -> void:
	global_position = start_pos
	_target = target
	_damage = damage
	if _target != null:
		_target_position = _target.global_position
	else:
		_target_position = start_pos

func _process(delta: float) -> void:
	_time += delta
	if _target != null and is_instance_valid(_target):
		_target_position = _target.global_position
	var distance := global_position.distance_to(_target_position)
	if distance <= speed * delta:
		global_position = _target_position
		_apply_damage()
		queue_free()
		return
	var direction := (_target_position - global_position).normalized()
	global_position += direction * speed * delta
	queue_redraw()

func _apply_damage() -> void:
	if _damage <= 0:
		return
	if _target == null or not is_instance_valid(_target):
		return
	if _target.has_method("take_damage"):
		_target.take_damage(_damage)

func _draw() -> void:
	var flicker := 1.0 + sin(_time * 12.0) * 0.1
	var core_radius := radius * flicker
	var glow_radius := radius * 1.8 * flicker
	var core_color := Color(1.0, 0.45, 0.1, 0.95)
	var glow_color := Color(1.0, 0.2, 0.05, 0.4)
	draw_circle(Vector2.ZERO, glow_radius, glow_color)
	draw_circle(Vector2.ZERO, core_radius, core_color)
