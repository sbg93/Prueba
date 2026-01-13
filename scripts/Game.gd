extends Node2D

@onready var coin: Area2D = $Coin
@onready var score_label: Label = $HUD/ScoreLabel
@onready var player: CharacterBody2D = $Player

var score := 0
var bounds := Rect2(Vector2(40, 40), Vector2(880, 460))

func _ready() -> void:
	randomize()
	coin.body_entered.connect(_on_coin_body_entered)
	_update_label()

func _on_coin_body_entered(body: Node) -> void:
	if body != player:
		return
	score += 1
	_update_label()
	_move_coin()

func _move_coin() -> void:
	var new_pos := Vector2(
		randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
		randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
	)
	coin.position = new_pos

func _update_label() -> void:
	score_label.text = "Monedas: %d" % score
