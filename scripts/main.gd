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
@onready var health_bar_fill: ColorRect = $UI/HUD/HealthBar/Fill
@onready var health_bar_text: Label = $UI/HUD/HealthBar/HealthText
@onready var coins_label: Label = $UI/HUD/CoinsLabel
@onready var xp_label = $UI/HUD/XPLabel
@onready var floor_label = $UI/HUD/FloorLabel
@onready var dev_mode_button = $UI/HUD/DevModeButton

var is_entry_pause_active := false
var is_status_panel_open := false
var is_death_overlay_open := false

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

	_update_health_bar()
	coins_label.text = "Moedas: %d" % [PlayerStats.coins]
	floor_label.text = "Andar: %d" % [GameManager.current_floor]

func _update_health_bar() -> void:
	var max_health: int = max(PlayerStats.max_health, 1)
	var current_health: int = clampi(PlayerStats.current_health, 0, max_health)
	var health_ratio: float = float(current_health) / float(max_health)

	PlayerStats.current_health = current_health
	health_bar_fill.anchor_right = health_ratio
	health_bar_text.text = "%d/%d" % [current_health, max_health]

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
