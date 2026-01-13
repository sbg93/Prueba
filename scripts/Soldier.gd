extends Node2D

@export var speed := 70.0
@export var attack_damage := 1
@export var attack_interval := 2.0
@export var attack_range := 14.0

var game: Node
var _attack_timer := 0.0
var _attack_sound: AudioStreamPlayer2D
var _attack_stream: AudioStreamGenerator
var _current_target
var _animation_player: AnimationPlayer
var _is_attacking := false

func _ready() -> void:
	add_to_group("soldiers")
	_attack_stream = AudioStreamGenerator.new()
	_attack_stream.mix_rate = 44100
	_attack_stream.buffer_length = 0.3
	_attack_sound = AudioStreamPlayer2D.new()
	_attack_sound.stream = _attack_stream
	_attack_sound.volume_db = -6.0
	add_child(_attack_sound)
	_setup_animations()

func _physics_process(delta: float) -> void:
	_attack_timer += delta
	if game == null:
		return
	if not _is_target_valid(_current_target):
		_current_target = game.get_random_near_rat(global_position) as Node2D
	if _current_target == null:
		_stop_walk_animation()
		return
	var target_pos: Vector2 = _current_target.global_position
	var distance := global_position.distance_to(target_pos)
	if distance > attack_range:
		var direction: Vector2 = (target_pos - global_position).normalized()
		global_position += direction * speed * delta
		_play_walk_animation()
		return
	_stop_walk_animation()
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		if _current_target != null and _current_target.has_method("take_damage"):
			_current_target.take_damage(attack_damage)
		_play_attack_animation()
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
	var duration := 0.2
	var sample_count := int(sample_rate * duration)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var envelope := 1.0
		if t < 0.05:
			envelope = t / 0.05
		elif t > 0.15:
			envelope = max(0.0, (duration - t) / 0.05)
		var noise := randf_range(-1.0, 1.0)
		var tone := sin(2.0 * PI * 220.0 * t) * 0.3
		var sample := (noise * 0.7 + tone) * envelope * 0.6
		playback.push_frame(Vector2(sample, sample))

func _setup_animations() -> void:
	_animation_player = AnimationPlayer.new()
	add_child(_animation_player)
	var library := AnimationLibrary.new()
	library.add_animation("walk", _create_walk_animation())
	library.add_animation("attack", _create_attack_animation())
	_animation_player.add_animation_library("default", library)
	_animation_player.play("walk")

func _create_walk_animation() -> Animation:
	var walk := Animation.new()
	walk.length = 0.6
	walk.loop_mode = Animation.LOOP_LINEAR
	var position_track := walk.add_track(Animation.TYPE_VALUE)
	walk.track_set_path(position_track, "Sprite2D:position")
	walk.track_insert_key(position_track, 0.0, Vector2.ZERO)
	walk.track_insert_key(position_track, 0.15, Vector2(0, -2))
	walk.track_insert_key(position_track, 0.3, Vector2.ZERO)
	walk.track_insert_key(position_track, 0.45, Vector2(0, -2))
	walk.track_insert_key(position_track, 0.6, Vector2.ZERO)
	var scale_track := walk.add_track(Animation.TYPE_VALUE)
	walk.track_set_path(scale_track, "Sprite2D:scale")
	walk.track_insert_key(scale_track, 0.0, Vector2(1.0, 1.0))
	walk.track_insert_key(scale_track, 0.15, Vector2(0.96, 1.02))
	walk.track_insert_key(scale_track, 0.3, Vector2(1.04, 0.98))
	walk.track_insert_key(scale_track, 0.45, Vector2(0.96, 1.02))
	walk.track_insert_key(scale_track, 0.6, Vector2(1.0, 1.0))
	return walk

func _create_attack_animation() -> Animation:
	var attack := Animation.new()
	attack.length = 0.35
	attack.loop_mode = Animation.LOOP_NONE
	var position_track := attack.add_track(Animation.TYPE_VALUE)
	attack.track_set_path(position_track, "Sprite2D:position")
	attack.track_insert_key(position_track, 0.0, Vector2.ZERO)
	attack.track_insert_key(position_track, 0.1, Vector2(2, -1))
	attack.track_insert_key(position_track, 0.2, Vector2(4, 0))
	attack.track_insert_key(position_track, 0.35, Vector2.ZERO)
	var rotation_track := attack.add_track(Animation.TYPE_VALUE)
	attack.track_set_path(rotation_track, "Sprite2D:rotation")
	attack.track_insert_key(rotation_track, 0.0, 0.0)
	attack.track_insert_key(rotation_track, 0.1, -0.4)
	attack.track_insert_key(rotation_track, 0.2, 0.35)
	attack.track_insert_key(rotation_track, 0.35, 0.0)
	return attack

func _play_walk_animation() -> void:
	if _animation_player == null:
		return
	if _is_attacking and _animation_player.is_playing():
		return
	if _animation_player.current_animation != "walk":
		_animation_player.play("walk")

func _stop_walk_animation() -> void:
	if _animation_player == null:
		return
	if _animation_player.current_animation == "walk":
		_animation_player.stop()
		_animation_player.seek(0.0, true)

func _play_attack_animation() -> void:
	if _animation_player == null:
		return
	_is_attacking = true
	_animation_player.play("attack")
	_animation_player.animation_finished.connect(_on_attack_animation_finished, CONNECT_ONE_SHOT)

func _on_attack_animation_finished(anim_name: StringName) -> void:
	if anim_name != "attack":
		return
	_is_attacking = false
