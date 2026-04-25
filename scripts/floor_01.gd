extends Node2D

var enemies = []

func _ready():
	enemies = _get_floor_enemies()

func enemy_killed(enemy):
	enemies.erase(enemy)

	if enemies.size() == 0:
		on_floor_cleared()

func on_floor_cleared():
	print("Floor Cleared!")

	var portal = get_node("ExitPortal")
	if portal:
		portal.activate()

func _get_floor_enemies():
	var floor_enemies = []
	_collect_enemies(self, floor_enemies)
	return floor_enemies

func _collect_enemies(node, floor_enemies):
	if node.is_in_group("enemies"):
		floor_enemies.append(node)

	for child in node.get_children():
		_collect_enemies(child, floor_enemies)
