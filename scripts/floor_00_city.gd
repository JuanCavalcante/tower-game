extends Node2D
class_name Floor00City

const TOTAL_PORTAL_FLOORS := 10
const POTION_COST := 15
const WEAPON_COST := 60
const RESISTANCE_COLLAR_COST := 400
const IRON_CHESTPLATE_COST := 500
const IRON_PANTS_COST := 360
const IRON_HELMET_COST := 280
const LEATHER_BOOTS_COST := 300
const RESISTANCE_COLLAR_REDUCTION_PERCENT := 20
const WEAPON_NAME := "Lamina de Aco"
const WEAPON_DAMAGE_BONUS := 15
const RESISTANCE_COLLAR_NAME := "Colar da Resistencia"
const IRON_CHESTPLATE_NAME := "Peitoral de ferro"
const IRON_PANTS_NAME := "Calcas de ferro"
const IRON_HELMET_NAME := "Elmo de ferro"
const LEATHER_BOOTS_NAME := "Botas de couro"
const BUY_SOUND := preload("res://assets/sprites/effect/sound/buySound.mp3")

var _player_in_portal_range := false
var _player_in_vendor_range := false
var _ui_open := false
var _active_ui_mode := ""
var _paused_by_hub_ui := false

@onready var interact_prompt: Label = $InteractPrompt
@onready var portal_ui: CanvasLayer = $PortalUI
@onready var portal_overlay: ColorRect = $PortalUI/Overlay
@onready var portal_panel: PanelContainer = $PortalUI/PortalPanel
@onready var floor_buttons_grid: GridContainer = $PortalUI/PortalPanel/VBox/FloorButtons
@onready var panel_title: Label = $PortalUI/PortalPanel/VBox/Title
@onready var portal_anchor: Marker2D = $PortalAnchor
@onready var portal_area: Area2D = $PortalArea

var vendor_anchor: Marker2D = null
var vendor_area: Area2D = null
var _vendor_label: Label = null
var _buy_sfx_player: AudioStreamPlayer2D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sync_portal_layout_to_sprite()
	_ensure_vendor_area()

	interact_prompt.visible = false
	portal_overlay.visible = false
	portal_panel.visible = false
	portal_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	portal_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio()

	_build_portal_buttons()

	portal_area.body_entered.connect(_on_portal_body_entered)
	portal_area.body_exited.connect(_on_portal_body_exited)
	if vendor_area != null:
		vendor_area.body_entered.connect(_on_vendor_body_entered)
		vendor_area.body_exited.connect(_on_vendor_body_exited)

	var close_btn: Button = $PortalUI/PortalPanel/VBox/CloseButton
	close_btn.pressed.connect(_close_ui)

func _sync_portal_layout_to_sprite() -> void:
	var portal_sprite: Node2D = _find_portal_sprite()
	var portal_position: Vector2 = portal_anchor.global_position

	if portal_sprite != null:
		portal_position = portal_sprite.global_position
	else:
		push_warning("Portal nao encontrado em CidadeHub; usando PortalAnchor como fallback.")

	portal_anchor.global_position = portal_position
	portal_area.global_position = portal_position
	interact_prompt.global_position = portal_position + Vector2(-130, -120)

func _find_portal_sprite() -> Node2D:
	var direct_portal := get_node_or_null("CidadeHub/Portal") as Node2D
	if direct_portal != null:
		return direct_portal

	var nested_portal := get_node_or_null("CidadeHub/Cidade_Hub/Portal") as Node2D
	if nested_portal != null:
		return nested_portal

	return null


func _find_trader_sprite() -> Node2D:
	var direct_trader := get_node_or_null("CidadeHub/TraderNpc") as Node2D
	if direct_trader != null:
		return direct_trader

	var nested_trader := get_node_or_null("CidadeHub/Cidade_Hub/TraderNpc") as Node2D
	if nested_trader != null:
		return nested_trader

	return null


func _ensure_audio() -> void:
	if _buy_sfx_player != null:
		return

	_buy_sfx_player = AudioStreamPlayer2D.new()
	_buy_sfx_player.name = "BuySfx"
	_buy_sfx_player.stream = BUY_SOUND
	_buy_sfx_player.volume_db = -6.0
	add_child(_buy_sfx_player)


