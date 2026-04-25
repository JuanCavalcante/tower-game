extends Node

func _ready():
	GameManager.load_floor(1)
	
func _process(delta):
	$UI/HealthLabel.text = "HP: " + str(PlayerStats.current_health) + "/" + str(PlayerStats.max_health)
