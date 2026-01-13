extends Node2D

const BASE_NEST_COST := 5
const BASE_GOBLIN_NEST_COST := 20
const BASE_SOLDIER_COST := 5
const BASE_MAGE_COST := 20
const BASE_KNIGHT_COST := 100
const BASE_CLICK_UPGRADE_COST := 5
const BASE_RAT_STEROIDS_COST := 5
const BASE_GOBLIN_STEROIDS_COST := 20
const BASE_SOLDIER_STEROIDS_COST := 5
const BASE_MAGE_STEROIDS_COST := 20
const BASE_KNIGHT_STEROIDS_COST := 50
const BASE_KNIGHT_ANABOLIZANTES_COST := 100
const BASE_DOUBLE_FIREBALL_COST := 100
const BASE_TORBELLINO_COST := 100
const BASE_HAND_OF_GOD_COST := 100

const NEST_COST_MULTIPLIER := 2
const GOBLIN_NEST_COST_MULTIPLIER := 3
const SOLDIER_COST_MULTIPLIER := 2
const MAGE_COST_MULTIPLIER := 2
const KNIGHT_COST_MULTIPLIER := 3
const CLICK_UPGRADE_MULTIPLIER := 2
const RAT_STEROIDS_MULTIPLIER := 2
const GOBLIN_STEROIDS_MULTIPLIER := 3
const SOLDIER_STEROIDS_MULTIPLIER := 2
const MAGE_STEROIDS_MULTIPLIER := 2
const KNIGHT_STEROIDS_MULTIPLIER := 2
const KNIGHT_ANABOLIZANTES_MULTIPLIER := 3
const HAND_OF_GOD_MULTIPLIER := 2

const BASE_RAT_GOLD_VALUE := 1
const BASE_SOLDIER_DAMAGE := 1
const BASE_MAGE_DAMAGE := 3
const BASE_MAGE_RANGE := 120.0
const BASE_KNIGHT_SPEED := 220.0
const MAGE_RANGE_MULTIPLIER_PER_UPGRADE := 1.10
const KNIGHT_SIZE_MULTIPLIER_PER_UPGRADE := 1.10
const DELETE_SELECT_RADIUS := 26.0

@export var playfield_rect := Rect2()

@onready var playfield_backdrop: Polygon2D = $PlayfieldBackdrop
@onready var playfield: Node2D = $Playfield
@onready var gold_label: Label = $HUD/UIRoot/TopBar/TopBarContent/GoldLabel
@onready var click_damage_label: Label = $HUD/UIRoot/TopBar/TopBarContent/ClickDamageLabel
@onready var placement_label: Label = $HUD/UIRoot/TopBar/TopBarContent/PlacementLabel
@onready var trash_button: Button = $HUD/UIRoot/TopBar/TopBarContent/TrashButton
@onready var purchases_tab_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/TabButtons/PurchasesTabButton
@onready var upgrades_tab_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/TabButtons/UpgradesTabButton
@onready var purchases_list: VBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList
@onready var upgrades_list: VBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList
@onready var rat_nest_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/RatNestRow/RatNestCountLabel
@onready var goblin_nest_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/GoblinNestRow/GoblinNestCountLabel
@onready var soldier_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/SoldierRow/SoldierCountLabel
@onready var mage_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/MageRow/MageCountLabel
@onready var knight_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/KnightRow/KnightCountLabel
@onready var click_upgrade_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/ClickUpgradeRow/ClickUpgradeCountLabel
@onready var hand_of_god_row: HBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/HandOfGodRow
@onready var hand_of_god_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/HandOfGodRow/HandOfGodCountLabel
@onready var rat_steroids_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/RatSteroidsRow/RatSteroidsCountLabel
@onready var goblin_steroids_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/GoblinSteroidsRow/GoblinSteroidsCountLabel
@onready var soldier_steroids_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/SoldierSteroidsRow/SoldierSteroidsCountLabel
@onready var mage_steroids_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/MageSteroidsRow/MageSteroidsCountLabel
@onready var knight_steroids_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/KnightSteroidsRow/KnightSteroidsCountLabel
@onready var knight_anabolizantes_row: HBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/KnightAnabolizantesRow
@onready var knight_anabolizantes_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/KnightAnabolizantesRow/KnightAnabolizantesCountLabel
@onready var knight_anabolizantes_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/KnightAnabolizantesRow/KnightAnabolizantesButton
@onready var rat_nest_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/RatNestRow/RatNestBuyButton
@onready var goblin_nest_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/GoblinNestRow/GoblinNestBuyButton
@onready var soldier_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/SoldierRow/SoldierBuyButton
@onready var mage_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/MageRow/MageBuyButton
@onready var knight_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/PurchasesList/KnightRow/KnightBuyButton
@onready var click_upgrade_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/ClickUpgradeRow/ClickUpgradeButton
@onready var hand_of_god_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/HandOfGodRow/HandOfGodButton
@onready var rat_steroids_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/RatSteroidsRow/RatSteroidsButton
@onready var goblin_steroids_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/GoblinSteroidsRow/GoblinSteroidsButton
@onready var soldier_steroids_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/SoldierSteroidsRow/SoldierSteroidsButton
@onready var mage_steroids_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/MageSteroidsRow/MageSteroidsButton
@onready var knight_steroids_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/KnightSteroidsRow/KnightSteroidsButton
@onready var double_fireball_row: HBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/DoubleFireballRow
@onready var double_fireball_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/DoubleFireballRow/DoubleFireballCountLabel
@onready var double_fireball_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/DoubleFireballRow/DoubleFireballButton
@onready var torbellino_row: HBoxContainer = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/TorbellinoRow
@onready var torbellino_count_label: Label = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/TorbellinoRow/TorbellinoCountLabel
@onready var torbellino_button: Button = $HUD/UIRoot/Sidebar/SidebarContent/UpgradesList/TorbellinoRow/TorbellinoButton

