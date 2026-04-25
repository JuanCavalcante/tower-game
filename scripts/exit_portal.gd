extends Area2D

var active = false

func activate():
	active = true
	print("Portal ativado!")

func _on_body_entered(body):
	if not active:
		return

	if body.name == "Player":
		GameManager.load_floor(GameManager.current_floor + 1)
