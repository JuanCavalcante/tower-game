extends Area2D

var active = false

func activate():
	active = true
	print("Portal ativado! Avance para o próximo andar.")
	$AnimatedSprite2D.modulate = Color(0.5, 1.0, 0.5)

func _on_body_entered(body):
	if not active:
		return

	if body.is_in_group("player"):
		var next_floor: int = int(GameManager.current_floor) + 1
		if GameManager.has_floor(next_floor):
			GameManager.unlock_floor(next_floor)
			GameManager.load_floor(next_floor, true, GameManager.SpawnContext.ADVANCE_FLOOR)
		else:
			GameManager.return_to_hub(true)
