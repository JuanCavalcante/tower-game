extends Node2D

var enemies = []

func _ready():
	enemies = get_tree().get_nodes_in_group("enemies")

func enemy_killed(enemy):
	enemies.erase(enemy)

	if enemies.size() == 0:
		on_floor_cleared()

func on_floor_cleared():
	print("Floor 3 Cleared! Mini Boss derrotado!")

	var portal = get_node("ExitPortal")
	if portal:
		portal.activate()
