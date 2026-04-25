extends Node2D
class_name BaseFloor

var enemies: Array = []

func _ready() -> void:
	enemies = _get_floor_enemies()

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

func _collect_enemies(node: Node, floor_enemies: Array) -> void:
	if node.is_in_group("enemies"):
		floor_enemies.append(node)

	for child in node.get_children():
		_collect_enemies(child, floor_enemies)
