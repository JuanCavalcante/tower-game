extends Area2D

var active := false
var _player_in_range := false
var _ui_open := false
var _paused_by_portal := false

var _portal_ui: CanvasLayer
var _overlay: ColorRect
var _panel: PanelContainer
var _next_floor_button: Button
var _interact_prompt: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interact_prompt()
	_build_choice_ui()


func activate() -> void:
	active = true
	print("Portal ativado! Escolha retornar a cidade ou avancar para o proximo andar.")
	$AnimatedSprite2D.modulate = Color(0.5, 1.0, 0.5)
	_unlock_next_floor()
	_refresh_next_floor_button()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("ui_cancel") and _ui_open:
		_close_choice_ui()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("interact"):
		if _ui_open:
			_close_choice_ui()
			get_viewport().set_input_as_handled()
		elif _player_in_range:
			_open_choice_ui()
			get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_update_interact_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if _ui_open:
			_close_choice_ui()
		_update_interact_prompt()


func _build_interact_prompt() -> void:
	_interact_prompt = Label.new()
	_interact_prompt.name = "InteractPrompt"
	_interact_prompt.text = "Pressione E"
	_interact_prompt.position = Vector2(-56, -58)
	_interact_prompt.size = Vector2(112, 24)
	_interact_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interact_prompt.visible = false
	add_child(_interact_prompt)


func _build_choice_ui() -> void:
	_portal_ui = CanvasLayer.new()
	_portal_ui.name = "PortalChoiceUI"
	_portal_ui.layer = 20
	_portal_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_portal_ui)

	_overlay = ColorRect.new()
	_overlay.name = "Overlay"
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.color = Color(0, 0, 0, 0.45)
	_overlay.visible = false
	_portal_ui.add_child(_overlay)

	_panel = PanelContainer.new()
	_panel.name = "ChoicePanel"
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -180.0
	_panel.offset_top = -105.0
	_panel.offset_right = 180.0
	_panel.offset_bottom = 105.0
	_panel.visible = false
	_portal_ui.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Portal do Andar"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var return_button := Button.new()
	return_button.text = "Retornar a cidade"
	return_button.pressed.connect(_return_to_city)
	vbox.add_child(return_button)

	_next_floor_button = Button.new()
	_next_floor_button.pressed.connect(_go_to_next_floor)
	vbox.add_child(_next_floor_button)
	_refresh_next_floor_button()


func _open_choice_ui() -> void:
	_ui_open = true
	_pause_game_for_portal()
	_refresh_next_floor_button()
	_overlay.visible = true
	_panel.visible = true
	_update_interact_prompt()


func _close_choice_ui() -> void:
	_ui_open = false
	_overlay.visible = false
	_panel.visible = false
	_resume_game_from_portal()
	_update_interact_prompt()


func _update_interact_prompt() -> void:
	if _interact_prompt == null:
		return

	_interact_prompt.visible = _player_in_range or _ui_open
	_interact_prompt.text = "Pressione E para fechar" if _ui_open else "Pressione E"


func _refresh_next_floor_button() -> void:
	if _next_floor_button == null:
		return

	var next_floor: int = _get_next_floor()
	var has_next_floor := GameManager.has_floor(next_floor)
	_next_floor_button.disabled = not active
	_next_floor_button.text = "Ir Proximo Andar" if has_next_floor else "Concluir Torre"

	if not active:
		_next_floor_button.text += " (Bloqueado)"


func _return_to_city() -> void:
	_close_choice_ui()
	GameManager.return_to_hub(true)


func _go_to_next_floor() -> void:
	if not active:
		return

	_close_choice_ui()
	var next_floor: int = _get_next_floor()
	if GameManager.has_floor(next_floor):
		GameManager.unlock_floor(next_floor)
		GameManager.load_floor(next_floor, true, GameManager.SpawnContext.ADVANCE_FLOOR)
	else:
		GameManager.return_to_hub(true)


func _pause_game_for_portal() -> void:
	if get_tree().paused:
		return

	_paused_by_portal = true
	get_tree().paused = true


func _resume_game_from_portal() -> void:
	if not _paused_by_portal:
		return

	_paused_by_portal = false
	get_tree().paused = false


func _unlock_next_floor() -> void:
	var next_floor: int = _get_next_floor()
	if GameManager.has_floor(next_floor):
		GameManager.unlock_floor(next_floor)


func _get_next_floor() -> int:
	return int(GameManager.current_floor) + 1
