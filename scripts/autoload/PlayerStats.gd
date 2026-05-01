extends Node
signal coins_changed(value: int)

const BASE_STRENGTH := 0
const BASE_VITALITY := 0
const BASE_DEXTERITY := 0
const BASE_INTELLIGENCE := 0
const BASE_LUCK := 0

const BASE_HEALTH := 100
const BASE_STAMINA := 100
const BASE_MANA := 100
const VITALITY_HEALTH_PER_POINT := 5
const VITALITY_STAMINA_PER_POINT := 10
const INTELLIGENCE_MANA_PER_POINT := 10

const STRENGTH_DAMAGE_PERCENT_PER_POINT := 0.02
const INTELLIGENCE_MAGIC_DAMAGE_PERCENT_PER_POINT := 0.02
const DEXTERITY_MOVE_SPEED_PERCENT_PER_POINT := 0.005
const DEXTERITY_ATTACK_SPEED_FLAT_PER_POINT := 0.05
const DEXTERITY_HIT_CHANCE_PER_POINT := 1
const LUCK_CRIT_CHANCE_PER_POINT := 1
const BASE_HIT_CHANCE_PERCENT := 65
const BASE_CRIT_CHANCE_PERCENT := 5
const BASE_CRIT_DAMAGE_PERCENT := 150
const MAX_DAMAGE_REDUCTION_RATIO := 0.75
const ARMOR_TO_DAMAGE_REDUCTION_RATIO := 0.0015
const RESISTANCE_COLLAR_DAMAGE_REDUCTION_RATIO := 0.20
const IRON_CHESTPLATE_ARMOR := 75
const IRON_PANTS_ARMOR := 50
const IRON_HELMET_ARMOR := 30
const LEATHER_BOOTS_MOVE_SPEED_BONUS_RATIO := 0.50
const INVENTORY_TOTAL_BACKPACK_SLOTS := 30
const INVENTORY_UNLOCKED_BACKPACK_SLOTS := 15
const INVENTORY_EQUIPMENT_SLOT_IDS := ["head", "necklace", "left_hand", "chest", "right_hand", "ring_1", "legs", "ring_2", "feet"]

const STARTING_ATTRIBUTE_POINTS := 10
const ATTRIBUTE_POINTS_PER_LEVEL := 5

var level := 1
var xp := 0
var xp_to_next_level: float = 50.0

var max_health := BASE_HEALTH
var current_health := BASE_HEALTH
var max_stamina := BASE_STAMINA
var current_stamina := BASE_STAMINA
var max_mana := BASE_MANA
var current_mana := BASE_MANA

var coins := 0
var potions := 0
var equipped_weapon_name := "Espada Inicial"
var weapon_damage_bonus := 0
var has_resistance_collar := false
var has_iron_chestplate := false
var has_iron_pants := false
var has_iron_helmet := false
var has_leather_boots := false
var enemy_kills := 0
var level_resource_bonus := 0
var level_damage_bonus := 0
var inventory_weapon_damage_bonus := 0
var inventory_flat_armor_bonus := 0
var inventory_damage_reduction_bonus_ratio := 0.0
var inventory_move_speed_bonus_ratio := 0.0
var inventory_crit_chance_bonus_percent := 0
var inventory_backpack_slots: Array = []
var inventory_equipment_slots: Dictionary = {}

var total_attribute_points := STARTING_ATTRIBUTE_POINTS
var available_attribute_points := STARTING_ATTRIBUTE_POINTS
var strength := BASE_STRENGTH
var vitality := BASE_VITALITY
var dexterity := BASE_DEXTERITY
var intelligence := BASE_INTELLIGENCE
var luck := BASE_LUCK

