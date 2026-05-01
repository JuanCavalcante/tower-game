extends Control

const TOTAL_BACKPACK_SLOTS := 30
const UNLOCKED_BACKPACK_SLOTS := 15
const BACKPACK_SLOT_SIZE := Vector2(100, 64)
const EQUIPMENT_SLOT_SIZE := Vector2(92, 72)
const TOOLTIP_OFFSET := Vector2(14, 14)

const EQUIPMENT_LAYOUT := [
	{"id": "head", "label": "Cabeca", "types": ["helmet"]},
	{"id": "necklace", "label": "Colar", "types": ["necklace"]},
	{"id": "left_hand", "label": "Mao Esquerda", "types": ["shield"]},
	{"id": "chest", "label": "Peitoral", "types": ["chest"]},
	{"id": "right_hand", "label": "Mao Direita", "types": ["weapon"]},
	{"id": "ring_1", "label": "Anel 1", "types": ["ring"]},
	{"id": "legs", "label": "Pernas", "types": ["legs"]},
	{"id": "ring_2", "label": "Anel 2", "types": ["ring"]},
	{"id": "feet", "label": "Pes", "types": ["boots"]}
]

@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Header/CloseButton
@onready var coins_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Body/EquipmentColumn/EquipmentCard/MarginContainer/EquipmentBody/CoinsRow/CoinsValue
@onready var backpack_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Body/BackpackColumn/BackpackCard/MarginContainer/BackpackBody/SlotsGrid
@onready var equipment_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Body/EquipmentColumn/EquipmentCard/MarginContainer/EquipmentBody/EquipmentSlotsGrid

signal close_requested

var _slot_nodes: Dictionary = {}
var _backpack_data: Array[Dictionary] = []
var _equipment_data: Dictionary = {}
var _equipment_config_by_id: Dictionary = {}
var _hover_tooltip_panel: PanelContainer
var _hover_tooltip_label: Label

const EQUIPMENT_GRID_CELL_COUNT := 12
const EQUIPMENT_GRID_POSITIONS := {
	"head": 1,
	"left_hand": 3,
	"chest": 4,
	"right_hand": 5,
	"necklace": 6,
	"legs": 7,
	"ring_2": 8,
	"ring_1": 9,
	"feet": 10
}

func _ready() -> void:
	close_button.pressed.connect(func(): close_requested.emit())
	PlayerStats.coins_changed.connect(_on_coins_changed)
	_build_hover_tooltip()
	_init_state()
	_build_backpack_slots()
	_build_equipment_slots()
	_refresh_all_slots()
	_on_coins_changed(PlayerStats.coins)
	_apply_equipment_effects_to_player_stats()

func _process(_delta: float) -> void:
	if _hover_tooltip_panel != null and _hover_tooltip_panel.visible:
		_update_tooltip_position()

func on_slot_drop(source_slot_id: String, target_slot_id: String) -> void:
	if source_slot_id == target_slot_id:
		return

	var source_item := _get_slot_item(source_slot_id)
	if source_item.is_empty():
		return

	var target_item := _get_slot_item(target_slot_id)
	if not _can_place_item_in_slot(source_item, target_slot_id):
		return
	if not _can_place_item_in_slot(target_item, source_slot_id):
		return

	_set_slot_item(source_slot_id, target_item)
	_set_slot_item(target_slot_id, source_item)
	_refresh_slot(source_slot_id)
	_refresh_slot(target_slot_id)
	_persist_inventory_state()
	_apply_equipment_effects_to_player_stats()

func _init_state() -> void:
	_reset_inventory_state()
	if _load_inventory_state_from_player_stats():
		return
	_persist_inventory_state()

func _reset_inventory_state() -> void:
	_backpack_data.resize(TOTAL_BACKPACK_SLOTS)
	for i in range(TOTAL_BACKPACK_SLOTS):
		_backpack_data[i] = {}

	_equipment_data.clear()
	_equipment_config_by_id.clear()
	for config in EQUIPMENT_LAYOUT:
		var slot_id := str(config["id"])
		_equipment_data[slot_id] = {}
		_equipment_config_by_id[slot_id] = config

