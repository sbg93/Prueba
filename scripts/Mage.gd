extends Node2D

@export var speed := 50.0
@export var attack_damage := 3
@export var attack_interval := 2.2
@export var attack_range := 120.0

var game: Node
var _attack_timer := 0.0
var _current_target

func _ready() -> void:
	add_to_group("mages")

func _physics_process(delta: float) -> void:
	_attack_timer += delta
	if game == null:
		return
	if not _is_target_valid(_current_target):
		_current_target = game.get_random_near_rat(global_position) as Node2D
	if _current_target == null:
		return
	var target_pos: Vector2 = _current_target.global_position
	var distance := global_position.distance_to(target_pos)
	if distance > attack_range:
		var direction: Vector2 = (target_pos - global_position).normalized()
		global_position += direction * speed * delta
		return
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		if _current_target != null and _current_target.has_method("take_damage"):
			_current_target.take_damage(attack_damage)

func _is_target_valid(target) -> bool:
	return (
		target != null
		and is_instance_valid(target)
		and target is Node2D
		and target.is_inside_tree()
	)
