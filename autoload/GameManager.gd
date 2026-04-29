extends Node

const SAVE_PATH := "user://savegame.json"
const PLAYER_START_POSITION := Vector2(69, 73)
const HUB_FLOOR := 0
const FIRST_FLOOR := 1
const MAX_PORTAL_FLOOR := 10
const HUB_RETURN_SPAWN_OFFSET := Vector2(120, 18)
const FLOOR_PORTAL_SPAWN_OFFSET := Vector2(64, 18)

var current_floor = 0
var current_level_instance = null
var unlocked_floors: Array[int] = [FIRST_FLOOR]
var is_dev_mode := false
var _is_loading_floor := false

var floors = {
	0: "res://scenes/world/floor_00_city.tscn",
	1: "res://scenes/world/floor_01.tscn",
	2: "res://scenes/world/floor_02.tscn",
	3: "res://scenes/world/floor_03.tscn",
	4: "res://scenes/world/floor_04.tscn",
	5: "res://scenes/world/floor_05.tscn",
	6: "res://scenes/world/floor_06.tscn",
	7: "res://scenes/world/floor_07.tscn",
	8: "res://scenes/world/floor_08.tscn",
	9: "res://scenes/world/floor_09.tscn",
	10: "res://scenes/world/floor_10.tscn"
}

enum SpawnContext {
	DEFAULT,
	NEW_GAME,
	CONTINUE_GAME,
	ENTER_TOWER,
	ADVANCE_FLOOR,
	RETURN_TO_HUB
}

func start_new_game() -> void:
	PlayerStats.reset()
	unlocked_floors = [FIRST_FLOOR]
	load_floor(HUB_FLOOR, true, SpawnContext.NEW_GAME)

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

func has_floor(floor_number: int) -> bool:
	return floors.has(floor_number)

func has_save_game() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
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

func continue_game() -> void:
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
	load_floor(HUB_FLOOR, false, SpawnContext.CONTINUE_GAME)

func return_to_hub(save_progress := true) -> void:
	load_floor(HUB_FLOOR, save_progress, SpawnContext.RETURN_TO_HUB)

func load_floor(floor_number: int, save_progress := true, spawn_context: int = SpawnContext.DEFAULT) -> void:
	if _is_loading_floor:
		return

	var game_node = get_tree().get_root().get_node_or_null("Main/Game")
	if game_node == null:
		push_warning("Main/Game nao encontrado; floor nao carregado.")
		return

	_is_loading_floor = true
	_clear_loaded_levels(game_node)

	var scene_path = floors.get(floor_number)
	if not scene_path:
		print("Todos os andares concluidos! Parabens!")
		_is_loading_floor = false
		return

	var scene = load(scene_path)
	if not scene:
		print("Failed to load scene at: ", scene_path)
		_is_loading_floor = false
		return

	current_floor = floor_number
	current_level_instance = scene.instantiate()
	game_node.add_child(current_level_instance)
	_reset_player_position(game_node, spawn_context)
	if _should_refill_health_on_floor_load(floor_number, spawn_context):
		PlayerStats.refill_health()

	if save_progress:
		save_game()

	print("Loaded floor: ", floor_number)
	_is_loading_floor = false

func _clear_loaded_levels(game_node: Node) -> void:
	for child in game_node.get_children():
		if child.is_in_group("player"):
			continue
		game_node.remove_child(child)
		child.queue_free()

	current_level_instance = null

func _reset_player_position(game_node: Node, spawn_context: int) -> void:
	var player = game_node.get_node_or_null("Player")
	if not player:
		return

	player.global_position = _resolve_spawn_position(spawn_context)
	player.velocity = Vector2.ZERO

func _should_refill_health_on_floor_load(floor_number: int, spawn_context: int) -> bool:
	return spawn_context in [
		SpawnContext.ADVANCE_FLOOR,
		SpawnContext.RETURN_TO_HUB
	]

func _resolve_spawn_position(spawn_context: int) -> Vector2:
	if current_floor == HUB_FLOOR:
		return _resolve_hub_spawn_position(spawn_context)

	return _resolve_floor_portal_spawn_position()

func _resolve_hub_spawn_position(spawn_context: int) -> Vector2:
	var should_use_portal_spawn := spawn_context in [
		SpawnContext.NEW_GAME,
		SpawnContext.CONTINUE_GAME,
		SpawnContext.RETURN_TO_HUB
	]
	if not should_use_portal_spawn:
		return PLAYER_START_POSITION

	if current_level_instance == null:
		return PLAYER_START_POSITION

	var anchor := current_level_instance.get_node_or_null("PortalAnchor") as Node2D
	if anchor == null:
		anchor = _find_node2d_by_paths(current_level_instance, [
			"CidadeHub/Portal",
			"CidadeHub/Cidade_Hub/Portal"
		])

	if anchor == null:
		return PLAYER_START_POSITION

	return anchor.global_position + HUB_RETURN_SPAWN_OFFSET

func _resolve_floor_portal_spawn_position() -> Vector2:
	if current_level_instance == null:
		return PLAYER_START_POSITION

	var anchor := current_level_instance.get_node_or_null("ExitPortal") as Node2D
	if anchor == null:
		anchor = _find_node2d_by_paths(current_level_instance, [
			"Arena/ExitPortal",
			"World/ExitPortal"
		])

	if anchor == null:
		return PLAYER_START_POSITION

	return anchor.global_position + FLOOR_PORTAL_SPAWN_OFFSET

func _find_node2d_by_paths(root: Node, paths: Array[String]) -> Node2D:
	for path in paths:
		var found := root.get_node_or_null(path) as Node2D
		if found != null:
			return found

	return null
