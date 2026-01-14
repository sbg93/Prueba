extends Node2D

const MAX_ACTIVE_RATS := 5

@export var spawn_interval := 3.5
@export var spawn_radius := 24.0

var game: Node
var _timer := 0.0
var _active_rats := 0

func _process(delta: float) -> void:
	_timer += delta
	var adjusted_interval := _get_adjusted_spawn_interval()
	if _timer >= adjusted_interval:
		_timer = 0.0
		_spawn_rat()

func _ready() -> void:
	add_to_group("nests")

func _spawn_rat() -> void:
	if game == null:
		return
	if _active_rats >= MAX_ACTIVE_RATS:
		return
	var is_green := randf() < 0.1
	var offset := Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	var rat : Node = game.spawn_rat_at_position(global_position + offset, is_green)
	if rat != null:
		_active_rats += 1
		rat.died.connect(_on_rat_died)

func _on_rat_died(_gold_value: int, _enemy_kind: String, _killed_by_click: bool) -> void:
	_active_rats = max(_active_rats - 1, 0)

func _get_adjusted_spawn_interval() -> float:
	var multiplier := _get_bardo_spawn_multiplier()
	if multiplier <= 0.0:
		return spawn_interval
	return spawn_interval / multiplier

func _get_bardo_spawn_multiplier() -> float:
	if game == null or not game.has_method("get_bardo_spawn_bonus"):
		return 1.0
	var total_bonus := 0.0
	for bardo in get_tree().get_nodes_in_group("bardos"):
		if bardo is Node2D:
			var effect_range : Variant = bardo.effect_range if "effect_range" in bardo else 0.0
			if effect_range > 0.0 and global_position.distance_to(bardo.global_position) <= effect_range:
				total_bonus += game.get_bardo_spawn_bonus()
	return 1.0 + total_bonus
