extends Node

const SAVE_PATH := "user://savegame.json"
const PLAYER_START_POSITION := Vector2(69, 73)
const HUB_FLOOR := 0
const FIRST_FLOOR := 1
const MAX_PORTAL_FLOOR := 10

var current_floor = 0
var current_level_instance = null
var unlocked_floors: Array[int] = [FIRST_FLOOR]
var is_dev_mode := false

var floors = {
	0: "res://scenes/world/floor_00_city.tscn",
	1: "res://scenes/world/floor_01.tscn",
	2: "res://scenes/world/floor_02.tscn",
	3: "res://scenes/world/floor_03.tscn",
	4: "res://scenes/world/floor_04.tscn"
}

func start_new_game():
	PlayerStats.reset()
	unlocked_floors = [FIRST_FLOOR]
	load_floor(HUB_FLOOR)

func set_dev_mode(enabled: bool) -> void:
	is_dev_mode = enabled

func is_floor_unlocked(floor_number: int) -> bool:
	return floor_number in unlocked_floors

func unlock_floor(floor_number: int) -> void:
	if floor_number < FIRST_FLOOR or floor_number > MAX_PORTAL_FLOOR:
		return

	if floor_number not in unlocked_floors:
		unlocked_floors.append(floor_number)
		unlocked_floors.sort()
		save_game()

func has_save_game():
	return FileAccess.file_exists(SAVE_PATH)

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if not file:
		print("Nao foi possivel salvar o jogo.")
		return

	var data = {
		"current_floor": current_floor,
		"unlocked_floors": unlocked_floors,
		"player_stats": PlayerStats.to_save_data()
	}

	file.store_string(JSON.stringify(data))

func continue_game():
	if not has_save_game():
		start_new_game()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if not file:
		start_new_game()
		return

	var parsed = JSON.parse_string(file.get_as_text())

	if typeof(parsed) != TYPE_DICTIONARY:
		start_new_game()
		return

	PlayerStats.load_save_data(parsed.get("player_stats", {}))
	var saved_floors = parsed.get("unlocked_floors", [FIRST_FLOOR])
	unlocked_floors = []
	for f in saved_floors:
		var floor_number := int(f)
		if floor_number >= FIRST_FLOOR and floor_number <= MAX_PORTAL_FLOOR and floor_number not in unlocked_floors:
			unlocked_floors.append(floor_number)

	if FIRST_FLOOR not in unlocked_floors:
		unlocked_floors.append(FIRST_FLOOR)

	unlocked_floors.sort()

	# Continue sempre retorna ao hub e preserva progresso salvo.
	load_floor(HUB_FLOOR, false)

func load_floor(floor_number, save_progress := true):
	if current_level_instance:
		current_level_instance.queue_free()

	var scene_path = floors.get(floor_number)

	if not scene_path:
		print("Todos os andares concluídos! Parabéns!")
		return

	var scene = load(scene_path)

	if not scene:
		print("Failed to load scene at: ", scene_path)
		return

	current_floor = floor_number
	current_level_instance = scene.instantiate()

	var game_node = get_tree().get_root().get_node("Main/Game")
	game_node.add_child(current_level_instance)
	_reset_player_position(game_node)

	if save_progress:
		save_game()

	print("Loaded floor: ", floor_number)

func _reset_player_position(game_node):
	var player = game_node.get_node_or_null("Player")

	if not player:
		return

	player.global_position = PLAYER_START_POSITION
	player.velocity = Vector2.ZERO
