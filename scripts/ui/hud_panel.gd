extends Control

const HUD_BAR_INNER_SIZE_X := 164.0

@onready var coins_label: Label = $CoinsLabel
@onready var floor_label: Label = $FloorLabel
@onready var inventory_quick_button: Button = $QuickActionsBar/MarginContainer/ActionsRow/InventoryQuickButton
@onready var character_quick_button: Button = $QuickActionsBar/MarginContainer/ActionsRow/CharacterQuickButton

@onready var level_label: Label = $PlayerHud/Portrait/LevelLabel
@onready var health_fill: ColorRect = $PlayerHud/StatusRows/HealthRow/BarRoot/FillClip/Fill
@onready var mana_fill: ColorRect = $PlayerHud/StatusRows/ManaRow/BarRoot/FillClip/Fill
@onready var stamina_fill: ColorRect = $PlayerHud/StatusRows/StaminaRow/BarRoot/FillClip/Fill
@onready var health_text: Label = $PlayerHud/StatusRows/HealthRow/ValueLabel
@onready var mana_text: Label = $PlayerHud/StatusRows/ManaRow/ValueLabel
@onready var stamina_text: Label = $PlayerHud/StatusRows/StaminaRow/ValueLabel

@onready var boss_health_root: Control = $BossHealthUI
@onready var boss_health_bar: ProgressBar = $BossHealthUI/Panel/Content/BossHealthBar
@onready var boss_name_label: Label = $BossHealthUI/Panel/Content/BossNameLabel

signal inventory_quick_pressed
signal character_quick_pressed

func _ready() -> void:
	inventory_quick_button.pressed.connect(func(): inventory_quick_pressed.emit())
	character_quick_button.pressed.connect(func(): character_quick_pressed.emit())

func set_hud_visible(visible_state: bool) -> void:
	visible = visible_state

func refresh(current_floor: int) -> void:
	var max_health: int = max(PlayerStats.max_health, 1)
	var current_health: int = clampi(PlayerStats.current_health, 0, max_health)
	var max_mana: int = max(PlayerStats.max_mana, 1)
	var current_mana: int = clampi(PlayerStats.current_mana, 0, max_mana)
	var max_stamina: int = max(PlayerStats.max_stamina, 1)
	var current_stamina: int = clampi(PlayerStats.current_stamina, 0, max_stamina)

	PlayerStats.current_health = current_health
	PlayerStats.current_mana = current_mana
	PlayerStats.current_stamina = current_stamina

	level_label.text = str(PlayerStats.level)
	health_fill.size.x = HUD_BAR_INNER_SIZE_X * (float(current_health) / float(max_health))
	mana_fill.size.x = HUD_BAR_INNER_SIZE_X * (float(current_mana) / float(max_mana))
	stamina_fill.size.x = HUD_BAR_INNER_SIZE_X * (float(current_stamina) / float(max_stamina))
	health_text.text = "%d/%d" % [current_health, max_health]
	mana_text.text = "%d/%d" % [current_mana, max_mana]
	stamina_text.text = "%d/%d" % [current_stamina, max_stamina]

	coins_label.text = "%d" % PlayerStats.coins
	floor_label.text = "Andar: %d" % current_floor

func update_boss_health_ui(current_floor: int, game_visible: bool, tracked_boss: Node) -> void:
	if current_floor != 10 or not game_visible:
		boss_health_root.visible = false
		return

	if tracked_boss == null or not is_instance_valid(tracked_boss):
		boss_health_root.visible = false
		return

	var max_hp: int = int(tracked_boss.get("max_health"))
	var current_hp: int = int(tracked_boss.get("current_health"))
	if max_hp <= 0 or current_hp <= 0:
		boss_health_root.visible = false
		return

	boss_health_bar.max_value = max_hp
	boss_health_bar.value = clampi(current_hp, 0, max_hp)
	if tracked_boss.has_method("get_boss_display_name"):
		boss_name_label.text = tracked_boss.get_boss_display_name()
	else:
		boss_name_label.text = "Boss do Andar 10"
	boss_health_root.visible = true
