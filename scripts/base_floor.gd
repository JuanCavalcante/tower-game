extends Node2D
class_name BaseFloor

var enemies: Array = []
var floor_number: int = 0

func _ready() -> void:
	floor_number = _resolve_floor_number()
	enemies = _get_floor_enemies()
	_apply_floor_balance()
	_enforce_floor_10_boss_only()

func enemy_killed(enemy: Node) -> void:
	if enemies.has(enemy):
		enemies.erase(enemy)
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
		return "boss"
	return "minion"

func _enforce_floor_10_boss_only() -> void:
	if floor_number != 10:
		return

	for enemy in enemies.duplicate():
		if _resolve_enemy_role(enemy) != "boss":
			enemy.queue_free()
			enemies.erase(enemy)

func _collect_enemies(node: Node, floor_enemies: Array) -> void:
	if node.is_in_group("enemies"):
		floor_enemies.append(node)

	for child in node.get_children():
		_collect_enemies(child, floor_enemies)
