extends Node

const BASE_STRENGTH := 5
const BASE_VITALITY := 5
const BASE_DEXTERITY := 5
const BASE_INTELLIGENCE := 5
const BASE_LUCK := 5

var level := 1
var xp := 0
var xp_to_next_level: float = 50.0

var max_health := 100
var current_health := 100
var coins := 0
var potions := 0
var equipped_weapon_name := "Espada Inicial"
var weapon_damage_bonus := 0
var enemy_kills := 0

var total_attribute_points := 10
var available_attribute_points := 10
var strength := BASE_STRENGTH
var vitality := BASE_VITALITY
var dexterity := BASE_DEXTERITY
var intelligence := BASE_INTELLIGENCE
var luck := BASE_LUCK

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
	enemy_kills = 0
	total_attribute_points = 10
	available_attribute_points = 10
	strength = BASE_STRENGTH
	vitality = BASE_VITALITY
	dexterity = BASE_DEXTERITY
	intelligence = BASE_INTELLIGENCE
	luck = BASE_LUCK

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
		"weapon_damage_bonus": weapon_damage_bonus,
		"enemy_kills": enemy_kills,
		"total_attribute_points": total_attribute_points,
		"available_attribute_points": available_attribute_points,
		"strength": strength,
		"vitality": vitality,
		"dexterity": dexterity,
		"intelligence": intelligence,
		"luck": luck
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
	enemy_kills = int(data.get("enemy_kills", 0))
	total_attribute_points = int(data.get("total_attribute_points", 10))
	available_attribute_points = int(data.get("available_attribute_points", total_attribute_points))
	strength = int(data.get("strength", BASE_STRENGTH))
	vitality = int(data.get("vitality", BASE_VITALITY))
	dexterity = int(data.get("dexterity", BASE_DEXTERITY))
	intelligence = int(data.get("intelligence", BASE_INTELLIGENCE))
	luck = int(data.get("luck", BASE_LUCK))

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

	print("LEVEL UP! Agora nivel ", level)

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
	var strength_bonus := max(strength - BASE_STRENGTH, 0)
	return max(base_damage + weapon_damage_bonus + strength_bonus, 0)

func register_enemy_kill() -> void:
	enemy_kills += 1

func increment_attribute(attribute_name: String) -> bool:
	if available_attribute_points <= 0:
		return false

	match attribute_name:
		"strength":
			strength += 1
		"vitality":
			vitality += 1
		"dexterity":
			dexterity += 1
		"intelligence":
			intelligence += 1
		"luck":
			luck += 1
		_:
			return false

	available_attribute_points -= 1
	return true

func reset_attributes() -> void:
	strength = BASE_STRENGTH
	vitality = BASE_VITALITY
	dexterity = BASE_DEXTERITY
	intelligence = BASE_INTELLIGENCE
	luck = BASE_LUCK
	available_attribute_points = total_attribute_points
