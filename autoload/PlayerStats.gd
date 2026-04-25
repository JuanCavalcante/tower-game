extends Node

var level := 1
var xp := 0
var xp_to_next_level := 50

var max_health := 100
var current_health := 100

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
