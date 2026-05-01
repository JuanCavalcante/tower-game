extends Node2D
class_name BaseFloor

var enemies: Array = []
var floor_number: int = 0
var _waves_active: bool = false
var _waves: Array = []
var _current_wave: int = 0
var _enemies_alive_in_wave: int = 0
var _wave_spawn_points: Array[Vector2] = []
var _wave_enemy_scene: PackedScene = null

func _ready() -> void:
	floor_number = _resolve_floor_number()
	enemies = _get_floor_enemies()
	_apply_floor_balance()
	_enforce_floor_10_boss_only()
	_try_start_waves()

func enemy_killed(enemy: Node) -> void:
	if enemies.has(enemy):
		enemies.erase(enemy)
	if _waves_active:
		_enemies_alive_in_wave = max(_enemies_alive_in_wave - 1, 0)
		if _enemies_alive_in_wave <= 0:
			start_next_wave()
		return
	if enemies.is_empty():
		on_floor_cleared()

func on_floor_cleared() -> void:
	var portal = get_node_or_null("ExitPortal")
	if portal:
		portal.activate()

func _get_floor_enemies() -> Array:
	var floor_enemies: Array = []
	_collect_enemies(self, floor_enemies)
	return floor_enemies

func _resolve_floor_number() -> int:
	var scene_path: String = scene_file_path
	var file_name: String = scene_path.get_file().get_basename()
	if file_name.begins_with("floor_"):
		return int(file_name.trim_prefix("floor_"))
	return 0

func _apply_floor_balance() -> void:
	var data: Dictionary = FloorBalance.get_floor_data(floor_number)
	if data.is_empty():
		return

	for enemy in enemies:
		_apply_enemy_balance(enemy, data)

func _apply_enemy_balance(enemy: Node, data: Dictionary) -> void:
	var role: String = _resolve_enemy_role(enemy)
	var stats: Dictionary = data.get(role, {})
	if stats.is_empty():
		return

	_apply_stat(enemy, "max_health", int(stats.get("hp", 0)))
	_apply_stat(enemy, "damage", int(stats.get("damage", 0)))
	_apply_stat(enemy, "xp_reward", int(stats.get("xp", 0)))
	_apply_stat(enemy, "speed", float(stats.get("speed", 0.0)))
	_apply_stat(enemy, "attack_cooldown", float(stats.get("attack_cooldown", 0.0)))
	_apply_stat(enemy, "damage_reduction_ratio", float(stats.get("damage_reduction_ratio", 0.0)))
	_apply_stat(enemy, "damage_reduction_flat", int(stats.get("damage_reduction_flat", 0)))
	if "current_health" in enemy and int(stats.get("hp", 0)) > 0:
		enemy.current_health = int(stats["hp"])

func _apply_stat(enemy: Node, field_name: String, value: Variant) -> void:
	if field_name in enemy:
		enemy.set(field_name, value)

func _resolve_enemy_role(enemy: Node) -> String:
	var script_ref: Script = enemy.get_script() as Script
	var script_path: String = ""
	if script_ref:
		script_path = script_ref.resource_path.to_lower()
	if script_path.contains("mini_boss"):
		return "miniboss"
	if script_path.contains("boss"):
		return "boss_unico"
	return "minion"

func _enforce_floor_10_boss_only() -> void:
	if floor_number != 10:
		return

	for enemy in enemies.duplicate():
		if _resolve_enemy_role(enemy) != "boss_unico":
			enemy.queue_free()
			enemies.erase(enemy)

func _collect_enemies(node: Node, floor_enemies: Array) -> void:
	if node.is_in_group("enemies"):
		floor_enemies.append(node)

	for child in node.get_children():
		_collect_enemies(child, floor_enemies)

func _try_start_waves() -> void:
	var data: Dictionary = FloorBalance.get_floor_data(floor_number)
	var configured_waves: Array = data.get("waves", [])
	if configured_waves.is_empty():
		return

	_collect_wave_spawn_points()
	if _wave_spawn_points.is_empty():
		push_warning("Floor%02d: waves configuradas sem pontos de spawn." % floor_number)
		return

	_wave_enemy_scene = _resolve_wave_enemy_scene()
	if _wave_enemy_scene == null:
		push_warning("Floor%02d: waves configuradas sem enemy_scene valido." % floor_number)
		return

	_waves = configured_waves.duplicate(true)
	_waves_active = true
	_current_wave = 0
	_enemies_alive_in_wave = 0
	_remove_baked_enemies()
	call_deferred("start_next_wave")

func start_next_wave() -> void:
	if not _waves_active:
		return
	if _current_wave >= _waves.size():
		_waves_active = false
		on_floor_cleared()
		return

	var wave_data: Dictionary = _waves[_current_wave]
	_current_wave += 1
	var rest: float = float(wave_data.get("rest", 1.0))
	await get_tree().create_timer(rest, false).timeout
	spawn_wave(wave_data)

func spawn_wave(wave_data: Dictionary) -> void:
	var count: int = int(wave_data.get("count", 0))
	var delay: float = float(wave_data.get("delay", 0.8))
	for i in range(count):
		var spawn_point: Vector2 = _wave_spawn_points[randi() % _wave_spawn_points.size()]
		spawn_enemy_at(spawn_point)
		await get_tree().create_timer(delay, false).timeout

func spawn_enemy_at(spawn_position: Vector2) -> void:
	if _wave_enemy_scene == null:
		return
	var enemy: Node2D = _wave_enemy_scene.instantiate() as Node2D
	if enemy == null:
		return

	var jitter_x: float = randf_range(-22.0, 22.0)
	enemy.global_position = spawn_position + Vector2(jitter_x, 0)
	_ensure_enemies_container().add_child(enemy)
	enemies.append(enemy)
	_apply_enemy_balance(enemy, FloorBalance.get_floor_data(floor_number))
	_enemies_alive_in_wave += 1

func _collect_wave_spawn_points() -> void:
	_wave_spawn_points.clear()
	var spawn_points_root: Node = get_node_or_null("SpawnPoints")
	if spawn_points_root != null:
		for child in spawn_points_root.get_children():
			var point_node := child as Node2D
			if point_node != null:
				_wave_spawn_points.append(point_node.global_position)
		if not _wave_spawn_points.is_empty():
			return

	for enemy in enemies:
		var enemy_node := enemy as Node2D
		if enemy_node != null:
			_wave_spawn_points.append(enemy_node.global_position)

func _resolve_wave_enemy_scene() -> PackedScene:
	var enemies_root: Node = get_node_or_null("Enemies")
	if enemies_root != null:
		for child in enemies_root.get_children():
			var child_node := child as Node
			if child_node == null:
				continue
			var scene_path: String = child_node.scene_file_path
			if scene_path.is_empty():
				continue
			var packed: PackedScene = load(scene_path) as PackedScene
			if packed != null:
				return packed
	var fallback_scene_path: String = "res://scenes/enemies/slime.tscn" if floor_number <= 5 else "res://scenes/enemies/skeleton.tscn"
	var fallback_scene: PackedScene = load(fallback_scene_path) as PackedScene
	if fallback_scene != null:
		return fallback_scene
	return null

func _remove_baked_enemies() -> void:
	var enemies_root: Node = get_node_or_null("Enemies")
	if enemies_root == null:
		return
	for child in enemies_root.get_children():
		child.queue_free()
	enemies.clear()

func _ensure_enemies_container() -> Node2D:
	var container: Node2D = get_node_or_null("Enemies") as Node2D
	if container != null:
		return container
	container = Node2D.new()
	container.name = "Enemies"
	add_child(container)
	return container