func reset() -> void:
	level = 1
	xp = 0
	xp_to_next_level = 50.0
	coins = 0
	potions = 0
	equipped_weapon_name = "Espada Inicial"
	weapon_damage_bonus = 0
	has_resistance_collar = false
	has_iron_chestplate = false
	has_iron_pants = false
	has_iron_helmet = false
	has_leather_boots = false
	enemy_kills = 0
	level_resource_bonus = 0
	level_damage_bonus = 0
	inventory_weapon_damage_bonus = 0
	inventory_flat_armor_bonus = 0
	inventory_damage_reduction_bonus_ratio = 0.0
	inventory_move_speed_bonus_ratio = 0.0
	inventory_crit_chance_bonus_percent = 0
	inventory_backpack_slots = []
	inventory_equipment_slots = {}
	total_attribute_points = STARTING_ATTRIBUTE_POINTS
	available_attribute_points = STARTING_ATTRIBUTE_POINTS
	strength = BASE_STRENGTH
	vitality = BASE_VITALITY
	dexterity = BASE_DEXTERITY
	intelligence = BASE_INTELLIGENCE
	luck = BASE_LUCK
	_rebuild_level_scaling_from_level()
	_recalculate_resource_caps(true)
	coins_changed.emit(coins)

func to_save_data() -> Dictionary:
	return {
		"level": level,
		"xp": xp,
		"xp_to_next_level": xp_to_next_level,
		"max_health": max_health,
		"current_health": current_health,
		"max_stamina": max_stamina,
		"current_stamina": current_stamina,
		"max_mana": max_mana,
		"current_mana": current_mana,
		"coins": coins,
		"potions": potions,
		"equipped_weapon_name": equipped_weapon_name,
		"weapon_damage_bonus": weapon_damage_bonus,
		"has_resistance_collar": has_resistance_collar,
		"has_iron_chestplate": has_iron_chestplate,
		"has_iron_pants": has_iron_pants,
		"has_iron_helmet": has_iron_helmet,
		"has_leather_boots": has_leather_boots,
		"inventory_backpack_slots": inventory_backpack_slots.duplicate(true),
		"inventory_equipment_slots": inventory_equipment_slots.duplicate(true),
		"enemy_kills": enemy_kills,
		"total_attribute_points": total_attribute_points,
		"available_attribute_points": available_attribute_points,
		"strength": strength,
		"vitality": vitality,
		"dexterity": dexterity,
		"intelligence": intelligence,
		"luck": luck
	}

func load_save_data(data: Dictionary) -> void:
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	xp_to_next_level = float(data.get("xp_to_next_level", 50.0))
	coins = int(data.get("coins", 0))
	potions = int(data.get("potions", 0))
	equipped_weapon_name = str(data.get("equipped_weapon_name", "Espada Inicial"))
	weapon_damage_bonus = int(data.get("weapon_damage_bonus", 0))
	has_resistance_collar = bool(data.get("has_resistance_collar", false))
	if bool(data.get("has_iron_armor", false)):
		has_resistance_collar = true
	has_iron_chestplate = bool(data.get("has_iron_chestplate", false))
	has_iron_pants = bool(data.get("has_iron_pants", false))
	has_iron_helmet = bool(data.get("has_iron_helmet", false))
	has_leather_boots = bool(data.get("has_leather_boots", false))
	inventory_weapon_damage_bonus = 0
	inventory_flat_armor_bonus = 0
	inventory_damage_reduction_bonus_ratio = 0.0
	inventory_move_speed_bonus_ratio = 0.0
	inventory_crit_chance_bonus_percent = 0
	inventory_backpack_slots = []
	inventory_equipment_slots = {}

	var saved_backpack = data.get("inventory_backpack_slots", [])
	if saved_backpack is Array:
		inventory_backpack_slots = (saved_backpack as Array).duplicate(true)
	var saved_equipment = data.get("inventory_equipment_slots", {})
	if saved_equipment is Dictionary:
		inventory_equipment_slots = (saved_equipment as Dictionary).duplicate(true)
	enemy_kills = int(data.get("enemy_kills", 0))
	total_attribute_points = int(data.get("total_attribute_points", STARTING_ATTRIBUTE_POINTS))
	available_attribute_points = int(data.get("available_attribute_points", total_attribute_points))
	strength = int(data.get("strength", BASE_STRENGTH))
	vitality = int(data.get("vitality", BASE_VITALITY))
	dexterity = int(data.get("dexterity", BASE_DEXTERITY))
	intelligence = int(data.get("intelligence", BASE_INTELLIGENCE))
	luck = int(data.get("luck", BASE_LUCK))

	_rebuild_level_scaling_from_level()
	_recalculate_resource_caps(false)
	current_health = int(data.get("current_health", max_health))
	current_stamina = int(data.get("current_stamina", max_stamina))
	current_mana = int(data.get("current_mana", max_mana))
	current_health = clampi(current_health, 0, max_health)
	current_stamina = clampi(current_stamina, 0, max_stamina)
	current_mana = clampi(current_mana, 0, max_mana)
	coins_changed.emit(coins)

