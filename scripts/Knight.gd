extends Node2D

@export var speed := 220.0
@export var attack_damage := 5
@export var attack_interval := 3.0
@export var hit_radius := 24.0
@export var whirlwind_radius := 120.0

var game: Node
var _attack_timer := 0.0
var _current_target
var _charging := false
var _charge_direction := Vector2.ZERO
var _charge_target_pos := Vector2.ZERO
var _hit_targets: Array = []
var _charge_sound: AudioStreamPlayer2D
var _charge_stream: AudioStreamGenerator
var _hit_sound: AudioStreamPlayer2D
var _hit_stream: AudioStreamGenerator

func _ready() -> void:
	add_to_group("knights")
	_charge_stream = AudioStreamGenerator.new()
	_charge_stream.mix_rate = 44100
	_charge_stream.buffer_length = 0.4
	_charge_sound = AudioStreamPlayer2D.new()
	_charge_sound.stream = _charge_stream
	_charge_sound.volume_db = -4.0
	add_child(_charge_sound)
	_hit_stream = AudioStreamGenerator.new()
	_hit_stream.mix_rate = 44100
	_hit_stream.buffer_length = 0.2
	_hit_sound = AudioStreamPlayer2D.new()
	_hit_sound.stream = _hit_stream
	_hit_sound.volume_db = -2.0
	add_child(_hit_sound)

func _physics_process(delta: float) -> void:
	_attack_timer += delta
	if game == null:
		return
	if _charging:
		_perform_charge(delta)
		return
	if not _is_target_valid(_current_target):
		_current_target = game.get_random_near_enemy(global_position) as Node2D
	if _current_target == null:
		return
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		_start_charge(_current_target.global_position)

func _start_charge(target_pos: Vector2) -> void:
	var direction := (target_pos - global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	_charge_direction = direction
	_charge_target_pos = _get_wall_hit_point(global_position, direction)
	_hit_targets.clear()
	_charging = true
	_play_charge_sound()

func _perform_charge(delta: float) -> void:
	_apply_charge_damage()
	var to_target := _charge_target_pos - global_position
	var step := speed * delta
	if to_target.length() <= step:
		global_position = _charge_target_pos
		_charging = false
		return
	global_position += _charge_direction * step

func _apply_charge_damage() -> void:
	if game == null:
		return
	var space_state := get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = hit_radius
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, global_position)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	var hits := space_state.intersect_shape(params, 32)
	for hit in hits:
		var collider : Variant = hit.get("collider")
		if collider is Node and collider.is_in_group("enemies"):
			if _hit_targets.has(collider):
				continue
			_hit_targets.append(collider)
			if collider.has_method("take_damage"):
				collider.take_damage(attack_damage)
			_play_hit_sound()
			if _is_torbellino_active():
				_apply_torbellino_damage()

func _apply_torbellino_damage() -> void:
	var space_state := get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = whirlwind_radius
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, global_position)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	var hits := space_state.intersect_shape(params, 32)
	var applied := false
	for hit in hits:
		var collider : Variant = hit.get("collider")
		if collider is Node and collider.is_in_group("enemies"):
			if _hit_targets.has(collider):
				continue
			_hit_targets.append(collider)
			if collider.has_method("take_damage"):
				collider.take_damage(attack_damage)
			applied = true
	if applied:
		_play_hit_sound()

func _is_torbellino_active() -> bool:
	return game != null and game.has_method("is_torbellino_unlocked") and game.is_torbellino_unlocked()

func _get_wall_hit_point(origin: Vector2, direction: Vector2) -> Vector2:
	if game == null or not ("playfield_rect" in game):
		return origin
	var rect: Rect2 = game.playfield_rect
	var min_pos := rect.position
	var max_pos := rect.position + rect.size
	var candidates: Array[Vector2] = []
	if direction.x != 0.0:
		var t_left := (min_pos.x - origin.x) / direction.x
		if t_left > 0.0:
			var point_left := origin + direction * t_left
			if point_left.y >= min_pos.y and point_left.y <= max_pos.y:
				candidates.append(point_left)
		var t_right := (max_pos.x - origin.x) / direction.x
		if t_right > 0.0:
			var point_right := origin + direction * t_right
			if point_right.y >= min_pos.y and point_right.y <= max_pos.y:
				candidates.append(point_right)
	if direction.y != 0.0:
		var t_top := (min_pos.y - origin.y) / direction.y
		if t_top > 0.0:
			var point_top := origin + direction * t_top
			if point_top.x >= min_pos.x and point_top.x <= max_pos.x:
				candidates.append(point_top)
		var t_bottom := (max_pos.y - origin.y) / direction.y
		if t_bottom > 0.0:
			var point_bottom := origin + direction * t_bottom
			if point_bottom.x >= min_pos.x and point_bottom.x <= max_pos.x:
				candidates.append(point_bottom)
	if candidates.is_empty():
		return origin
	var best_point := candidates[0]
	var best_distance := origin.distance_to(best_point)
	for point in candidates:
		var distance := origin.distance_to(point)
		if distance < best_distance:
			best_distance = distance
			best_point = point
	return best_point

func _is_target_valid(target) -> bool:
	return (
		target != null
		and is_instance_valid(target)
		and target is Node2D
		and target.is_inside_tree()
	)

func _play_charge_sound() -> void:
	if _charge_sound == null or _charge_stream == null:
		return
	_charge_sound.play()
	var playback := _charge_sound.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var sample_rate := _charge_stream.mix_rate
	var duration := 0.35
	var sample_count := int(sample_rate * duration)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var envelope := 1.0
		if t < 0.05:
			envelope = t / 0.05
		elif t > 0.28:
			envelope = max(0.0, (duration - t) / 0.07)
		var gallop := sin(2.0 * PI * 90.0 * t) * 0.4
		var thump := sin(2.0 * PI * 45.0 * t) * 0.6
		var noise := randf_range(-0.2, 0.2)
		var beat := 0.5 + 0.5 * sin(2.0 * PI * 6.0 * t)
		var sample := (gallop * 0.4 + thump * 0.6 + noise) * envelope * beat
		playback.push_frame(Vector2(sample, sample))

func _play_hit_sound() -> void:
	if _hit_sound == null or _hit_stream == null:
		return
	_hit_sound.play()
	var playback := _hit_sound.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var sample_rate := _hit_stream.mix_rate
	var duration := 0.12
	var sample_count := int(sample_rate * duration)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var envelope := 1.0
		if t < 0.01:
			envelope = t / 0.01
		elif t > 0.08:
			envelope = max(0.0, (duration - t) / 0.04)
		var noise := randf_range(-1.0, 1.0)
		var tone := sin(2.0 * PI * 980.0 * t) * 0.5
		var sample := (noise * 0.6 + tone * 0.4) * envelope * 0.7
		playback.push_frame(Vector2(sample, sample))
