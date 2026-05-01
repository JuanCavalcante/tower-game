extends PanelContainer

const STYLE_EMPTY := Color(0.12, 0.09, 0.09, 0.9)
const STYLE_ITEM := Color(0.29, 0.18, 0.12, 0.95)
const STYLE_BLOCKED := Color(0.06, 0.06, 0.06, 0.85)
const BORDER_COLOR := Color(0.9, 0.82, 0.58, 0.95)
const BORDER_WIDTH := 2

signal slot_double_clicked(slot_id: String)
signal slot_hover_started(slot_id: String)
signal slot_hover_ended

var slot_id := ""
var slot_kind := "backpack"
var slot_label := ""
var slot_size := Vector2(96, 74)
var allowed_item_types: Array[String] = []
var blocked := false
var item_data: Dictionary = {}
var inventory_owner: Node = null

var _label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = slot_size
	mouse_entered.connect(func(): slot_hover_started.emit(slot_id))
	mouse_exited.connect(func(): slot_hover_ended.emit())
	_build_content()
	_refresh_visual()

func configure(
	new_slot_id: String,
	new_slot_kind: String,
	new_slot_label: String,
	new_slot_size: Vector2,
	new_allowed_item_types: Array[String],
	new_blocked: bool,
	new_inventory_owner: Node
) -> void:
	slot_id = new_slot_id
	slot_kind = new_slot_kind
	slot_label = new_slot_label
	slot_size = new_slot_size
	allowed_item_types = new_allowed_item_types.duplicate()
	blocked = new_blocked
	inventory_owner = new_inventory_owner
	custom_minimum_size = slot_size
	_refresh_visual()

func set_item(new_item_data: Dictionary) -> void:
	item_data = new_item_data.duplicate(true)
	_refresh_visual()

func get_item() -> Dictionary:
	return item_data.duplicate(true)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if blocked or item_data.is_empty():
		return null

	var payload := {
		"source_slot_id": slot_id,
		"item_data": item_data.duplicate(true)
	}

	var preview := Label.new()
	preview.text = str(item_data.get("display_name", "Item"))
	preview.add_theme_font_size_override("font_size", 14)
	preview.modulate = Color(1.0, 0.95, 0.8, 1.0)
	set_drag_preview(preview)
	return payload

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if blocked:
		return false
	if not (data is Dictionary):
		return false
	if not data.has("source_slot_id") or not data.has("item_data"):
		return false

	var incoming_item: Dictionary = data["item_data"]
	var incoming_type := str(incoming_item.get("item_type", ""))
	if slot_kind == "equipment":
		return allowed_item_types.has(incoming_type)
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if inventory_owner == null:
		return
	if not inventory_owner.has_method("on_slot_drop"):
		return
	inventory_owner.on_slot_drop(str(data.get("source_slot_id", "")), slot_id)

func _gui_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not mouse_event.pressed:
		return
	if not mouse_event.double_click:
		return
	slot_double_clicked.emit(slot_id)

func _build_content() -> void:
	if _label != null:
		return

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_label.clip_text = true
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_label.add_theme_font_size_override("font_size", 11)
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(_label)

func _refresh_visual() -> void:
	if _label == null:
		return

	var style := StyleBoxFlat.new()
	style.border_width_left = BORDER_WIDTH
	style.border_width_top = BORDER_WIDTH
	style.border_width_right = BORDER_WIDTH
	style.border_width_bottom = BORDER_WIDTH
	style.border_color = BORDER_COLOR
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5

	if blocked:
		style.bg_color = STYLE_BLOCKED
		_label.text = "Bloqueado"
		_label.modulate = Color(0.65, 0.65, 0.65, 1.0)
	elif item_data.is_empty():
		style.bg_color = STYLE_EMPTY
		if slot_kind == "equipment" and slot_label != "":
			_label.text = slot_label
		else:
			_label.text = ""
		_label.modulate = Color(0.8, 0.8, 0.8, 1.0)
	else:
		style.bg_color = STYLE_ITEM
		_label.text = str(item_data.get("display_name", "Item"))
		_label.modulate = Color(1.0, 0.94, 0.82, 1.0)

	add_theme_stylebox_override("panel", style)
