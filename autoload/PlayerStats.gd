extends Node

var level := 1
var xp := 0
var xp_to_next_level := 50

var max_health := 100
var current_health := 100

func reset():
	level = 1
	xp = 0
	xp_to_next_level = 50
	max_health = 100
	current_health = max_health

func to_save_data():
	return {
		"level": level,
		"xp": xp,
		"xp_to_next_level": xp_to_next_level,
		"max_health": max_health,
		"current_health": current_health
	}

func load_save_data(data):
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	xp_to_next_level = int(data.get("xp_to_next_level", 50))
	max_health = int(data.get("max_health", 100))
	current_health = int(data.get("current_health", max_health))

func add_xp(amount):
	xp += amount
	print("XP: ", xp, "/", xp_to_next_level)

	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp = xp - xp_to_next_level
	xp_to_next_level *= 1.5

	max_health += 20
	current_health = max_health

	print("LEVEL UP! Agora nível ", level)