func _build_backpack_slots() -> void:
	for i in range(TOTAL_BACKPACK_SLOTS):
		var slot := preload("res://scripts/ui/inventory_slot.gd").new()
		var slot_id := _get_backpack_slot_id(i)
		slot.configure(slot_id, "backpack", "", BACKPACK_SLOT_SIZE, [], i >= UNLOCKED_BACKPACK_SLOTS, self)
		slot.slot_double_clicked.connect(_on_slot_double_clicked)
		slot.slot_hover_started.connect(_on_slot_hover_started)
		slot.slot_hover_ended.connect(_on_slot_hover_ended)
		backpack_grid.add_child(slot)
		_slot_nodes[slot_id] = slot

func _build_equipment_slots() -> void:
	for cell_index in range(EQUIPMENT_GRID_CELL_COUNT):
		var equipment_id := _get_equipment_id_for_cell(cell_index)
		if equipment_id == "":
			var spacer := Control.new()
			spacer.custom_minimum_size = EQUIPMENT_SLOT_SIZE
			equipment_grid.add_child(spacer)
			continue

		var config := _equipment_config_by_id.get(equipment_id, {}) as Dictionary
		var slot := preload("res://scripts/ui/inventory_slot.gd").new()
		var slot_id := _get_equipment_slot_id(equipment_id)
		var allowed_types: Array[String] = []
		for item_type in config.get("types", []):
			allowed_types.append(str(item_type))
		slot.configure(slot_id, "equipment", str(config.get("label", "")), EQUIPMENT_SLOT_SIZE, allowed_types, false, self)
		slot.slot_double_clicked.connect(_on_slot_double_clicked)
		slot.slot_hover_started.connect(_on_slot_hover_started)
		slot.slot_hover_ended.connect(_on_slot_hover_ended)
		equipment_grid.add_child(slot)
		_slot_nodes[slot_id] = slot

func _refresh_all_slots() -> void:
	for i in range(TOTAL_BACKPACK_SLOTS):
		_refresh_slot(_get_backpack_slot_id(i))
	for config in EQUIPMENT_LAYOUT:
		_refresh_slot(_get_equipment_slot_id(str(config["id"])))

func _refresh_slot(slot_id: String) -> void:
	var slot_node = _slot_nodes.get(slot_id)
	if slot_node == null:
		return
	slot_node.set_item(_get_slot_item(slot_id))

func _get_slot_item(slot_id: String) -> Dictionary:
	if slot_id.begins_with("backpack_"):
		var index := int(slot_id.trim_prefix("backpack_"))
		if index < 0 or index >= _backpack_data.size():
			return {}
		return _backpack_data[index].duplicate(true)

	var equipment_key := slot_id.trim_prefix("equip_")
	return (_equipment_data.get(equipment_key, {}) as Dictionary).duplicate(true)

func _set_slot_item(slot_id: String, item_data: Dictionary) -> void:
	var copied := item_data.duplicate(true)
	if slot_id.begins_with("backpack_"):
		var index := int(slot_id.trim_prefix("backpack_"))
		if index < 0 or index >= _backpack_data.size():
			return
		_backpack_data[index] = copied
		return

	var equipment_key := slot_id.trim_prefix("equip_")
	_equipment_data[equipment_key] = copied

func _can_place_item_in_slot(item_data: Dictionary, slot_id: String) -> bool:
	if item_data.is_empty():
		return true

	if slot_id.begins_with("backpack_"):
		var index := int(slot_id.trim_prefix("backpack_"))
		return index >= 0 and index < UNLOCKED_BACKPACK_SLOTS

	var equipment_key := slot_id.trim_prefix("equip_")
	var config := _find_equipment_config(equipment_key)
	if config.is_empty():
		return false

	var item_type := str(item_data.get("item_type", ""))
	for accepted_type in config["types"]:
		if str(accepted_type) == item_type:
			return true
	return false

