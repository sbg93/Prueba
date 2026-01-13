extends Node2D

const MAX_ACTIVE_RATS := 5

@export var spawn_interval := 3.5
@export var spawn_radius := 24.0

var game: Node
var _timer := 0.0
var _active_rats := 0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
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
