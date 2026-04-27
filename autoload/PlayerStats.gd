extends Node

var level := 1
var xp := 0
var xp_to_next_level: float = 50.0

var max_health := 100
var current_health := 100
var coins := 0
var potions := 0
var equipped_weapon_name := "Espada Inicial"
var weapon_damage_bonus := 0

func reset():
	level = 1
	xp = 0
	xp_to_next_level = 50
	max_health = 100
	current_health = max_health
	coins = 0
	potions = 0
	equipped_weapon_name = "Espada Inicial"
	weapon_damage_bonus = 0

func to_save_data():
	return {
		"level": level,
		"xp": xp,
		"xp_to_next_level": xp_to_next_level,
		"max_health": max_health,
		"current_health": current_health,
		"coins": coins,
		"potions": potions,
		"equipped_weapon_name": equipped_weapon_name,
		"weapon_damage_bonus": weapon_damage_bonus
	}

func load_save_data(data):
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	xp_to_next_level = float(data.get("xp_to_next_level", 50.0))
	max_health = int(data.get("max_health", 100))
	current_health = int(data.get("current_health", max_health))
	coins = int(data.get("coins", 0))
	potions = int(data.get("potions", 0))
	equipped_weapon_name = str(data.get("equipped_weapon_name", "Espada Inicial"))
	weapon_damage_bonus = int(data.get("weapon_damage_bonus", 0))

func add_xp(amount):
	xp += amount
	print("XP: ", xp, "/", xp_to_next_level)

	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp = xp - int(xp_to_next_level)
	xp_to_next_level *= 1.5

	max_health += 20
	current_health = max_health

	print("LEVEL UP! Agora nível ", level)


func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount


func can_afford(cost: int) -> bool:
	return coins >= max(cost, 0)


func spend_coins(cost: int) -> bool:
	if not can_afford(cost):
		return false

	coins -= max(cost, 0)
	return true


func add_potion(amount: int = 1) -> void:
	if amount <= 0:
		return
	potions += amount


func use_potion(heal_amount: int = 40) -> bool:
	if potions <= 0:
		return false
	if current_health >= max_health:
		return false

	potions -= 1
	current_health = min(current_health + max(heal_amount, 0), max_health)
	return true


func equip_weapon(weapon_name: String, damage_bonus: int) -> void:
	equipped_weapon_name = weapon_name
	weapon_damage_bonus = max(damage_bonus, 0)


func get_total_damage(base_damage: int) -> int:
	return max(base_damage + weapon_damage_bonus, 0)
