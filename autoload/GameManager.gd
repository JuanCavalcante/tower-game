extends Node

var current_floor = 1
var current_level_instance = null

var floors = {
	1: "res://scenes/world/floor_01.tscn"
}

func load_floor(floor_number):
	if current_level_instance:
		current_level_instance.queue_free()

	var scene_path = floors.get(floor_number)

	if not scene_path:
		print("Floor not found: ", floor_number)
		return

	var scene = load(scene_path)

	if not scene:
		print("Failed to load scene at: ", scene_path)
		return

	current_level_instance = scene.instantiate()

	var game_node = get_tree().get_root().get_node("Main/Game")
	game_node.add_child(current_level_instance)

	print("Loaded floor: ", floor_number)