func _find_equipment_config(slot_id: String) -> Dictionary:
	return _equipment_config_by_id.get(slot_id, {}) as Dictionary

func _get_backpack_slot_id(index: int) -> String:
	return "backpack_%d" % index

func _get_equipment_slot_id(id: String) -> String:
	return "equip_%s" % id

func _get_equipment_id_for_cell(cell_index: int) -> String:
	for key in EQUIPMENT_GRID_POSITIONS.keys():
		if int(EQUIPMENT_GRID_POSITIONS[key]) == cell_index:
			return str(key)
	return ""

func _on_coins_changed(value: int) -> void:
	coins_label.text = str(value)

func _on_slot_double_clicked(slot_id: String) -> void:
	if slot_id.begins_with("equip_"):
		_try_unequip_from_slot(slot_id)
		return
	if not slot_id.begins_with("backpack_"):
		return

	var source_item := _get_slot_item(slot_id)
	if source_item.is_empty():
		return

	var item_type := str(source_item.get("item_type", ""))
	if item_type == "":
		return

	var compatible_targets: Array[String] = []
	for config in EQUIPMENT_LAYOUT:
		for accepted_type in config["types"]:
			if str(accepted_type) == item_type:
				compatible_targets.append(_get_equipment_slot_id(str(config["id"])))
				break

	if compatible_targets.is_empty():
		return

	var chosen_target := compatible_targets[0]
	for target_slot_id in compatible_targets:
		if _get_slot_item(target_slot_id).is_empty():
			chosen_target = target_slot_id
			break

	var target_item := _get_slot_item(chosen_target)
	_set_slot_item(slot_id, target_item)
	_set_slot_item(chosen_target, source_item)
	_refresh_slot(slot_id)
	_refresh_slot(chosen_target)
	_persist_inventory_state()
	_apply_equipment_effects_to_player_stats()

func _try_unequip_from_slot(equip_slot_id: String) -> void:
	var equipped_item := _get_slot_item(equip_slot_id)
	if equipped_item.is_empty():
		return

	var free_backpack_slot := _find_first_empty_backpack_slot()
	if free_backpack_slot == "":
		return

	_set_slot_item(equip_slot_id, {})
	_set_slot_item(free_backpack_slot, equipped_item)
	_refresh_slot(equip_slot_id)
	_refresh_slot(free_backpack_slot)
	_persist_inventory_state()
	_apply_equipment_effects_to_player_stats()

func _find_first_empty_backpack_slot() -> String:
	for index in range(UNLOCKED_BACKPACK_SLOTS):
		var slot_id := _get_backpack_slot_id(index)
		if _get_slot_item(slot_id).is_empty():
			return slot_id
	return ""

func reload_from_player_stats() -> void:
	if not _load_inventory_state_from_player_stats():
		_reset_inventory_state()
		_persist_inventory_state()
	_refresh_all_slots()
	_apply_equipment_effects_to_player_stats()

func _persist_inventory_state() -> void:
	PlayerStats.set_inventory_state(_backpack_data, _equipment_data)

func _load_inventory_state_from_player_stats() -> bool:
	if not PlayerStats.has_inventory_state():
		return false

	var state: Dictionary = PlayerStats.get_inventory_state()
	var saved_backpack = state.get("backpack_slots", [])
	var saved_equipment = state.get("equipment_slots", {})
	if not (saved_backpack is Array):
		return false
	if not (saved_equipment is Dictionary):
		return false

	var backpack_array: Array = saved_backpack as Array
	if backpack_array.size() != TOTAL_BACKPACK_SLOTS:
		return false

	for index in range(TOTAL_BACKPACK_SLOTS):
		var entry = backpack_array[index]
		if entry is Dictionary:
			_backpack_data[index] = (entry as Dictionary).duplicate(true)
		else:
			_backpack_data[index] = {}

	var equipment_dict: Dictionary = saved_equipment as Dictionary
	for config in EQUIPMENT_LAYOUT:
		var equipment_id := str(config["id"])
		var equipment_entry = equipment_dict.get(equipment_id, {})
		if equipment_entry is Dictionary:
			_equipment_data[equipment_id] = (equipment_entry as Dictionary).duplicate(true)
		else:
			_equipment_data[equipment_id] = {}

	return true

