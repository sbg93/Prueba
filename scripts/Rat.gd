extends Area2D

signal died

@export var max_health := 5

var health := 5
var game: Node

func _ready() -> void:
	health = max_health
	add_to_group("rats")

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	if health == 0:
		died.emit()
		queue_free()
