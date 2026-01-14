extends Node2D

@export var speed := 50.0
@export var effect_range := 120.0
@export var retarget_interval := 30.0

var game: Node
var _current_nest: Node2D
var _retarget_timer := 0.0

func _ready() -> void:
	add_to_group("bardos")

func _physics_process(delta: float) -> void:
	_retarget_timer += delta
	if game == null:
		return
	if _should_pick_new_target():
		_pick_new_target()
		_retarget_timer = 0.0
	if _current_nest == null:
		return
	var target_pos: Vector2 = _current_nest.global_position
	var distance := global_position.distance_to(target_pos)
	if distance > effect_range:
		var direction := (target_pos - global_position).normalized()
		global_position += direction * speed * delta

func _should_pick_new_target() -> bool:
	return _retarget_timer >= retarget_interval or not _is_target_valid(_current_nest)

func _is_target_valid(target) -> bool:
	return (
		target != null
		and is_instance_valid(target)
		and target is Node2D
		and target.is_inside_tree()
	)

func _pick_new_target() -> void:
	if game == null or not game.has_method("get_random_nest"):
		_current_nest = null
		return
	_current_nest = game.get_random_nest(_current_nest) as Node2D
