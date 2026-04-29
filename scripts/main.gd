extends Node

const ENTRY_PAUSE_SECONDS := 1.2
const INITIAL_MUSIC_VOLUME_LINEAR := 0.5

@onready var game = $Game
@onready var theme_music = $ThemeMusic
@onready var main_menu = $UI/MainMenu
@onready var pause_menu = $UI/PauseMenu
@onready var death_overlay = $UI/DeathOverlay
@onready var respawn_button = $UI/DeathOverlay/MenuPanel/MenuItems/RespawnButton
@onready var hud = $UI/HUD
@onready var main_continue_button = $UI/MainMenu/MenuPanel/MenuItems/ContinueButton
@onready var music_volume_slider = $UI/MainMenu/MenuPanel/MenuItems/MusicVolumeSlider
@onready var music_pause_button = $UI/MainMenu/MenuPanel/MenuItems/MusicPauseButton
@onready var player_status_panel = $UI/PlayerStatusPanel
@onready var health_label = $UI/HUD/HealthLabel
@onready var xp_label = $UI/HUD/XPLabel
@onready var floor_label = $UI/HUD/FloorLabel
@onready var dev_mode_button = $UI/HUD/DevModeButton

var is_entry_pause_active := false
var is_status_panel_open := false
var is_death_overlay_open := false
var _boss_health_root: Control = null
var _boss_health_bar: ProgressBar = null
var _boss_name_label: Label = null
var _tracked_boss: Node = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	main_continue_button.disabled = not GameManager.has_save_game()
	$UI/MainMenu/MenuPanel/MenuItems/NewGameButton.pressed.connect(_on_new_game_pressed)
	$UI/MainMenu/MenuPanel/MenuItems/ContinueButton.pressed.connect(_on_continue_pressed)
	$UI/MainMenu/MenuPanel/MenuItems/QuitButton.pressed.connect(_on_quit_pressed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	music_pause_button.pressed.connect(_on_music_pause_button_pressed)
	music_volume_slider.value = INITIAL_MUSIC_VOLUME_LINEAR
	_set_music_volume_from_linear(INITIAL_MUSIC_VOLUME_LINEAR)
	music_pause_button.text = "Pausar Musica"
	$UI/PauseMenu/MenuPanel/MenuItems/ResumeButton.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/MenuPanel/MenuItems/NewGameButton.pressed.connect(_on_new_game_pressed)
	$UI/PauseMenu/MenuPanel/MenuItems/QuitButton.pressed.connect(_on_quit_pressed)
	respawn_button.pressed.connect(_on_respawn_pressed)
	dev_mode_button.toggled.connect(_on_dev_mode_toggled)
	dev_mode_button.button_pressed = GameManager.is_dev_mode
	_update_dev_button_text(GameManager.is_dev_mode)
	player_status_panel.close_requested.connect(_close_status_panel)
	_setup_boss_health_ui()
	xp_label.visible = false
	show_main_menu()

func _process(_delta):
	_ensure_player_death_signal()

	if Input.is_action_just_pressed("toggle_status_panel") and not main_menu.visible and game.visible and not is_entry_pause_active and not pause_menu.visible:
		if is_status_panel_open:
			_close_status_panel()
		else:
			_open_status_panel()

	if Input.is_action_just_pressed("ui_cancel") and not main_menu.visible and game.visible and not is_entry_pause_active and not is_status_panel_open and not is_death_overlay_open:
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

	if is_status_panel_open:
		player_status_panel.refresh(_get_player_node())

	health_label.text = "HP: %d/%d | Moedas: %d" % [PlayerStats.current_health, PlayerStats.max_health, PlayerStats.coins]
	floor_label.text = "Andar: %d" % [GameManager.current_floor]
	_update_boss_health_ui()

func show_main_menu():
	get_tree().paused = false
	game.visible = false
	hud.visible = false
	main_menu.visible = true
	pause_menu.visible = false
	death_overlay.visible = false
	is_death_overlay_open = false

func start_game():
	get_tree().paused = false
	game.visible = true
	hud.visible = true
	main_menu.visible = false
	pause_menu.visible = false
	death_overlay.visible = false
	is_death_overlay_open = false

func pause_game():
	if is_status_panel_open:
		_close_status_panel()
	get_tree().paused = true
	pause_menu.visible = true

func resume_game():
	get_tree().paused = false
	pause_menu.visible = false

func _open_status_panel() -> void:
	is_status_panel_open = true
	player_status_panel.visible = true
	player_status_panel.refresh(_get_player_node())
	get_tree().paused = true

func _close_status_panel() -> void:
	is_status_panel_open = false
	player_status_panel.visible = false
	if not pause_menu.visible and not main_menu.visible and game.visible and not is_entry_pause_active and not is_death_overlay_open:
		get_tree().paused = false

func _get_player_node() -> Node:
	return get_tree().get_first_node_in_group("player")

func _ensure_player_death_signal() -> void:
	var player := _get_player_node()
	if player == null:
		return
	if player.has_signal("death_sequence_finished"):
		var callback := Callable(self, "_on_player_death_sequence_finished")
		if not player.death_sequence_finished.is_connected(callback):
			player.death_sequence_finished.connect(callback)

func _on_player_death_sequence_finished() -> void:
	is_death_overlay_open = true
	if is_status_panel_open:
		_close_status_panel()
	pause_menu.visible = false
	death_overlay.visible = true
	get_tree().paused = true

func _on_respawn_pressed() -> void:
	var player := _get_player_node()
	if player == null or not player.has_method("respawn_to_hub"):
		return
	is_death_overlay_open = false
	death_overlay.visible = false
	get_tree().paused = false
	player.respawn_to_hub()

func _on_new_game_pressed():
	start_game()
	GameManager.start_new_game()
	main_continue_button.disabled = false
	await _apply_entry_pause()

func _on_continue_pressed():
	start_game()
	GameManager.continue_game()
	await _apply_entry_pause()

func _apply_entry_pause():
	is_entry_pause_active = true
	get_tree().paused = true
	await get_tree().create_timer(ENTRY_PAUSE_SECONDS, true).timeout
	get_tree().paused = false
	is_entry_pause_active = false

func _on_resume_pressed():
	resume_game()

func _on_quit_pressed():
	if game.visible and GameManager.current_level_instance:
		GameManager.save_game()

	get_tree().quit()

func _on_music_volume_changed(value: float) -> void:
	_set_music_volume_from_linear(value)

func _on_music_pause_button_pressed() -> void:
	theme_music.stream_paused = not theme_music.stream_paused
	music_pause_button.text = "Retomar Musica" if theme_music.stream_paused else "Pausar Musica"

func _set_music_volume_from_linear(value: float) -> void:
	var safe_value := clampf(value, 0.0, 1.0)
	if safe_value <= 0.0:
		theme_music.volume_db = -80.0
		return

	theme_music.volume_db = linear_to_db(safe_value)

func _on_dev_mode_toggled(enabled: bool) -> void:
	GameManager.set_dev_mode(enabled)
	_update_dev_button_text(enabled)

func _update_dev_button_text(enabled: bool) -> void:
	dev_mode_button.text = "Modo Dev: ON" if enabled else "Modo Dev: OFF"

func _setup_boss_health_ui() -> void:
	_boss_health_root = Control.new()
	_boss_health_root.name = "BossHealthUI"
	_boss_health_root.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_boss_health_root.anchor_left = 0.18
	_boss_health_root.anchor_right = 0.82
	_boss_health_root.offset_top = 14.0
	_boss_health_root.offset_bottom = 86.0
	_boss_health_root.visible = false
	hud.add_child(_boss_health_root)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0
	_boss_health_root.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	panel.add_child(content)

	_boss_health_bar = ProgressBar.new()
	_boss_health_bar.custom_minimum_size = Vector2(0, 28)
	_boss_health_bar.show_percentage = false
	_boss_health_bar.max_value = 100.0
	_boss_health_bar.value = 100.0
	var boss_bar_background := StyleBoxFlat.new()
	boss_bar_background.bg_color = Color(0.15, 0.04, 0.04, 0.95)
	_boss_health_bar.add_theme_stylebox_override("background", boss_bar_background)
	var boss_bar_fill := StyleBoxFlat.new()
	boss_bar_fill.bg_color = Color(0.87, 0.12, 0.12, 1.0)
	_boss_health_bar.add_theme_stylebox_override("fill", boss_bar_fill)
	content.add_child(_boss_health_bar)

	_boss_name_label = Label.new()
	_boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name_label.text = ""
	content.add_child(_boss_name_label)

func _update_boss_health_ui() -> void:
	if _boss_health_root == null or _boss_health_bar == null or _boss_name_label == null:
		return

	if GameManager.current_floor != 10 or not game.visible:
		_boss_health_root.visible = false
		_tracked_boss = null
		return

	if _tracked_boss == null or not is_instance_valid(_tracked_boss):
		_tracked_boss = _find_floor_10_boss()

	if _tracked_boss == null or not is_instance_valid(_tracked_boss):
		_boss_health_root.visible = false
		return

	var max_hp: int = int(_tracked_boss.get("max_health"))
	var current_hp: int = int(_tracked_boss.get("current_health"))
	if max_hp <= 0 or current_hp <= 0:
		_boss_health_root.visible = false
		return

	_boss_health_bar.max_value = max_hp
	_boss_health_bar.value = clampi(current_hp, 0, max_hp)
	if _tracked_boss.has_method("get_boss_display_name"):
		_boss_name_label.text = _tracked_boss.get_boss_display_name()
	else:
		_boss_name_label.text = "Boss do Andar 10"

	_boss_health_root.visible = true

func _find_floor_10_boss() -> Node:
	for enemy in get_tree().get_nodes_in_group("boss_enemy"):
		if enemy == null or not is_instance_valid(enemy):
			continue
		if "state" in enemy and int(enemy.get("state")) == 4:
			continue
		return enemy
	return null
