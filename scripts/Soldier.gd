extends Node2D

@export var speed := 70.0
@export var attack_damage := 1
@export var attack_interval := 2.0
@export var attack_range := 14.0

var game: Node
var _attack_timer := 0.0
var _attack_sound: AudioStreamPlayer2D
var _attack_stream: AudioStreamGenerator

func _ready() -> void:
	_attack_stream = AudioStreamGenerator.new()
	_attack_stream.mix_rate = 44100
	_attack_stream.buffer_length = 0.3
	_attack_sound = AudioStreamPlayer2D.new()
	_attack_sound.stream = _attack_stream
	_attack_sound.volume_db = -6.0
	add_child(_attack_sound)

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
		_play_attack_sound()

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
