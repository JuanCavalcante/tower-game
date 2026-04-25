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
		GameManager.load_floor(GameManager.current_floor + 1)
