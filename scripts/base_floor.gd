extends Node2D
class_name BaseFloor

var enemies: Array = []

func _ready():
	enemies = get_tree().get_nodes_in_group("enemies")

func enemy_killed(enemy):
	enemies.erase(enemy)
	if enemies.size() == 0:
		on_floor_cleared()

func on_floor_cleared():
	var portal = get_node_or_null("ExitPortal")
	if portal:
		portal.activate()