func add_xp(amount: int) -> void:
	if amount <= 0:
		return

	xp += amount
	print("XP: ", xp, "/", xp_to_next_level)

	while xp >= int(xp_to_next_level):
		level_up()

func level_up() -> void:
	level += 1
	xp -= int(xp_to_next_level)
	xp_to_next_level *= 1.5
	total_attribute_points += ATTRIBUTE_POINTS_PER_LEVEL
	available_attribute_points += ATTRIBUTE_POINTS_PER_LEVEL
	var level_gain: int = 25 if level % 5 == 0 else 10
	level_resource_bonus += level_gain
	level_damage_bonus += 2
	_recalculate_resource_caps(true)
	print("LEVEL UP! Agora nivel ", level)

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)

func can_afford(cost: int) -> bool:
	return coins >= max(cost, 0)

func spend_coins(cost: int) -> bool:
	if not can_afford(cost):
		return false

	coins -= max(cost, 0)
	coins_changed.emit(coins)
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
	heal(heal_amount)
	return true

func take_damage(amount: int) -> int:
	var damage_taken: int = max(amount, 0)
	current_health = clampi(current_health - damage_taken, 0, max_health)
	return current_health

func heal(amount: int) -> int:
	var heal_amount: int = max(amount, 0)
	current_health = clampi(current_health + heal_amount, 0, max_health)
	return current_health

func refill_health() -> void:
	current_health = max_health

func equip_weapon(weapon_name: String, damage_bonus: int) -> void:
	equipped_weapon_name = weapon_name
	weapon_damage_bonus = max(damage_bonus, 0)

func equip_resistance_collar() -> void:
	has_resistance_collar = true

func equip_iron_chestplate() -> void:
	has_iron_chestplate = true

func equip_iron_pants() -> void:
	has_iron_pants = true

func equip_iron_helmet() -> void:
	has_iron_helmet = true

func equip_leather_boots() -> void:
	has_leather_boots = true

func register_enemy_kill() -> void:
	enemy_kills += 1

func apply_inventory_item_bonuses(bonuses: Dictionary) -> void:
	inventory_weapon_damage_bonus = max(int(bonuses.get("weapon_damage_bonus", 0)), 0)
	inventory_flat_armor_bonus = max(int(bonuses.get("flat_armor_bonus", 0)), 0)
	inventory_damage_reduction_bonus_ratio = max(float(bonuses.get("damage_reduction_bonus_ratio", 0.0)), 0.0)
	inventory_move_speed_bonus_ratio = max(float(bonuses.get("move_speed_bonus_ratio", 0.0)), 0.0)
	inventory_crit_chance_bonus_percent = max(int(bonuses.get("crit_chance_bonus_percent", 0)), 0)

func set_inventory_state(backpack_slots: Array, equipment_slots: Dictionary) -> void:
	inventory_backpack_slots = backpack_slots.duplicate(true)
	inventory_equipment_slots = equipment_slots.duplicate(true)

