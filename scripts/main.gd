extends Node

func _ready():
	GameManager.load_floor(1)
	
func _process(delta):
	$UI/HealthLabel.text = "HP: " + str(PlayerStats.current_health) + "/" + str(PlayerStats.max_health)
	$UI/XPLabel.text = "XP: " + str(PlayerStats.xp) + "/" + str(PlayerStats.xp_to_next_level) + "  Nível: " + str(PlayerStats.level)
	$UI/FloorLabel.text = "Andar: " + str(GameManager.current_floor)
