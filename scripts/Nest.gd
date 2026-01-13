extends Node2D

@export var spawn_interval := 3.5
@export var spawn_radius := 24.0

var game: Node
var _timer := 0.0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_rat()

func _spawn_rat() -> void:
	if game == null:
		return
	var offset := Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	game.spawn_rat_at_position(global_position + offset)