func get_inventory_state() -> Dictionary:
	return {
		"backpack_slots": inventory_backpack_slots.duplicate(true),
		"equipment_slots": inventory_equipment_slots.duplicate(true)
	}

func has_inventory_state() -> bool:
	return not inventory_backpack_slots.is_empty() and not inventory_equipment_slots.is_empty()

func inventory_contains_item_named(item_name: String) -> bool:
	if item_name == "":
		return false

	for entry in inventory_backpack_slots:
		if not (entry is Dictionary):
			continue
		var item_data := entry as Dictionary
		if str(item_data.get("display_name", "")) == item_name:
			return true

	for entry in inventory_equipment_slots.values():
		if not (entry is Dictionary):
			continue
		var item_data := entry as Dictionary
		if str(item_data.get("display_name", "")) == item_name:
			return true

	return false

func add_item_to_inventory(item_data: Dictionary) -> bool:
	if item_data.is_empty():
		return false

	_ensure_inventory_state_initialized()
	for index in range(INVENTORY_UNLOCKED_BACKPACK_SLOTS):
		var slot_entry = inventory_backpack_slots[index]
		if slot_entry is Dictionary and not (slot_entry as Dictionary).is_empty():
			continue
		inventory_backpack_slots[index] = item_data.duplicate(true)
		return true

	return false

func _ensure_inventory_state_initialized() -> void:
	if inventory_backpack_slots.size() != INVENTORY_TOTAL_BACKPACK_SLOTS:
		inventory_backpack_slots.resize(INVENTORY_TOTAL_BACKPACK_SLOTS)
		for index in range(INVENTORY_TOTAL_BACKPACK_SLOTS):
			var existing = inventory_backpack_slots[index]
			if existing is Dictionary:
				continue
			inventory_backpack_slots[index] = {}

	for slot_id in INVENTORY_EQUIPMENT_SLOT_IDS:
		if not inventory_equipment_slots.has(slot_id):
			inventory_equipment_slots[slot_id] = {}

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
	_recalculate_resource_caps(false)
	return true

func reset_attributes() -> void:
	strength = BASE_STRENGTH
	vitality = BASE_VITALITY
	dexterity = BASE_DEXTERITY
	intelligence = BASE_INTELLIGENCE
	luck = BASE_LUCK
	available_attribute_points = total_attribute_points
	_recalculate_resource_caps(false)

func get_total_damage(base_damage: int) -> int:
	var effective_weapon_bonus: int = maxi(weapon_damage_bonus, inventory_weapon_damage_bonus)
	var base_with_weapon: float = float(max(base_damage + effective_weapon_bonus + level_damage_bonus, 0))
	return int(round(base_with_weapon * get_strength_damage_multiplier()))

func get_magic_damage(base_magic_damage: int = 0) -> int:
	var safe_base: float = float(max(base_magic_damage, 0))
	return int(round(safe_base * get_magic_damage_multiplier()))

func get_strength_damage_multiplier() -> float:
	return 1.0 + float(strength) * STRENGTH_DAMAGE_PERCENT_PER_POINT

func get_magic_damage_multiplier() -> float:
	return 1.0 + float(intelligence) * INTELLIGENCE_MAGIC_DAMAGE_PERCENT_PER_POINT

func get_move_speed(base_speed: float) -> float:
	var speed_multiplier: float = _get_move_speed_multiplier()
	return max(base_speed * speed_multiplier, 0.0)

func get_move_speed_percent() -> int:
	var speed_multiplier: float = _get_move_speed_multiplier()
	return int(round(max(speed_multiplier, 0.0) * 100.0))

func get_attack_speed_from_cooldown(base_cooldown: float) -> float:
	var safe_cooldown: float = max(base_cooldown, 0.001)
	var base_attack_speed: float = 1.0 / safe_cooldown
	return max(base_attack_speed + float(dexterity) * DEXTERITY_ATTACK_SPEED_FLAT_PER_POINT, 0.05)

