extends Area2D

signal died

@export var max_health := 5

var health := 5
var game: Node

func _ready() -> void:
	health = max_health
	add_to_group("rats")
	input_event.connect(_on_input_event)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	if health == 0:
		died.emit()
		queue_free()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if game != null:
			game.apply_click_damage(self)