func _ensure_vendor_area() -> void:
	vendor_anchor = get_node_or_null("VendorAnchor") as Marker2D
	var trader_sprite: Node2D = _find_trader_sprite()
	var vendor_position: Vector2 = portal_anchor.global_position + Vector2(220, 0)
	if trader_sprite != null:
		vendor_position = trader_sprite.global_position
	else:
		push_warning("TraderNpc nao encontrado em CidadeHub; usando fallback de posicao.")

	if vendor_anchor == null:
		vendor_anchor = Marker2D.new()
		vendor_anchor.name = "VendorAnchor"
		add_child(vendor_anchor)

	vendor_anchor.global_position = vendor_position

	vendor_area = get_node_or_null("VendorArea") as Area2D
	if vendor_area == null:
		vendor_area = Area2D.new()
		vendor_area.name = "VendorArea"
		add_child(vendor_area)
		vendor_area.global_position = vendor_anchor.global_position

		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 72.0
		shape.shape = circle
		vendor_area.add_child(shape)

	_vendor_label = get_node_or_null("VendorLabel") as Label
	if _vendor_label == null:
		_vendor_label = Label.new()
		_vendor_label.name = "VendorLabel"
		_vendor_label.text = ""
		_vendor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_vendor_label)

	_vendor_label.position = vendor_anchor.global_position + Vector2(-78, -110)


func _clear_action_buttons() -> void:
	for child in floor_buttons_grid.get_children():
		child.queue_free()


