extends Control

const TOOLTIP_OFFSET := Vector2(16, 16)

@onready var level_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/LevelValue
@onready var xp_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/XPValue
@onready var hp_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/HPValue
@onready var sp_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/SPValue
@onready var mp_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/MPValue
@onready var damage_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/DamageValue
@onready var magic_damage_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/MagicDamageValue
@onready var armor_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/ArmorValue
@onready var hit_chance_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/HitChanceValue
@onready var crit_chance_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/CritChanceValue
@onready var crit_damage_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/CritDamageValue
@onready var speed_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/SpeedValue
@onready var attack_speed_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/AttackSpeedValue
@onready var hit_range_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/HitRangeValue
@onready var kills_label: Label = $CenterContainer/LayoutRoot/StatusContent/StatusValueList/KillsValue

@onready var available_points_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesHeader/AvailablePointsValue
@onready var total_points_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesHeader/TotalPointsValue
@onready var strength_value_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/StrengthValue
@onready var vitality_value_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/VitalityValue
@onready var dexterity_value_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/DexterityValue
@onready var intelligence_value_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/IntelligenceValue
@onready var luck_value_label: Label = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/LuckValue

@onready var add_strength_button: Button = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/StrengthPlus
@onready var add_vitality_button: Button = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/VitalityPlus
@onready var add_dexterity_button: Button = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/DexterityPlus
@onready var add_intelligence_button: Button = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/IntelligencePlus
@onready var add_luck_button: Button = $CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/LuckPlus
@onready var reset_attributes_button: Button = $CenterContainer/LayoutRoot/AttributesContent/Actions/ResetAttributesButton
@onready var close_button: Button = $CenterContainer/LayoutRoot/AttributesContent/Actions/CloseButton

var _hover_tooltip_panel: PanelContainer
var _hover_tooltip_label: Label

signal close_requested

func _ready() -> void:
	add_strength_button.pressed.connect(func(): _on_attribute_increment("strength"))
	add_vitality_button.pressed.connect(func(): _on_attribute_increment("vitality"))
	add_dexterity_button.pressed.connect(func(): _on_attribute_increment("dexterity"))
	add_intelligence_button.pressed.connect(func(): _on_attribute_increment("intelligence"))
	add_luck_button.pressed.connect(func(): _on_attribute_increment("luck"))
	reset_attributes_button.pressed.connect(_on_reset_attributes_pressed)
	close_button.pressed.connect(func(): close_requested.emit())
	_build_hover_tooltip()
	_bind_field_tooltips()

func _process(_delta: float) -> void:
	if _hover_tooltip_panel != null and _hover_tooltip_panel.visible:
		_update_tooltip_position()

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

func _build_hover_tooltip() -> void:
	_hover_tooltip_panel = PanelContainer.new()
	_hover_tooltip_panel.visible = false
	_hover_tooltip_panel.z_index = 200
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.78)
	style.border_color = Color(0.9, 0.82, 0.58, 0.85)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	_hover_tooltip_panel.add_theme_stylebox_override("panel", style)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	_hover_tooltip_panel.add_child(margin)
	_hover_tooltip_label = Label.new()
	_hover_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hover_tooltip_label.custom_minimum_size = Vector2(280, 0)
	margin.add_child(_hover_tooltip_label)
	add_child(_hover_tooltip_panel)

func _bind_field_tooltips() -> void:
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/LevelLabel", "Nivel atual do jogador e referencia de progressao geral.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/XPLabel", "Experiencia atual e quanto falta para o proximo nivel.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/HPLabel", "Vida atual e maxima do jogador.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/SPLabel", "Stamina atual e maxima. Usada por habilidades de vigor.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/MPLabel", "Mana atual e maxima. Base para habilidades magicas.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/DamageLabel", "Dano fisico atual do jogador.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/MagicDamageLabel", "Dano magico atual do jogador.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/ArmorLabel", "Reducao de dano recebida por defesa/armadura.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/HitChanceLabel", "Chance base de um ataque acertar o alvo.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/CritChanceLabel", "Probabilidade de causar ataque critico.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/CritDamageLabel", "Multiplicador percentual aplicado em acertos criticos.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/SpeedLabel", "Velocidade atual de movimento do jogador.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/AttackSpeedLabel", "Quantidade de ataques por segundo do jogador.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/HitRangeLabel", "Distancia maxima para conectar ataques corpo a corpo.")
	_bind_tooltip("CenterContainer/LayoutRoot/StatusContent/StatusNameList/KillsLabel", "Total de inimigos derrotados nesta campanha.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesHeader/AvailablePointsLabel", "Pontos livres para distribuir nos atributos.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesHeader/TotalPointsLabel", "Soma total de pontos conquistados por nivel.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/StrengthLabel", "Forca representa a capacidade de causar dano, interferindo diretamente no dano causado.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/VitalityLabel", "Vitalidade aumenta HP e SP maximos do jogador.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/DexterityLabel", "Destreza melhora acerto, velocidade de movimento e velocidade de ataque.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/IntelligenceLabel", "Inteligencia aumenta MP maximo e escala dano magico.")
	_bind_tooltip("CenterContainer/LayoutRoot/AttributesContent/AttributesGrid/LuckLabel", "Sorte aumenta a chance de acertos criticos.")

func _bind_tooltip(node_path: String, description: String) -> void:
	var target: Control = get_node_or_null(node_path) as Control
	if target == null:
		return
	target.mouse_filter = Control.MOUSE_FILTER_PASS
	target.mouse_entered.connect(func(): _show_tooltip(description))
	target.mouse_exited.connect(_hide_tooltip)

func _show_tooltip(description: String) -> void:
	if _hover_tooltip_panel == null:
		return
	_hover_tooltip_label.text = description
	_hover_tooltip_panel.visible = true
	_update_tooltip_position()

func _hide_tooltip() -> void:
	if _hover_tooltip_panel != null:
		_hover_tooltip_panel.visible = false

func _update_tooltip_position() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var panel_size: Vector2 = _hover_tooltip_panel.size
	var desired_position: Vector2 = get_viewport().get_mouse_position() + TOOLTIP_OFFSET
	if desired_position.x + panel_size.x > viewport_size.x - 8.0:
		desired_position.x = viewport_size.x - panel_size.x - 8.0
	if desired_position.y + panel_size.y > viewport_size.y - 8.0:
		desired_position.y = viewport_size.y - panel_size.y - 8.0
	desired_position.x = max(desired_position.x, 8.0)
	desired_position.y = max(desired_position.y, 8.0)
	_hover_tooltip_panel.position = desired_position