func _apply_equipment_effects_to_player_stats() -> void:
	var bonus_totals := {
		"weapon_damage_bonus": 0,
		"flat_armor_bonus": 0,
		"damage_reduction_bonus_ratio": 0.0,
		"move_speed_bonus_ratio": 0.0,
		"crit_chance_bonus_percent": 0
	}

	for config in EQUIPMENT_LAYOUT:
		var slot_id := _get_equipment_slot_id(str(config["id"]))
		var item_data := _get_slot_item(slot_id)
		if item_data.is_empty():
			continue

		var effects := item_data.get("effects", {}) as Dictionary
		bonus_totals["weapon_damage_bonus"] += int(effects.get("weapon_damage_bonus", 0))
		bonus_totals["flat_armor_bonus"] += int(effects.get("flat_armor_bonus", 0))
		bonus_totals["damage_reduction_bonus_ratio"] += float(effects.get("damage_reduction_bonus_ratio", 0.0))
		bonus_totals["move_speed_bonus_ratio"] += float(effects.get("move_speed_bonus_ratio", 0.0))
		bonus_totals["crit_chance_bonus_percent"] += int(effects.get("crit_chance_bonus_percent", 0))

	PlayerStats.apply_inventory_item_bonuses(bonus_totals)

func _build_hover_tooltip() -> void:
	_hover_tooltip_panel = PanelContainer.new()
	_hover_tooltip_panel.name = "HoverTooltip"
	_hover_tooltip_panel.visible = false
	_hover_tooltip_panel.z_index = 220

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.78)
	style.border_color = Color(0.9, 0.82, 0.58, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	_hover_tooltip_panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	_hover_tooltip_panel.add_child(margin)

	_hover_tooltip_label = Label.new()
	_hover_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hover_tooltip_label.custom_minimum_size = Vector2(280, 0)
	margin.add_child(_hover_tooltip_label)

	add_child(_hover_tooltip_panel)

func _on_slot_hover_started(slot_id: String) -> void:
	var item_data := _get_slot_item(slot_id)
	if item_data.is_empty():
		_hide_tooltip()
		return

	_hover_tooltip_label.text = _format_item_tooltip(item_data)
	_hover_tooltip_panel.visible = true
	_update_tooltip_position()

func _on_slot_hover_ended() -> void:
	_hide_tooltip()

func _hide_tooltip() -> void:
	if _hover_tooltip_panel == null:
		return
	_hover_tooltip_panel.visible = false

func _update_tooltip_position() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _hover_tooltip_panel.size
	var desired_position: Vector2 = get_viewport().get_mouse_position() + TOOLTIP_OFFSET

	if desired_position.x + panel_size.x > viewport_size.x - 8.0:
		desired_position.x = viewport_size.x - panel_size.x - 8.0
	if desired_position.y + panel_size.y > viewport_size.y - 8.0:
		desired_position.y = viewport_size.y - panel_size.y - 8.0

	desired_position.x = max(desired_position.x, 8.0)
	desired_position.y = max(desired_position.y, 8.0)
	_hover_tooltip_panel.position = desired_position

func _format_item_tooltip(item_data: Dictionary) -> String:
	var display_name := str(item_data.get("display_name", "Item"))
	var description := str(item_data.get("description", "Sem descricao."))
	var type_label := str(item_data.get("type_label", "Desconhecido"))
	var rarity := str(item_data.get("rarity", "Normal"))
	var properties: Array[String] = []
	for entry in item_data.get("properties", []):
		properties.append(str(entry))

	var properties_block := "Sem propriedades"
	if not properties.is_empty():
		properties_block = "\n".join(properties)

	return "%s\n\nDescricao:\n%s\n\nPropriedades:\n%s\n\nTipo: %s\nRaridade: %s" % [
		display_name,
		description,
		properties_block,
		type_label,
		rarity
	]
