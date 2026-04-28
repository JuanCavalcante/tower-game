extends BaseFloor

func _ready() -> void:
	super._ready()
	_ensure_floor4_enemies_active()

func _ensure_floor4_enemies_active() -> void:
	var enemies_root: Node = get_node_or_null("Enemies")
	if enemies_root == null:
		return

	for enemy_node in enemies_root.get_children():
		if enemy_node == null:
			continue

		enemy_node.process_mode = Node.PROCESS_MODE_INHERIT
		enemy_node.set_process(true)
		enemy_node.set_physics_process(true)

		if enemy_node.has_method("_refresh_player_reference"):
			enemy_node.call("_refresh_player_reference")
