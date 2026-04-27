extends Node

const ENTRY_PAUSE_SECONDS := 1.2
const INITIAL_MUSIC_VOLUME_LINEAR := 0.5

@onready var game = $Game
@onready var theme_music = $ThemeMusic
@onready var main_menu = $UI/MainMenu
@onready var pause_menu = $UI/PauseMenu
@onready var hud = $UI/HUD
@onready var main_continue_button = $UI/MainMenu/MenuPanel/MenuItems/ContinueButton
@onready var music_volume_slider = $UI/MainMenu/MenuPanel/MenuItems/MusicVolumeSlider
@onready var music_pause_button = $UI/MainMenu/MenuPanel/MenuItems/MusicPauseButton
@onready var health_label = $UI/HUD/HealthLabel
@onready var xp_label = $UI/HUD/XPLabel
@onready var floor_label = $UI/HUD/FloorLabel
@onready var dev_mode_button = $UI/HUD/DevModeButton

var is_entry_pause_active := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	dev_mode_button.toggled.connect(_on_dev_mode_toggled)
	dev_mode_button.button_pressed = GameManager.is_dev_mode
	_update_dev_button_text(GameManager.is_dev_mode)
	show_main_menu()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not main_menu.visible and game.visible and not is_entry_pause_active:
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

	health_label.text = "HP: %d/%d | Moedas: %d" % [PlayerStats.current_health, PlayerStats.max_health, PlayerStats.coins]
	xp_label.text = "XP: %d/%d  Nivel: %d | Pocoes: %d (Q)" % [PlayerStats.xp, int(PlayerStats.xp_to_next_level), PlayerStats.level, PlayerStats.potions]
	floor_label.text = "Andar: %d | Equip: %s (+%d)" % [GameManager.current_floor, PlayerStats.equipped_weapon_name, PlayerStats.weapon_damage_bonus]

func show_main_menu():
	get_tree().paused = false
	game.visible = false
	hud.visible = false
	main_menu.visible = true
	pause_menu.visible = false

func start_game():
	get_tree().paused = false
	game.visible = true
	hud.visible = true
	main_menu.visible = false
	pause_menu.visible = false

func pause_game():
	get_tree().paused = true
	pause_menu.visible = true

func resume_game():
	get_tree().paused = false
	pause_menu.visible = false

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
