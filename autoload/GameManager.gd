extends Node

const SAVE_PATH := "user://savegame.json"
const PLAYER_START_POSITION := Vector2(69, 73)
const STARTING_FLOOR := 1

var current_floor = 1
var current_level_instance = null
var unlocked_floors := [STARTING_FLOOR]

var floors = {
	1: "res://scenes/world/floor_01.tscn",
	2: "res://scenes/world/floor_02.tscn",
	3: "res://scenes/world/floor_03.tscn"
}

func start_new_game():
	PlayerStats.reset()
	current_floor = STARTING_FLOOR
	unlocked_floors = [STARTING_FLOOR]
	load_floor(STARTING_FLOOR)

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
	_load_unlocked_floors(parsed.get("unlocked_floors", [STARTING_FLOOR]))

	var saved_floor = int(parsed.get("current_floor", STARTING_FLOOR))
	if not is_floor_unlocked(saved_floor):
		saved_floor = STARTING_FLOOR

	load_floor(saved_floor, false)

func load_floor(floor_number, save_progress := true):
	var scene_path = floors.get(floor_number)

	if not scene_path:
		print("Todos os andares concluídos! Parabéns!")
		return

	if not is_floor_unlocked(floor_number):
		print("Andar bloqueado: ", floor_number)
		return

	if current_level_instance:
		current_level_instance.queue_free()

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

func is_floor_unlocked(floor_number: int) -> bool:
	return unlocked_floors.has(floor_number)

func unlock_floor(floor_number: int) -> void:
	if not floors.has(floor_number):
		return

	if unlocked_floors.has(floor_number):
		return

	unlocked_floors.append(floor_number)
	unlocked_floors.sort()
	save_game()

func get_unlocked_floors() -> Array:
	return unlocked_floors.duplicate()

func _load_unlocked_floors(saved_unlocked_floors) -> void:
	unlocked_floors = []

	if typeof(saved_unlocked_floors) == TYPE_ARRAY:
		for floor_number in saved_unlocked_floors:
			var parsed_floor = int(floor_number)
			if floors.has(parsed_floor) and not unlocked_floors.has(parsed_floor):
				unlocked_floors.append(parsed_floor)

	if not unlocked_floors.has(STARTING_FLOOR):
		unlocked_floors.append(STARTING_FLOOR)

	unlocked_floors.sort()

func _reset_player_position(game_node):
	var player = game_node.get_node_or_null("Player")

	if not player:
		return

	player.global_position = PLAYER_START_POSITION
	player.velocity = Vector2.ZERO