var gold := 100000
var click_damage := 1
var nest_count := 0
var goblin_nest_count := 0
var soldier_count := 0
var mage_count := 0
var knight_count := 0
var click_upgrade_count := 0
var hand_of_god_count := 0
var rat_steroids_count := 0
var goblin_steroids_count := 0
var soldier_steroids_count := 0
var mage_steroids_count := 0
var knight_steroids_count := 0
var knight_anabolizantes_count := 0
var rat_gold_bonus := 0
var goblin_gold_bonus := 0
var click_kill_gold_multiplier := 1.0
var soldier_damage_bonus := 0
var mage_range_multiplier := 1.0
var knight_speed_multiplier := 1.0
var knight_size_multiplier := 1.0
var double_fireball_purchased := false
var torbellino_purchased := false

var pending_purchase := ""
var pending_cost := 0
var pending_delete := false

var _click_sound: AudioStreamPlayer2D
var _click_stream: AudioStreamGenerator

var rat_scene := preload("res://scenes/Rat.tscn")
var green_rat_scene := preload("res://scenes/GreenRat.tscn")
var nest_scene := preload("res://scenes/Nest.tscn")
var goblin_scene := preload("res://scenes/Goblin.tscn")
var goblin_nest_scene := preload("res://scenes/GoblinNest.tscn")
var soldier_scene := preload("res://scenes/Soldier.tscn")
var mage_scene := preload("res://scenes/Mage.tscn")
var knight_scene := preload("res://scenes/Knight.tscn")

func _ready() -> void:
	add_to_group("game")
	randomize()
	playfield_rect = _get_playfield_backdrop_rect(playfield_backdrop)
	purchases_tab_button.pressed.connect(_on_purchases_tab_pressed)
	upgrades_tab_button.pressed.connect(_on_upgrades_tab_pressed)
	trash_button.pressed.connect(_on_trash_pressed)
	rat_nest_button.pressed.connect(_on_buy_rat_nest_pressed)
	goblin_nest_button.pressed.connect(_on_buy_goblin_nest_pressed)
	soldier_button.pressed.connect(_on_buy_soldier_pressed)
	mage_button.pressed.connect(_on_buy_mage_pressed)
	knight_button.pressed.connect(_on_buy_knight_pressed)
	click_upgrade_button.pressed.connect(_on_buy_click_upgrade_pressed)
	hand_of_god_button.pressed.connect(_on_buy_hand_of_god_pressed)
	rat_steroids_button.pressed.connect(_on_buy_rat_steroids_pressed)
	goblin_steroids_button.pressed.connect(_on_buy_goblin_steroids_pressed)
	soldier_steroids_button.pressed.connect(_on_buy_soldier_steroids_pressed)
	mage_steroids_button.pressed.connect(_on_buy_mage_steroids_pressed)
	knight_steroids_button.pressed.connect(_on_buy_knight_steroids_pressed)
	knight_anabolizantes_button.pressed.connect(_on_buy_knight_anabolizantes_pressed)
	double_fireball_button.pressed.connect(_on_buy_double_fireball_pressed)
	torbellino_button.pressed.connect(_on_buy_torbellino_pressed)
	_click_stream = AudioStreamGenerator.new()
	_click_stream.mix_rate = 44100
	_click_stream.buffer_length = 0.4
	_click_sound = AudioStreamPlayer2D.new()
	_click_sound.stream = _click_stream
	_click_sound.volume_db = -3.0
	add_child(_click_sound)
	_update_ui()
	_show_purchases()
	
