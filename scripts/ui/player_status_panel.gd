extends Control

@onready var level_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/LevelValue
@onready var xp_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/XPValue
@onready var hp_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/HPValue
@onready var sp_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/SPValue
@onready var mp_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/MPValue
@onready var damage_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/DamageValue
@onready var magic_damage_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/MagicDamageValue
@onready var armor_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/ArmorValue
@onready var hit_chance_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/HitChanceValue
@onready var crit_chance_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/CritChanceValue
@onready var crit_damage_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/CritDamageValue
@onready var speed_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/SpeedValue
@onready var attack_speed_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/AttackSpeedValue
@onready var hit_range_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/HitRangeValue
@onready var kills_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/StatusColumn/StatusGrid/KillsValue

@onready var available_points_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesHeader/AvailablePointsValue
@onready var total_points_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesHeader/TotalPointsValue
@onready var strength_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/StrengthValue
@onready var vitality_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/VitalityValue
@onready var dexterity_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/DexterityValue
@onready var intelligence_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/IntelligenceValue
@onready var luck_value_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/LuckValue
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/Actions/CloseButton

@onready var add_strength_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/StrengthPlus
@onready var add_vitality_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/VitalityPlus
@onready var add_dexterity_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/DexterityPlus
@onready var add_intelligence_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/IntelligencePlus
@onready var add_luck_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/AttributesGrid/LuckPlus
@onready var reset_attributes_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/AttributesColumn/Actions/ResetAttributesButton

signal close_requested

func _ready() -> void:
	add_strength_button.pressed.connect(func(): _on_attribute_increment("strength"))
	add_vitality_button.pressed.connect(func(): _on_attribute_increment("vitality"))
	add_dexterity_button.pressed.connect(func(): _on_attribute_increment("dexterity"))
	add_intelligence_button.pressed.connect(func(): _on_attribute_increment("intelligence"))
	add_luck_button.pressed.connect(func(): _on_attribute_increment("luck"))
	reset_attributes_button.pressed.connect(_on_reset_attributes_pressed)
	close_button.pressed.connect(func(): close_requested.emit())

func refresh(player_node: Node) -> void:
	level_label.text = str(PlayerStats.level)
	xp_label.text = "%d/%d" % [PlayerStats.xp, int(PlayerStats.xp_to_next_level)]
	hp_label.text = "%d/%d" % [PlayerStats.current_health, PlayerStats.max_health]
	sp_label.text = "%d/%d" % [PlayerStats.current_stamina, PlayerStats.max_stamina]
	mp_label.text = "%d/%d" % [PlayerStats.current_mana, PlayerStats.max_mana]

	var base_damage := 0
	var attack_range := 0
	var move_speed := 0
	var attack_speed := 0.0

	if is_instance_valid(player_node):
		if "attack_damage" in player_node:
			base_damage = int(player_node.attack_damage)
		if "attack_range" in player_node:
			attack_range = int(player_node.attack_range)
		if "speed" in player_node:
			move_speed = int(PlayerStats.get_move_speed(float(player_node.speed)))
		if "attack_cooldown" in player_node:
			attack_speed = PlayerStats.get_attack_speed_from_cooldown(float(player_node.attack_cooldown))

	damage_label.text = str(PlayerStats.get_total_damage(base_damage))
	magic_damage_label.text = str(PlayerStats.get_magic_damage(0))
	armor_label.text = "0"
	hit_chance_label.text = "%d%%" % PlayerStats.get_hit_chance_percent()
	crit_chance_label.text = "%d%%" % PlayerStats.get_crit_chance_percent()
	crit_damage_label.text = "%d%%" % PlayerStats.get_crit_damage_percent()
	speed_label.text = str(move_speed)
	attack_speed_label.text = "%.2f" % attack_speed
	hit_range_label.text = str(attack_range)
	kills_label.text = str(PlayerStats.enemy_kills)

	available_points_label.text = str(PlayerStats.available_attribute_points)
	total_points_label.text = str(PlayerStats.total_attribute_points)
	strength_value_label.text = str(PlayerStats.strength)
	vitality_value_label.text = str(PlayerStats.vitality)
	dexterity_value_label.text = str(PlayerStats.dexterity)
	intelligence_value_label.text = str(PlayerStats.intelligence)
	luck_value_label.text = str(PlayerStats.luck)

	var can_spend := PlayerStats.available_attribute_points > 0
	add_strength_button.disabled = not can_spend
	add_vitality_button.disabled = not can_spend
	add_dexterity_button.disabled = not can_spend
	add_intelligence_button.disabled = not can_spend
	add_luck_button.disabled = not can_spend

func _on_attribute_increment(attribute_name: String) -> void:
	if PlayerStats.increment_attribute(attribute_name):
		refresh(get_tree().get_first_node_in_group("player"))

func _on_reset_attributes_pressed() -> void:
	PlayerStats.reset_attributes()
	refresh(get_tree().get_first_node_in_group("player"))