func get_attack_cooldown(base_cooldown: float) -> float:
	var attack_speed: float = get_attack_speed_from_cooldown(base_cooldown)
	return max(1.0 / attack_speed, 0.05)

func get_hit_chance_percent() -> int:
	return clampi(BASE_HIT_CHANCE_PERCENT + dexterity * DEXTERITY_HIT_CHANCE_PER_POINT, 0, 100)

func get_crit_chance_percent() -> int:
	return clampi(BASE_CRIT_CHANCE_PERCENT + luck * LUCK_CRIT_CHANCE_PER_POINT + inventory_crit_chance_bonus_percent, 0, 100)

func get_crit_damage_percent() -> int:
	return BASE_CRIT_DAMAGE_PERCENT

func get_armor_damage_reduction_percent() -> int:
	return int(round(get_armor_damage_reduction_ratio() * 100.0))

func get_damage_reduction_percent() -> int:
	return int(round(get_damage_reduction_ratio() * 100.0))

func get_total_armor() -> int:
	var armor := 0
	if has_iron_chestplate:
		armor += IRON_CHESTPLATE_ARMOR
	if has_iron_pants:
		armor += IRON_PANTS_ARMOR
	if has_iron_helmet:
		armor += IRON_HELMET_ARMOR
	return armor + inventory_flat_armor_bonus

func get_armor_damage_reduction_ratio() -> float:
	return min(float(get_total_armor()) * ARMOR_TO_DAMAGE_REDUCTION_RATIO, MAX_DAMAGE_REDUCTION_RATIO)

func get_item_damage_reduction_ratio() -> float:
	var legacy_ratio := RESISTANCE_COLLAR_DAMAGE_REDUCTION_RATIO if has_resistance_collar else 0.0
	return legacy_ratio + inventory_damage_reduction_bonus_ratio

func get_damage_reduction_ratio() -> float:
	var total_ratio: float = get_armor_damage_reduction_ratio() + get_item_damage_reduction_ratio()
	return min(total_ratio, MAX_DAMAGE_REDUCTION_RATIO)

func get_incoming_damage(raw_damage: int) -> int:
	if raw_damage <= 0:
		return 0

	var reduced_damage: float = float(raw_damage) * (1.0 - get_damage_reduction_ratio())
	return maxi(int(ceil(reduced_damage)), 1)

func _recalculate_resource_caps(refill: bool) -> void:
	var new_max_health: int = BASE_HEALTH + level_resource_bonus + vitality * VITALITY_HEALTH_PER_POINT
	var new_max_stamina: int = BASE_STAMINA + level_resource_bonus + vitality * VITALITY_STAMINA_PER_POINT
	var new_max_mana: int = BASE_MANA + level_resource_bonus + intelligence * INTELLIGENCE_MANA_PER_POINT

	max_health = max(new_max_health, 1)
	max_stamina = max(new_max_stamina, 1)
	max_mana = max(new_max_mana, 1)

	if refill:
		current_health = max_health
		current_stamina = max_stamina
		current_mana = max_mana
	else:
		current_health = clampi(current_health, 0, max_health)
		current_stamina = clampi(current_stamina, 0, max_stamina)
		current_mana = clampi(current_mana, 0, max_mana)

func _rebuild_level_scaling_from_level() -> void:
	level_resource_bonus = 0
	level_damage_bonus = 0
	for current_level in range(2, level + 1):
		level_resource_bonus += 25 if current_level % 5 == 0 else 10
		level_damage_bonus += 2

func _get_move_speed_multiplier() -> float:
	var speed_multiplier: float = 1.0 + float(dexterity) * DEXTERITY_MOVE_SPEED_PERCENT_PER_POINT
	if has_leather_boots:
		speed_multiplier += LEATHER_BOOTS_MOVE_SPEED_BONUS_RATIO
	speed_multiplier += inventory_move_speed_bonus_ratio
	return speed_multiplier
