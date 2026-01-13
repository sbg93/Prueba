extends Node2D

@export var speed := 50.0
@export var attack_damage := 3
@export var attack_interval := 2.2
@export var attack_range := 120.0

var game: Node
var _attack_timer := 0.0
var _attack_sound: AudioStreamPlayer2D
var _attack_stream: AudioStreamGenerator
var _current_target
var _fireball_scene := preload("res://scenes/Fireball.tscn")

func _ready() -> void:
	add_to_group("mages")
	_attack_stream = AudioStreamGenerator.new()
	_attack_stream.mix_rate = 44100
	_attack_stream.buffer_length = 0.3
	_attack_sound = AudioStreamPlayer2D.new()
	_attack_sound.stream = _attack_stream
	_attack_sound.volume_db = -4.0
	add_child(_attack_sound)

func _physics_process(delta: float) -> void:
	_attack_timer += delta
	if game == null:
		return
	if not _is_target_valid(_current_target):
		_current_target = game.get_random_near_enemy(global_position) as Node2D
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
		_spawn_fireball(_current_target)
		_spawn_double_fireball()
		_play_attack_sound()

func _is_target_valid(target) -> bool:
	return (
		target != null
		and is_instance_valid(target)
		and target is Node2D
		and target.is_inside_tree()
	)

func _play_attack_sound() -> void:
	if _attack_sound == null or _attack_stream == null:
		return
	_attack_sound.play()
	var playback := _attack_sound.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var sample_rate := _attack_stream.mix_rate
	var duration := 0.25
	var sample_count := int(sample_rate * duration)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var envelope := 1.0
		if t < 0.04:
			envelope = t / 0.04
		elif t > 0.18:
			envelope = max(0.0, (duration - t) / 0.07)
		var sweep : Variant = lerp(700.0, 220.0, t / duration)
		var flame := sin(2.0 * PI * sweep * t) * 0.5
		var crackle := randf_range(-1.0, 1.0) * 0.3
		var sample := (flame + crackle) * envelope * 0.6
		playback.push_frame(Vector2(sample, sample))

func _spawn_fireball(target) -> void:
	if _fireball_scene == null:
		return
	if target == null or not is_instance_valid(target) or not (target is Node2D):
		return
	var fireball := _fireball_scene.instantiate() as Node2D
	if fireball == null:
		return
	var parent_node := get_parent()
	if parent_node != null:
		parent_node.add_child(fireball)
	else:
		add_child(fireball)
	if fireball.has_method("launch"):
		fireball.call("launch", global_position, target, attack_damage)
	else:
		fireball.global_position = global_position

func _spawn_double_fireball() -> void:
	if game == null or not game.has_method("is_double_fireball_unlocked"):
		return
	if not game.is_double_fireball_unlocked():
		return
	var enemies_in_range := _get_enemies_in_range()
	if enemies_in_range.size() <= 1:
		return
	var secondary_candidates: Array[Node2D] = []
	for enemy in enemies_in_range:
		if enemy != _current_target:
			secondary_candidates.append(enemy)
	if secondary_candidates.is_empty():
		return
	var secondary_target := secondary_candidates[randi_range(0, secondary_candidates.size() - 1)]
	_spawn_fireball(secondary_target)

func _get_enemies_in_range() -> Array[Node2D]:
	var enemies_in_range: Array[Node2D] = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node2D and global_position.distance_to(enemy.global_position) <= attack_range:
			enemies_in_range.append(enemy)
	return enemies_in_range
