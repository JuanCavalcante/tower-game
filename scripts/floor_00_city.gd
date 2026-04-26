extends Node2D
class_name Floor00City

const TOTAL_PORTAL_FLOORS := 10

var _player_in_range := false
var _ui_open := false

@onready var interact_prompt: Label = $InteractPrompt
@onready var portal_ui: CanvasLayer = $PortalUI
@onready var portal_overlay: ColorRect = $PortalUI/Overlay
@onready var portal_panel: PanelContainer = $PortalUI/PortalPanel
@onready var floor_buttons_grid: GridContainer = $PortalUI/PortalPanel/VBox/FloorButtons
@onready var portal_anchor: Marker2D = $PortalAnchor
@onready var portal_area: Area2D = $PortalArea

func _ready() -> void:
	_sync_portal_layout_to_sprite()

	interact_prompt.visible = false
	portal_overlay.visible = false
	portal_panel.visible = false

	_build_floor_buttons()

	portal_area.body_entered.connect(_on_body_entered)
	portal_area.body_exited.connect(_on_body_exited)

	var close_btn: Button = $PortalUI/PortalPanel/VBox/CloseButton
	close_btn.pressed.connect(_close_ui)

func _sync_portal_layout_to_sprite() -> void:
	var portal_sprite: Node2D = _find_portal_sprite()
	var portal_position: Vector2 = portal_anchor.global_position

	if portal_sprite != null:
		portal_position = portal_sprite.global_position
	else:
		push_warning("Portal nao encontrado em CidadeHub; usando PortalAnchor como fallback.")

	portal_anchor.global_position = portal_position
	portal_area.global_position = portal_position
	interact_prompt.global_position = portal_position + Vector2(-95, -120)

func _find_portal_sprite() -> Node2D:
	var direct_portal := get_node_or_null("CidadeHub/Portal") as Node2D
	if direct_portal != null:
		return direct_portal

	var nested_portal := get_node_or_null("CidadeHub/Cidade_Hub/Portal") as Node2D
	if nested_portal != null:
		return nested_portal

	return null

func _build_floor_buttons() -> void:
	for child in floor_buttons_grid.get_children():
		child.queue_free()

	for floor_num in range(1, TOTAL_PORTAL_FLOORS + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(120, 40)
		btn.set_meta("floor_number", floor_num)

		_apply_floor_button_state(btn, floor_num)

		btn.pressed.connect(func(): _enter_floor(floor_num))
		floor_buttons_grid.add_child(btn)

func _apply_floor_button_state(btn: Button, floor_num: int) -> void:
	var unlocked: bool = GameManager.is_floor_unlocked(floor_num)
	btn.disabled = not unlocked
	btn.text = "Andar %d" % floor_num if unlocked else "🔒 Andar %d (Bloqueado)" % floor_num
	btn.tooltip_text = "" if unlocked else "🔒 Bloqueado"

func _refresh_floor_buttons() -> void:
	for child in floor_buttons_grid.get_children():
		var btn := child as Button
		if btn == null or not btn.has_meta("floor_number"):
			continue

		var floor_num: int = int(btn.get_meta("floor_number"))
		_apply_floor_button_state(btn, floor_num)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("interact"):
		if _player_in_range and not _ui_open:
			_open_ui()
		elif _ui_open:
			_close_ui()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		interact_prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		interact_prompt.visible = false
		if _ui_open:
			_close_ui()

func _open_ui() -> void:
	_ui_open = true
	_refresh_floor_buttons()
	portal_overlay.visible = true
	portal_panel.visible = true

func _close_ui() -> void:
	_ui_open = false
	portal_overlay.visible = false
	portal_panel.visible = false

func _enter_floor(floor_number: int) -> void:
	_close_ui()
	GameManager.load_floor(floor_number)
