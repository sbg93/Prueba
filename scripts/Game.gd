extends Node2D

const BASE_NEST_COST := 5
const BASE_SOLDIER_COST := 5
const BASE_CLICK_UPGRADE_COST := 5

const NEST_COST_MULTIPLIER := 2
const SOLDIER_COST_MULTIPLIER := 2
const CLICK_UPGRADE_MULTIPLIER := 2

const RAT_GOLD_VALUE := 1

@export var playfield_rect := Rect2(Vector2(40, 80), Vector2(620, 440))

@onready var playfield: Node2D = $Playfield
@onready var gold_label: Label = $HUD/UIRoot/GoldLabel
@onready var click_damage_label: Label = $HUD/UIRoot/ClickDamageLabel
@onready var placement_label: Label = $HUD/UIRoot/PlacementLabel
@onready var purchases_tab_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/TabButtons/PurchasesTabButton
@onready var upgrades_tab_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/TabButtons/UpgradesTabButton
@onready var purchases_list: VBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList
@onready var upgrades_list: VBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList
@onready var rat_nest_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/RatNestRow/RatNestBuyButton
@onready var soldier_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/SoldierRow/SoldierBuyButton
@onready var click_upgrade_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/ClickUpgradeRow/ClickUpgradeButton

var gold := 10
var click_damage := 1
var nest_count := 0
var soldier_count := 0
var click_upgrade_count := 0

var pending_purchase := ""
var pending_cost := 0

var rat_scene := preload("res://scenes/Rat.tscn")
var nest_scene := preload("res://scenes/Nest.tscn")
var soldier_scene := preload("res://scenes/Soldier.tscn")

func _ready() -> void:
	add_to_group("game")
	randomize()
	purchases_tab_button.pressed.connect(_on_purchases_tab_pressed)
	upgrades_tab_button.pressed.connect(_on_upgrades_tab_pressed)
	rat_nest_button.pressed.connect(_on_buy_rat_nest_pressed)
	soldier_button.pressed.connect(_on_buy_soldier_pressed)
	click_upgrade_button.pressed.connect(_on_buy_click_upgrade_pressed)
	_update_ui()
	_show_purchases()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var click_pos := get_viewport().get_mouse_position()
		if event.button_index == MOUSE_BUTTON_LEFT and pending_purchase.is_empty():
			if playfield_rect.has_point(click_pos):
				_apply_click_damage_at(click_pos)
			return
		if pending_purchase.is_empty():
			return
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_clear_pending_purchase()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not playfield_rect.has_point(click_pos):
			return
		_place_pending_purchase(click_pos)

func apply_click_damage(rat: Node) -> void:
	if rat.has_method("take_damage"):
		rat.take_damage(click_damage)

func _apply_click_damage_at(click_pos: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = click_pos
	params.collide_with_areas = true
	var hits := space_state.intersect_point(params, 32)
	for hit in hits:
		var collider : Variant = hit.get("collider")
		if collider is Node and collider.is_in_group("rats"):
			apply_click_damage(collider)
			return

func spawn_rat_at_position(spawn_pos: Vector2) -> Node:
	var rat := rat_scene.instantiate()
	rat.position = spawn_pos
	rat.game = self
	playfield.add_child(rat)
	rat.died.connect(_on_rat_died)
	return rat

func get_nearest_rat(from_pos: Vector2) -> Node:
	var rats := get_tree().get_nodes_in_group("rats")
	var nearest : Node = null
	var nearest_distance := INF
	for rat in rats:
		var distance := from_pos.distance_to(rat.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = rat
	return nearest

func _on_rat_died() -> void:
	gold += RAT_GOLD_VALUE
	_update_ui()

func _on_purchases_tab_pressed() -> void:
	_show_purchases()

func _on_upgrades_tab_pressed() -> void:
	_show_upgrades()

func _show_purchases() -> void:
	purchases_list.visible = true
	upgrades_list.visible = false

func _show_upgrades() -> void:
	purchases_list.visible = false
	upgrades_list.visible = true

func _on_buy_rat_nest_pressed() -> void:
	var cost := _get_nest_cost()
	if gold < cost:
		return
	pending_purchase = "nest"
	pending_cost = cost
	placement_label.text = "Selecciona dónde colocar el nido de ratas."

func _on_buy_soldier_pressed() -> void:
	var cost := _get_soldier_cost()
	if gold < cost:
		return
	pending_purchase = "soldier"
	pending_cost = cost
	placement_label.text = "Selecciona dónde desplegar el soldado."

func _on_buy_click_upgrade_pressed() -> void:
	var cost := _get_click_upgrade_cost()
	if gold < cost:
		return
	gold -= cost
	click_upgrade_count += 1
	click_damage += 1
	_update_ui()

func _place_pending_purchase(click_pos: Vector2) -> void:
	gold -= pending_cost
	if pending_purchase == "nest":
		_spawn_nest(click_pos)
		nest_count += 1
	elif pending_purchase == "soldier":
		_spawn_soldier(click_pos)
		soldier_count += 1
	_clear_pending_purchase()
	_update_ui()

func _clear_pending_purchase() -> void:
	pending_purchase = ""
	pending_cost = 0
	placement_label.text = ""

func _spawn_nest(spawn_pos: Vector2) -> void:
	var nest := nest_scene.instantiate()
	nest.position = spawn_pos
	nest.game = self
	playfield.add_child(nest)

func _spawn_soldier(spawn_pos: Vector2) -> void:
	var soldier := soldier_scene.instantiate()
	soldier.position = spawn_pos
	soldier.game = self
	playfield.add_child(soldier)

func _update_ui() -> void:
	gold_label.text = "Oro: %d" % gold
	click_damage_label.text = "Daño: %d" % click_damage
	rat_nest_button.text = _format_cost(_get_nest_cost())
	soldier_button.text = _format_cost(_get_soldier_cost())
	click_upgrade_button.text = _format_cost(_get_click_upgrade_cost())

func _get_nest_cost() -> int:
	return int(BASE_NEST_COST * pow(NEST_COST_MULTIPLIER, nest_count))

func _get_soldier_cost() -> int:
	return int(BASE_SOLDIER_COST * pow(SOLDIER_COST_MULTIPLIER, soldier_count))

func _get_click_upgrade_cost() -> int:
	return int(BASE_CLICK_UPGRADE_COST * pow(CLICK_UPGRADE_MULTIPLIER, click_upgrade_count))

func _format_cost(cost: int) -> String:
	return "Coste: %d" % cost
