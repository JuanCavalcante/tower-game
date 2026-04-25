extends Node2D

@export var enemy_scene: PackedScene

var enemies_alive := 0

var waves = [
	{ "count": 3, "delay": 0.8 },
	{ "count": 5, "delay": 0.6 },
	{ "count": 7, "delay": 0.5 }
]

var current_wave := 0

func _ready():
	enemies_alive = _get_floor_enemies().size()

	if enemies_alive == 0:
		start_next_wave()

func enemy_killed(enemy):
	enemies_alive -= 1

	if enemies_alive <= 0:
		start_next_wave()

func start_next_wave():
	if current_wave >= waves.size():
		on_floor_cleared()
		return

	var wave_data = waves[current_wave]

	print("Wave ", current_wave + 1, " começou!")

	current_wave += 1

	await get_tree().create_timer(1.0).timeout

	spawn_wave(wave_data)

func spawn_wave(wave_data):
	var spawn_points = $SpawnPoints.get_children()

	for point in spawn_points:
		spawn_from_point(point, wave_data)

func spawn_from_point(point, wave_data):
	for i in range(wave_data["count"]):
		spawn_enemy_at(point)
		await get_tree().create_timer(wave_data["delay"]).timeout

func spawn_enemy_at(point):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = point.global_position

	add_child(enemy)
	enemies_alive += 1

func on_floor_cleared():
	var portal = get_node_or_null("ExitPortal")
	if portal:
		portal.activate()

func _get_floor_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")
