extends Node2D

const MAX_ACTIVE_GOBLINS := 5

@export var spawn_interval := 5.0
@export var spawn_radius := 24.0

var game: Node
var _timer := 0.0
var _active_goblins := 0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_goblin()

func _ready() -> void:
	add_to_group("goblin_nests")

func _spawn_goblin() -> void:
	if game == null:
		return
	if _active_goblins >= MAX_ACTIVE_GOBLINS:
		return
	var offset := Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	var goblin : Node = game.spawn_goblin_at_position(global_position + offset)
	if goblin != null:
		_active_goblins += 1
		goblin.died.connect(_on_goblin_died)

func _on_goblin_died(_gold_value: int, _enemy_kind: String, _killed_by_click: bool) -> void:
	_active_goblins = max(_active_goblins - 1, 0)
