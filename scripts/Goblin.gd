extends Area2D

signal died(gold_value: int, enemy_kind: String)

@export var max_health := 10
@export var move_speed := 120.0
@export var direction_change_range := Vector2(0.8, 1.6)
@export var gold_value := 10
@export var flee_distance := 200.0

var health := 10
var game: Node
var _direction := Vector2.ZERO
var _direction_timer := 0.0
var _next_direction_change := 0.0

func _ready() -> void:
	health = max_health
	add_to_group("goblins")
	add_to_group("enemies")
	_set_random_direction()
	_schedule_direction_change()

func _process(delta: float) -> void:
	_direction_timer += delta
	var flee_direction := _get_flee_direction()
	if flee_direction != Vector2.ZERO:
		_direction = flee_direction
	elif _direction_timer >= _next_direction_change:
		_direction_timer = 0.0
		_set_random_direction()
		_schedule_direction_change()

	if _direction != Vector2.ZERO:
		global_position += _direction * move_speed * delta

	if game != null and "playfield_rect" in game:
		_keep_inside_playfield(game.playfield_rect)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	if health == 0:
		died.emit(gold_value, "goblin")
		queue_free()

func _get_flee_direction() -> Vector2:
	if game == null:
		return Vector2.ZERO
	var target : Node = game.get_random_near_player_unit(global_position)
	if target == null:
		return Vector2.ZERO
	var target_pos: Vector2 = target.global_position
	if global_position.distance_to(target_pos) > flee_distance:
		return Vector2.ZERO
	return (global_position - target_pos).normalized()

func _set_random_direction() -> void:
	_direction = Vector2.from_angle(randf_range(0.0, TAU))

func _schedule_direction_change() -> void:
	_next_direction_change = randf_range(direction_change_range.x, direction_change_range.y)

func _keep_inside_playfield(playfield_rect: Rect2) -> void:
	var min_pos := playfield_rect.position
	var max_pos := playfield_rect.position + playfield_rect.size
	var pos := global_position
	var bounced := false

	if pos.x < min_pos.x or pos.x > max_pos.x:
		_direction.x = -_direction.x
		bounced = true
	if pos.y < min_pos.y or pos.y > max_pos.y:
		_direction.y = -_direction.y
		bounced = true
	if bounced:
		global_position = Vector2(
			clamp(pos.x, min_pos.x, max_pos.x),
			clamp(pos.y, min_pos.y, max_pos.y)
		)
