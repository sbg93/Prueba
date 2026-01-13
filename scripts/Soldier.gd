extends Node2D

@export var speed := 70.0
@export var attack_damage := 1
@export var attack_interval := 2.0
@export var attack_range := 14.0

var game: Node
var _attack_timer := 0.0

func _physics_process(delta: float) -> void:
	_attack_timer += delta
	if game == null:
		return
	var target: Node2D = game.get_nearest_rat(global_position) as Node2D
	if target == null:
		return
	var target_pos: Vector2 = target.global_position
	var distance := global_position.distance_to(target_pos)
	if distance > attack_range:
		var direction: Vector2 = (target_pos - global_position).normalized()
		global_position += direction * speed * delta
		return
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