func _build_portal_buttons() -> void:
	_clear_action_buttons()
	floor_buttons_grid.columns = 5
	floor_buttons_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_title.text = "Escolha o Andar"

	for floor_num in range(1, TOTAL_PORTAL_FLOORS + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(120, 40)
		btn.set_meta("floor_number", floor_num)

		_apply_floor_button_state(btn, floor_num)

		btn.pressed.connect(func(): _enter_floor(floor_num))
		floor_buttons_grid.add_child(btn)


func _build_vendor_buttons() -> void:
	_clear_action_buttons()
	floor_buttons_grid.columns = 1
	floor_buttons_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel_title.text = "Vendedor"

	var status := Label.new()
	status.text = "Moedas: %d | Pocoes: %d" % [PlayerStats.coins, PlayerStats.potions]
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floor_buttons_grid.add_child(status)

	var potion_btn := Button.new()
	potion_btn.custom_minimum_size = Vector2(260, 40)
	potion_btn.text = "Comprar Pocao de Vida (%d moedas)" % POTION_COST
	potion_btn.pressed.connect(_buy_potion)
	floor_buttons_grid.add_child(potion_btn)

	var weapon_btn := Button.new()
	weapon_btn.custom_minimum_size = Vector2(260, 40)
	weapon_btn.text = "Comprar %s (+%d dano) - %d moedas" % [WEAPON_NAME, WEAPON_DAMAGE_BONUS, WEAPON_COST]
	weapon_btn.disabled = PlayerStats.weapon_damage_bonus >= WEAPON_DAMAGE_BONUS
	weapon_btn.pressed.connect(_buy_weapon)
	floor_buttons_grid.add_child(weapon_btn)

	var collar_btn := Button.new()
	collar_btn.custom_minimum_size = Vector2(260, 40)
	collar_btn.text = "Comprar %s (-%d%% dano) - %d moedas" % [RESISTANCE_COLLAR_NAME, RESISTANCE_COLLAR_REDUCTION_PERCENT, RESISTANCE_COLLAR_COST]
	collar_btn.disabled = PlayerStats.has_resistance_collar
	collar_btn.pressed.connect(_buy_resistance_collar)
	floor_buttons_grid.add_child(collar_btn)

	var chest_btn := Button.new()
	chest_btn.custom_minimum_size = Vector2(260, 40)
	chest_btn.text = "Comprar %s (+%d armadura) - %d moedas" % [IRON_CHESTPLATE_NAME, PlayerStats.IRON_CHESTPLATE_ARMOR, IRON_CHESTPLATE_COST]
	chest_btn.disabled = PlayerStats.has_iron_chestplate
	chest_btn.pressed.connect(_buy_iron_chestplate)
	floor_buttons_grid.add_child(chest_btn)

	var pants_btn := Button.new()
	pants_btn.custom_minimum_size = Vector2(260, 40)
	pants_btn.text = "Comprar %s (+%d armadura) - %d moedas" % [IRON_PANTS_NAME, PlayerStats.IRON_PANTS_ARMOR, IRON_PANTS_COST]
	pants_btn.disabled = PlayerStats.has_iron_pants
	pants_btn.pressed.connect(_buy_iron_pants)
	floor_buttons_grid.add_child(pants_btn)

	var helmet_btn := Button.new()
	helmet_btn.custom_minimum_size = Vector2(260, 40)
	helmet_btn.text = "Comprar %s (+%d armadura) - %d moedas" % [IRON_HELMET_NAME, PlayerStats.IRON_HELMET_ARMOR, IRON_HELMET_COST]
	helmet_btn.disabled = PlayerStats.has_iron_helmet
	helmet_btn.pressed.connect(_buy_iron_helmet)
	floor_buttons_grid.add_child(helmet_btn)

	var boots_btn := Button.new()
	boots_btn.custom_minimum_size = Vector2(260, 40)
	boots_btn.text = "Comprar %s (+50%% velocidade) - %d moedas" % [LEATHER_BOOTS_NAME, LEATHER_BOOTS_COST]
	boots_btn.disabled = PlayerStats.has_leather_boots
	boots_btn.pressed.connect(_buy_leather_boots)
	floor_buttons_grid.add_child(boots_btn)

	var equipment_status := Label.new()
	equipment_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_status.text = "Equipamentos: Colar[%s] | Peitoral[%s] | Calcas[%s] | Elmo[%s] | Botas[%s] | Armadura total[%d]" % [
		"OK" if PlayerStats.has_resistance_collar else "--",
		"OK" if PlayerStats.has_iron_chestplate else "--",
		"OK" if PlayerStats.has_iron_pants else "--",
		"OK" if PlayerStats.has_iron_helmet else "--",
		"OK" if PlayerStats.has_leather_boots else "--"
		,
		PlayerStats.get_total_armor()
	]
	floor_buttons_grid.add_child(equipment_status)

func _apply_floor_button_state(btn: Button, floor_num: int) -> void:
	var unlocked: bool = GameManager.is_floor_unlocked(floor_num)
	btn.disabled = not unlocked
	btn.text = "Andar %d" % floor_num if unlocked else "🔒 Andar %d (Bloqueado)" % floor_num
	btn.tooltip_text = "" if unlocked else "🔒 Bloqueado"

func _refresh_floor_buttons() -> void:
	for child in floor_buttons_grid.get_children():
		var btn := child as Button
		if btn == null or not btn.has_meta("floor_number"):
			continue

		var floor_num: int = int(btn.get_meta("floor_number"))
		_apply_floor_button_state(btn, floor_num)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("ui_cancel") and _ui_open:
		_close_ui()
		return

	if event.is_action_pressed("interact"):
		if (_player_in_portal_range or _player_in_vendor_range) and not _ui_open:
			if _player_in_vendor_range:
				_open_vendor_ui()
			elif _player_in_portal_range:
				_open_portal_ui()
		elif _ui_open:
			_close_ui()

func _on_portal_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_portal_range = true
	_update_interaction_prompt()


func _on_portal_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_portal_range = false
	if _ui_open and _active_ui_mode == "portal":
		_close_ui()
	_update_interaction_prompt()


func _on_vendor_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_vendor_range = true
	_update_interaction_prompt()


func _on_vendor_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_vendor_range = false
	if _ui_open and _active_ui_mode == "vendor":
		_close_ui()

	_update_interaction_prompt()


func _update_interaction_prompt() -> void:
	if _player_in_vendor_range:
		interact_prompt.text = "Pressione E para falar com o vendedor"
		interact_prompt.global_position = vendor_anchor.global_position + Vector2(-150, -130)
		interact_prompt.visible = true
		return

	if _player_in_portal_range:
		interact_prompt.text = "Pressione E para entrar no portal"
		interact_prompt.global_position = portal_anchor.global_position + Vector2(-130, -120)
		interact_prompt.visible = true
		return

	interact_prompt.visible = false


func _open_portal_ui() -> void:
	_active_ui_mode = "portal"
	_ui_open = true
	_pause_game_for_hub_ui()
	_build_portal_buttons()
	_refresh_floor_buttons()
	portal_overlay.visible = true
	portal_panel.visible = true


func _open_vendor_ui() -> void:
	_active_ui_mode = "vendor"
	_ui_open = true
	_pause_game_for_hub_ui()
	_build_vendor_buttons()
	portal_overlay.visible = true
	portal_panel.visible = true

func _close_ui() -> void:
	_ui_open = false
	_active_ui_mode = ""
	portal_overlay.visible = false
	portal_panel.visible = false
	_resume_game_from_hub_ui()

func _enter_floor(floor_number: int) -> void:
	_close_ui()
	GameManager.load_floor(floor_number, true, GameManager.SpawnContext.ENTER_TOWER)


func _pause_game_for_hub_ui() -> void:
	if get_tree().paused:
		return

	_paused_by_hub_ui = true
	get_tree().paused = true


func _resume_game_from_hub_ui() -> void:
	if not _paused_by_hub_ui:
		return

	_paused_by_hub_ui = false
	get_tree().paused = false


func _buy_potion() -> void:
	if not PlayerStats.spend_coins(POTION_COST):
		push_warning("Moedas insuficientes para comprar pocao.")
		return

	PlayerStats.add_potion(1)
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()


func _buy_weapon() -> void:
	if PlayerStats.weapon_damage_bonus >= WEAPON_DAMAGE_BONUS:
		push_warning("Arma ja comprada.")
		return

	if not PlayerStats.spend_coins(WEAPON_COST):
		push_warning("Moedas insuficientes para comprar arma.")
		return

	PlayerStats.equip_weapon(WEAPON_NAME, WEAPON_DAMAGE_BONUS)
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()

func _buy_resistance_collar() -> void:
	if PlayerStats.has_resistance_collar:
		push_warning("Colar da resistencia ja comprado.")
		return

	if not PlayerStats.spend_coins(RESISTANCE_COLLAR_COST):
		push_warning("Moedas insuficientes para comprar colar.")
		return

	PlayerStats.equip_resistance_collar()
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()

func _buy_iron_chestplate() -> void:
	if PlayerStats.has_iron_chestplate:
		push_warning("Peitoral de ferro ja comprado.")
		return

	if not PlayerStats.spend_coins(IRON_CHESTPLATE_COST):
		push_warning("Moedas insuficientes para comprar peitoral.")
		return

	PlayerStats.equip_iron_chestplate()
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()

func _buy_iron_pants() -> void:
	if PlayerStats.has_iron_pants:
		push_warning("Calcas de ferro ja compradas.")
		return

	if not PlayerStats.spend_coins(IRON_PANTS_COST):
		push_warning("Moedas insuficientes para comprar calcas.")
		return

	PlayerStats.equip_iron_pants()
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()

func _buy_iron_helmet() -> void:
	if PlayerStats.has_iron_helmet:
		push_warning("Elmo de ferro ja comprado.")
		return

	if not PlayerStats.spend_coins(IRON_HELMET_COST):
		push_warning("Moedas insuficientes para comprar elmo.")
		return

	PlayerStats.equip_iron_helmet()
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()

func _buy_leather_boots() -> void:
	if PlayerStats.has_leather_boots:
		push_warning("Botas de couro ja compradas.")
		return

	if not PlayerStats.spend_coins(LEATHER_BOOTS_COST):
		push_warning("Moedas insuficientes para comprar botas.")
		return

	PlayerStats.equip_leather_boots()
	_build_vendor_buttons()
	_play_buy_sound()
	GameManager.save_game()


func _play_buy_sound() -> void:
	if _buy_sfx_player == null:
		return

	_buy_sfx_player.global_position = vendor_anchor.global_position if vendor_anchor != null else global_position
	if _buy_sfx_player.playing:
		_buy_sfx_player.stop()
	_buy_sfx_player.play()
