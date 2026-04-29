extends BaseFloor

@export var enemy_scene: PackedScene

var enemies_alive: int = 0

var waves := [
	{ "count": 3, "delay": 0.8 },
	{ "count": 5, "delay": 0.6 },
	{ "count": 7, "delay": 0.5 }
]

var current_wave: int = 0

@onready var spawn_points_node: Node = $SpawnPoints


func _ready() -> void:
	super._ready()
	randomize()
	_remove_baked_enemies()
	_apply_floor_01_waves_balance()
	enemies_alive = 0
	current_wave = 0
	start_next_wave()


func enemy_killed(_enemy: Node) -> void:
	enemies_alive = max(enemies_alive - 1, 0)

	if enemies_alive <= 0:
		start_next_wave()


func start_next_wave() -> void:
	if current_wave >= waves.size():
		on_floor_cleared()
		return

	var wave_data: Dictionary = waves[current_wave]

	print("Wave ", current_wave + 1, " começou!")

	current_wave += 1

	var rest: float = float(wave_data.get("rest", 1.0))
	await get_tree().create_timer(rest, false).timeout

	spawn_wave(wave_data)


func spawn_wave(wave_data: Dictionary) -> void:
	var spawn_points: Array[Node] = spawn_points_node.get_children()
	if spawn_points.is_empty():
		push_warning("Floor01: nenhum SpawnPoint encontrado.")
		return

	var count: int = int(wave_data.get("count", 0))
	var delay: float = float(wave_data.get("delay", 0.8))

	for i in range(count):
		var point: Node2D = spawn_points[randi() % spawn_points.size()] as Node2D
		if point:
			spawn_enemy_at(point)
		await get_tree().create_timer(delay, false).timeout


func spawn_enemy_at(point: Node2D) -> void:
	if enemy_scene == null:
		push_warning("Floor01: enemy_scene não configurada.")
		return

	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	if enemy == null:
		return

	var jitter_x: float = randf_range(-22.0, 22.0)
	enemy.global_position = point.global_position + Vector2(jitter_x, 0)
	_ensure_enemies_container().add_child(enemy)
	_apply_runtime_enemy_balance(enemy)
	enemies_alive += 1


func on_floor_cleared() -> void:
	var portal = get_node_or_null("ExitPortal")
	if portal:
		portal.activate()


func _remove_baked_enemies() -> void:
	for old_container_name in ["Enimies", "Enemies"]:
		var old_container: Node = get_node_or_null(old_container_name)
		if old_container == null:
			continue
		for child in old_container.get_children():
			child.queue_free()


func _ensure_enemies_container() -> Node2D:
	var container: Node2D = get_node_or_null("Enemies") as Node2D
	if container != null:
		return container

	container = Node2D.new()
	container.name = "Enemies"
	add_child(container)
	return container

func _apply_floor_01_waves_balance() -> void:
	var data: Dictionary = FloorBalance.get_floor_data(1)
	var balanced_waves: Array = data.get("waves", [])
	if not balanced_waves.is_empty():
		waves = balanced_waves.duplicate(true)

func _apply_runtime_enemy_balance(enemy: Node) -> void:
	var data: Dictionary = FloorBalance.get_floor_data(1)
	var minion_stats: Dictionary = data.get("minion", {})
	if minion_stats.is_empty():
		return

	if "max_health" in enemy:
		enemy.max_health = int(minion_stats.get("hp", enemy.max_health))
	if "current_health" in enemy:
		enemy.current_health = int(minion_stats.get("hp", enemy.current_health))
	if "damage" in enemy:
		enemy.damage = int(minion_stats.get("damage", enemy.damage))
	if "xp_reward" in enemy:
		enemy.xp_reward = int(minion_stats.get("xp", enemy.xp_reward))
	if "speed" in enemy:
		enemy.speed = float(minion_stats.get("speed", enemy.speed))
	if "attack_cooldown" in enemy:
		enemy.attack_cooldown = float(minion_stats.get("attack_cooldown", enemy.attack_cooldown))
