extends Node

@onready var game = $Game
@onready var main_menu = $UI/MainMenu
@onready var pause_menu = $UI/PauseMenu
@onready var hud = $UI/HUD
@onready var main_continue_button = $UI/MainMenu/MenuPanel/MenuItems/ContinueButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_continue_button.disabled = not GameManager.has_save_game()
	$UI/MainMenu/MenuPanel/MenuItems/NewGameButton.pressed.connect(_on_new_game_pressed)
	$UI/MainMenu/MenuPanel/MenuItems/ContinueButton.pressed.connect(_on_continue_pressed)
	$UI/MainMenu/MenuPanel/MenuItems/QuitButton.pressed.connect(_on_quit_pressed)
	$UI/PauseMenu/MenuPanel/MenuItems/ResumeButton.pressed.connect(_on_resume_pressed)
	$UI/PauseMenu/MenuPanel/MenuItems/NewGameButton.pressed.connect(_on_new_game_pressed)
	$UI/PauseMenu/MenuPanel/MenuItems/QuitButton.pressed.connect(_on_quit_pressed)
	show_main_menu()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not main_menu.visible and game.visible:
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

	$UI/HUD/HealthLabel.text = "HP: " + str(PlayerStats.current_health) + "/" + str(PlayerStats.max_health)
	$UI/HUD/XPLabel.text = "XP: " + str(PlayerStats.xp) + "/" + str(PlayerStats.xp_to_next_level) + "  Nivel: " + str(PlayerStats.level)
	$UI/HUD/FloorLabel.text = "Andar: " + str(GameManager.current_floor)

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

func _on_continue_pressed():
	start_game()
	GameManager.continue_game()

func _on_resume_pressed():
	resume_game()

func _on_quit_pressed():
	if game.visible and GameManager.current_level_instance:
		GameManager.save_game()

	get_tree().quit()