func polygon_local_rect(poly: Polygon2D) -> Rect2:
	var points := poly.polygon
	if points.is_empty():
		return Rect2()

	var min_v := points[0]
	var max_v := points[0]

	for p in points:
		min_v = min_v.min(p)
		max_v = max_v.max(p)

	return Rect2(min_v, max_v - min_v)

func _get_playfield_backdrop_rect(poly: Polygon2D) -> Rect2:
	var local_rect := polygon_local_rect(poly)
	if local_rect.size == Vector2.ZERO:
		return Rect2()

	var t := poly.global_transform

	var corners := [
		t * local_rect.position,
		t * (local_rect.position + Vector2(local_rect.size.x, 0)),
		t * (local_rect.position + Vector2(0, local_rect.size.y)),
		t * (local_rect.position + local_rect.size)
	]

	var min_x : Variant = corners[0].x
	var max_x : Variant = corners[0].x
	var min_y : Variant = corners[0].y
	var max_y : Variant = corners[0].y

	for c in corners:
		min_x = min(min_x, c.x)
		max_x = max(max_x, c.x)
		min_y = min(min_y, c.y)
		max_y = max(max_y, c.y)

	return Rect2(
		Vector2(min_x, min_y),
		Vector2(max_x - min_x, max_y - min_y)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var click_pos := get_viewport().get_mouse_position()
		if pending_delete:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				_clear_pending_delete()
				return
			if event.button_index != MOUSE_BUTTON_LEFT:
				return
			if not playfield_rect.has_point(click_pos):
				return
			var target := _find_deletable_target(click_pos)
			if target == null:
				placement_label.text = "Selecciona una unidad comprada para eliminar."
				return
			_delete_unit(target)
			_clear_pending_delete()
			return
		if event.button_index == MOUSE_BUTTON_LEFT and pending_purchase.is_empty():
			if playfield_rect.has_point(click_pos):
				_apply_click_damage_at(click_pos)
			return
		if pending_purchase.is_empty():
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not playfield_rect.has_point(click_pos):
			return
		_place_pending_purchase(click_pos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not pending_purchase.is_empty():
		var click_pos := get_viewport().get_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_clear_pending_purchase()
			return
		if event.button_index == MOUSE_BUTTON_LEFT and not playfield_rect.has_point(click_pos):
			_clear_pending_purchase()

func apply_click_damage(rat: Node) -> void:
	if rat.has_method("take_damage"):
		rat.take_damage(click_damage, "click")

func _apply_click_damage_at(click_pos: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = click_pos
	params.collide_with_areas = true
	var hits := space_state.intersect_point(params, 32)
	for hit in hits:
		var collider : Variant = hit.get("collider")
		if collider is Node and collider.is_in_group("enemies"):
			apply_click_damage(collider)
			_play_click_sound(click_pos)
			return

func spawn_rat_at_position(spawn_pos: Vector2, is_green: bool = false) -> Node:
	var rat_scene_to_use := green_rat_scene if is_green else rat_scene
	var rat := rat_scene_to_use.instantiate()
	rat.position = spawn_pos
	rat.game = self
	playfield.add_child(rat)
	rat.died.connect(_on_enemy_died)
	return rat

func spawn_goblin_at_position(spawn_pos: Vector2) -> Node:
	var goblin := goblin_scene.instantiate()
	goblin.position = spawn_pos
	goblin.game = self
	playfield.add_child(goblin)
	goblin.died.connect(_on_enemy_died)
	return goblin

func get_random_near_enemy(from_pos: Vector2, candidates_count: int = 3) -> Node:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var candidates: Array[Dictionary] = []
	for enemy in enemies:
		candidates.append({
			"enemy": enemy,
			"distance": from_pos.distance_to(enemy.global_position)
		})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["distance"] < b["distance"]
	)
	var max_candidates : Variant = min(candidates_count, candidates.size())
	var choice_index := randi_range(0, max_candidates - 1)
	return candidates[choice_index]["enemy"]

func get_random_near_player_unit(from_pos: Vector2, candidates_count: int = 3) -> Node:
	var candidates: Array[Dictionary] = []
	for group_name in ["soldiers", "mages", "knights", "nests", "goblin_nests"]:
		for unit in get_tree().get_nodes_in_group(group_name):
			candidates.append({
				"unit": unit,
				"distance": from_pos.distance_to(unit.global_position)
			})
	if candidates.is_empty():
		return null
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["distance"] < b["distance"]
	)
	var max_candidates : Variant = min(candidates_count, candidates.size())
	var choice_index := randi_range(0, max_candidates - 1)
	return candidates[choice_index]["unit"]

func _on_enemy_died(gold_value: int, enemy_kind: String, killed_by_click: bool) -> void:
	var base_gain := gold_value
	if enemy_kind == "goblin":
		base_gain += goblin_gold_bonus
	else:
		base_gain += rat_gold_bonus
	if killed_by_click:
		gold += int(round(base_gain * click_kill_gold_multiplier))
	else:
		gold += base_gain
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
	_clear_pending_delete()
	pending_purchase = "nest"
	pending_cost = cost
	placement_label.text = "Selecciona dónde colocar el nido de ratas."

func _on_buy_goblin_nest_pressed() -> void:
	var cost := _get_goblin_nest_cost()
	if gold < cost:
		return
	_clear_pending_delete()
	pending_purchase = "goblin_nest"
	pending_cost = cost
	placement_label.text = "Selecciona dónde colocar el nido de goblins."

func _on_buy_soldier_pressed() -> void:
	var cost := _get_soldier_cost()
	if gold < cost:
		return
	_clear_pending_delete()
	pending_purchase = "soldier"
	pending_cost = cost
	placement_label.text = "Selecciona dónde desplegar el soldado."

func _on_buy_mage_pressed() -> void:
	var cost := _get_mage_cost()
	if gold < cost:
		return
	_clear_pending_delete()
	pending_purchase = "mage"
	pending_cost = cost
	placement_label.text = "Selecciona dónde desplegar el mago."

func _on_buy_knight_pressed() -> void:
	var cost := _get_knight_cost()
	if gold < cost:
		return
	_clear_pending_delete()
	pending_purchase = "knight"
	pending_cost = cost
	placement_label.text = "Selecciona dónde desplegar el caballero."

func _on_buy_click_upgrade_pressed() -> void:
	var cost := _get_click_upgrade_cost()
	if gold < cost:
		return
	gold -= cost
	click_upgrade_count += 1
	click_damage += 1
	_update_ui()

func _on_buy_hand_of_god_pressed() -> void:
	var cost := _get_hand_of_god_cost()
	if gold < cost:
		return
	gold -= cost
	hand_of_god_count += 1
	click_kill_gold_multiplier *= 1.5
	_update_ui()

func _on_buy_rat_steroids_pressed() -> void:
	var cost := _get_rat_steroids_cost()
	if gold < cost:
		return
	gold -= cost
	rat_steroids_count += 1
	rat_gold_bonus += 1
	_update_ui()

func _on_buy_goblin_steroids_pressed() -> void:
	var cost := _get_goblin_steroids_cost()
	if gold < cost:
		return
	gold -= cost
	goblin_steroids_count += 1
	goblin_gold_bonus += 5
	_update_ui()

func _on_buy_soldier_steroids_pressed() -> void:
	var cost := _get_soldier_steroids_cost()
	if gold < cost:
		return
	gold -= cost
	soldier_steroids_count += 1
	soldier_damage_bonus += 1
	_update_soldier_damage()
	_update_ui()

func _on_buy_mage_steroids_pressed() -> void:
	var cost := _get_mage_steroids_cost()
	if gold < cost:
		return
	gold -= cost
	mage_steroids_count += 1
	mage_range_multiplier *= MAGE_RANGE_MULTIPLIER_PER_UPGRADE
	_update_mage_stats()
	_update_ui()

func _on_buy_knight_steroids_pressed() -> void:
	var cost := _get_knight_steroids_cost()
	if gold < cost:
		return
	gold -= cost
	knight_steroids_count += 1
	knight_speed_multiplier *= 1.1
	_update_knight_speed()
	_update_ui()

func _on_buy_knight_anabolizantes_pressed() -> void:
	var cost := _get_knight_anabolizantes_cost()
	if gold < cost:
		return
	gold -= cost
	knight_anabolizantes_count += 1
	knight_size_multiplier *= KNIGHT_SIZE_MULTIPLIER_PER_UPGRADE
	_update_knight_size()
	_update_ui()

func _on_buy_double_fireball_pressed() -> void:
	if double_fireball_purchased:
		return
	var cost := BASE_DOUBLE_FIREBALL_COST
	if gold < cost:
		return
	gold -= cost
	double_fireball_purchased = true
	_update_ui()

func _on_buy_torbellino_pressed() -> void:
	if torbellino_purchased:
		return
	var cost := BASE_TORBELLINO_COST
	if gold < cost:
		return
	gold -= cost
	torbellino_purchased = true
	_update_ui()

func _place_pending_purchase(click_pos: Vector2) -> void:
	var cost := _get_pending_purchase_cost()
	if gold < cost:
		_clear_pending_purchase()
		return
	gold -= cost
	if pending_purchase == "nest":
		_spawn_rat_nest(click_pos)
		nest_count += 1
	elif pending_purchase == "goblin_nest":
		_spawn_goblin_nest(click_pos)
		goblin_nest_count += 1
	elif pending_purchase == "soldier":
		_spawn_soldier(click_pos)
		soldier_count += 1
	elif pending_purchase == "mage":
		_spawn_mage(click_pos)
		mage_count += 1
	elif pending_purchase == "knight":
		_spawn_knight(click_pos)
		knight_count += 1
	_refresh_pending_purchase()
	_update_ui()

func _clear_pending_purchase() -> void:
	pending_purchase = ""
	pending_cost = 0
	placement_label.text = ""

func _refresh_pending_purchase() -> void:
	pending_cost = _get_pending_purchase_cost()
	if gold < pending_cost:
		_clear_pending_purchase()

func _on_trash_pressed() -> void:
	if pending_delete:
		_clear_pending_delete()
		return
	if not pending_purchase.is_empty():
		_clear_pending_purchase()
	pending_delete = true
	placement_label.text = "Selecciona la unidad que quieres eliminar."

func _clear_pending_delete() -> void:
	pending_delete = false
	placement_label.text = ""

func _find_deletable_target(click_pos: Vector2) -> Node2D:
	var closest_target: Node2D = null
	var closest_distance := DELETE_SELECT_RADIUS
	for group_name in ["nests", "goblin_nests", "soldiers", "mages", "knights"]:
		for unit in get_tree().get_nodes_in_group(group_name):
			if unit is Node2D:
				var distance := click_pos.distance_to(unit.global_position)
				if distance <= closest_distance:
					closest_distance = distance
					closest_target = unit
	return closest_target

func _delete_unit(unit: Node2D) -> void:
	if unit.is_in_group("nests"):
		nest_count = max(nest_count - 1, 0)
	elif unit.is_in_group("goblin_nests"):
		goblin_nest_count = max(goblin_nest_count - 1, 0)
	elif unit.is_in_group("soldiers"):
		soldier_count = max(soldier_count - 1, 0)
	elif unit.is_in_group("mages"):
		mage_count = max(mage_count - 1, 0)
	elif unit.is_in_group("knights"):
		knight_count = max(knight_count - 1, 0)
	unit.queue_free()
	_update_ui()

func _spawn_rat_nest(spawn_pos: Vector2) -> void:
	var nest := nest_scene.instantiate()
	nest.position = spawn_pos
	nest.game = self
	playfield.add_child(nest)

func _spawn_goblin_nest(spawn_pos: Vector2) -> void:
	var nest := goblin_nest_scene.instantiate()
	nest.position = spawn_pos
	nest.game = self
	playfield.add_child(nest)

func _spawn_soldier(spawn_pos: Vector2) -> void:
	var soldier := soldier_scene.instantiate()
	soldier.position = spawn_pos
	soldier.game = self
	if "attack_damage" in soldier:
		soldier.attack_damage = BASE_SOLDIER_DAMAGE + soldier_damage_bonus
	playfield.add_child(soldier)

func _spawn_mage(spawn_pos: Vector2) -> void:
	var mage := mage_scene.instantiate()
	mage.position = spawn_pos
	mage.game = self
	if "attack_range" in mage:
		mage.attack_range = BASE_MAGE_RANGE * mage_range_multiplier
	playfield.add_child(mage)

func _spawn_knight(spawn_pos: Vector2) -> void:
	var knight := knight_scene.instantiate()
	knight.position = spawn_pos
	knight.game = self
	if "speed" in knight:
		knight.speed = BASE_KNIGHT_SPEED * knight_speed_multiplier
	knight.scale = Vector2.ONE * knight_size_multiplier
	playfield.add_child(knight)

func _update_ui() -> void:
	gold_label.text = "🪙 %d" % gold
	click_damage_label.text = "Daño: %d" % click_damage
	rat_nest_count_label.text = str(nest_count)
	goblin_nest_count_label.text = str(goblin_nest_count)
	soldier_count_label.text = str(soldier_count)
	mage_count_label.text = str(mage_count)
	knight_count_label.text = str(knight_count)
	click_upgrade_count_label.text = str(click_upgrade_count)
	hand_of_god_count_label.text = str(hand_of_god_count)
	rat_steroids_count_label.text = str(rat_steroids_count)
	goblin_steroids_count_label.text = str(goblin_steroids_count)
	soldier_steroids_count_label.text = str(soldier_steroids_count)
	mage_steroids_count_label.text = str(mage_steroids_count)
	knight_steroids_count_label.text = str(knight_steroids_count)
	knight_anabolizantes_count_label.text = str(knight_anabolizantes_count)
	double_fireball_count_label.text = "1" if double_fireball_purchased else "0"
	torbellino_count_label.text = "1" if torbellino_purchased else "0"
	rat_nest_button.text = _format_cost(_get_nest_cost())
	goblin_nest_button.text = _format_cost(_get_goblin_nest_cost())
	soldier_button.text = _format_cost(_get_soldier_cost())
	mage_button.text = _format_cost(_get_mage_cost())
	knight_button.text = _format_cost(_get_knight_cost())
	click_upgrade_button.text = _format_cost(_get_click_upgrade_cost())
	hand_of_god_button.text = _format_cost(_get_hand_of_god_cost())
	rat_steroids_button.text = _format_cost(_get_rat_steroids_cost())
	goblin_steroids_button.text = _format_cost(_get_goblin_steroids_cost())
	soldier_steroids_button.text = _format_cost(_get_soldier_steroids_cost())
	mage_steroids_button.text = _format_cost(_get_mage_steroids_cost())
	knight_steroids_button.text = _format_cost(_get_knight_steroids_cost())
	knight_anabolizantes_button.text = _format_cost(_get_knight_anabolizantes_cost())
	double_fireball_row.visible = mage_steroids_count >= 5 or double_fireball_purchased
	double_fireball_button.disabled = double_fireball_purchased
	double_fireball_button.text = "-" if double_fireball_purchased else _format_cost(BASE_DOUBLE_FIREBALL_COST)
	torbellino_row.visible = soldier_steroids_count >= 5 or torbellino_purchased
	torbellino_button.disabled = torbellino_purchased
	torbellino_button.text = "-" if torbellino_purchased else _format_cost(BASE_TORBELLINO_COST)
	hand_of_god_row.visible = click_upgrade_count >= 5 or hand_of_god_count > 0
	knight_anabolizantes_row.visible = knight_steroids_count >= 5 or knight_anabolizantes_count > 0

func _get_nest_cost() -> int:
	return int(BASE_NEST_COST * pow(NEST_COST_MULTIPLIER, nest_count))

func _get_goblin_nest_cost() -> int:
	return int(BASE_GOBLIN_NEST_COST * pow(GOBLIN_NEST_COST_MULTIPLIER, goblin_nest_count))

func _get_soldier_cost() -> int:
	return int(BASE_SOLDIER_COST * pow(SOLDIER_COST_MULTIPLIER, soldier_count))

func _get_mage_cost() -> int:
	return int(BASE_MAGE_COST * pow(MAGE_COST_MULTIPLIER, mage_count))

func _get_knight_cost() -> int:
	return int(BASE_KNIGHT_COST * pow(KNIGHT_COST_MULTIPLIER, knight_count))

func _get_pending_purchase_cost() -> int:
	if pending_purchase == "nest":
		return _get_nest_cost()
	if pending_purchase == "goblin_nest":
		return _get_goblin_nest_cost()
	if pending_purchase == "soldier":
		return _get_soldier_cost()
	if pending_purchase == "mage":
		return _get_mage_cost()
	if pending_purchase == "knight":
		return _get_knight_cost()
	return 0

func _get_click_upgrade_cost() -> int:
	return int(BASE_CLICK_UPGRADE_COST * pow(CLICK_UPGRADE_MULTIPLIER, click_upgrade_count))

func _get_hand_of_god_cost() -> int:
	return int(BASE_HAND_OF_GOD_COST * pow(HAND_OF_GOD_MULTIPLIER, hand_of_god_count))

func _get_rat_steroids_cost() -> int:
	return int(BASE_RAT_STEROIDS_COST * pow(RAT_STEROIDS_MULTIPLIER, rat_steroids_count))

func _get_goblin_steroids_cost() -> int:
	return int(BASE_GOBLIN_STEROIDS_COST * pow(GOBLIN_STEROIDS_MULTIPLIER, goblin_steroids_count))

func _get_soldier_steroids_cost() -> int:
	return int(BASE_SOLDIER_STEROIDS_COST * pow(SOLDIER_STEROIDS_MULTIPLIER, soldier_steroids_count))

func _get_mage_steroids_cost() -> int:
	return int(BASE_MAGE_STEROIDS_COST * pow(MAGE_STEROIDS_MULTIPLIER, mage_steroids_count))

func _get_knight_steroids_cost() -> int:
	return int(BASE_KNIGHT_STEROIDS_COST * pow(KNIGHT_STEROIDS_MULTIPLIER, knight_steroids_count))

func _get_knight_anabolizantes_cost() -> int:
	return int(BASE_KNIGHT_ANABOLIZANTES_COST * pow(KNIGHT_ANABOLIZANTES_MULTIPLIER, knight_anabolizantes_count))

func _update_soldier_damage() -> void:
	for soldier in get_tree().get_nodes_in_group("soldiers"):
		if "attack_damage" in soldier:
			soldier.attack_damage = BASE_SOLDIER_DAMAGE + soldier_damage_bonus

func _update_mage_stats() -> void:
	for mage in get_tree().get_nodes_in_group("mages"):
		if "attack_range" in mage:
			mage.attack_range = BASE_MAGE_RANGE * mage_range_multiplier

func _update_knight_speed() -> void:
	for knight in get_tree().get_nodes_in_group("knights"):
		if "speed" in knight:
			knight.speed = BASE_KNIGHT_SPEED * knight_speed_multiplier

func _update_knight_size() -> void:
	for knight in get_tree().get_nodes_in_group("knights"):
		knight.scale = Vector2.ONE * knight_size_multiplier

func is_double_fireball_unlocked() -> bool:
	return double_fireball_purchased

func is_torbellino_unlocked() -> bool:
	return torbellino_purchased

func _play_click_sound(click_pos: Vector2) -> void:
	if _click_sound == null or _click_stream == null:
		return
	_click_sound.global_position = click_pos
	_click_sound.play()
	var playback := _click_sound.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	var sample_rate := _click_stream.mix_rate
	var duration := 0.35
	var sample_count := int(sample_rate * duration)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var envelope := 1.0
		if t < 0.03:
			envelope = t / 0.03
		elif t > 0.2:
			envelope = max(0.0, (duration - t) / 0.15)
		var rumble := sin(2.0 * PI * 80.0 * t) * 0.6
		var crack := randf_range(-1.0, 1.0) * 0.25
		var sample := (rumble + crack) * envelope * 0.7
		playback.push_frame(Vector2(sample, sample))

func _format_cost(cost: int) -> String:
	return "Coste: %d" % cost
