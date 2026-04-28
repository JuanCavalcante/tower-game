extends "res://scripts/enemies/skeleton.gd"

const BOSS_ATTACK_HIT_DELAY := 0.30
const BOSS_SPECIAL_HIT_DELAY := 0.26
const BOSS_SPECIAL_COOLDOWN := 3.0
const BOSS_VERTICAL_TOLERANCE := 130.0

var _attack_count := 0
var _special_on_cooldown := false

func _ready() -> void:
	max_health = 280
	damage = 22
	speed = 84.0
	knockback_force = 110.0
	knockback_immune = true
	attack_cooldown = 0.95
	detection_range = 320.0
	attack_range = 50.0
	stop_distance = 30.0
	xp_reward = 380
	coin_reward = 80
	super._ready()

func attack_player() -> void:
	if _is_dying or _is_hurt or _is_attacking or not can_attack:
		return

	can_attack = false
	_is_attacking = true
	_attack_count += 1

	var use_special := _attack_count % 3 == 0 and not _special_on_cooldown
	var attack_animation := "attack2" if use_special and anim.sprite_frames.has_animation("attack2") else "attack1"
	if not anim.sprite_frames.has_animation(attack_animation):
		attack_animation = "attack"

	anim.play(attack_animation)

	if use_special:
		_special_on_cooldown = true
		await get_tree().create_timer(BOSS_SPECIAL_HIT_DELAY).timeout
		_apply_boss_attack_damage(damage + 10)
		_start_special_cooldown.call_deferred()
	else:
		await get_tree().create_timer(BOSS_ATTACK_HIT_DELAY).timeout
		_apply_boss_attack_damage(damage)

	if anim.animation == attack_animation:
		await anim.animation_finished

	_is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _start_special_cooldown() -> void:
	await get_tree().create_timer(BOSS_SPECIAL_COOLDOWN).timeout
	_special_on_cooldown = false

func _apply_boss_attack_damage(hit_damage: int) -> void:
	if _is_gameplay_paused():
		return
	if not is_instance_valid(player) or not player.has_method("take_damage"):
		return

	if _can_land_attack_on(player):
		player.take_damage(hit_damage)
		return

	# Fallback para evitar falso negativo por diferença de tamanho entre boss e player.
	var to_player: Vector2 = player.global_position - global_position
	var in_vertical_range: bool = abs(to_player.y) <= BOSS_VERTICAL_TOLERANCE
	var in_horizontal_range: bool = abs(to_player.x) <= maxf(attack_range + 42.0, 78.0)
	var facing_sign := 1.0
	if anim != null:
		facing_sign = -1.0 if anim.flip_h == sprite_faces_right else 1.0
	var in_front: bool = to_player.x * facing_sign >= -18.0

	if in_vertical_range and in_horizontal_range and in_front:
		player.take_damage(hit_damage)

func _on_damage_area_body_entered(body) -> void:
	# Sem dano por contato: apenas habilita o estado de ataque.
	if not body.is_in_group("player") or _is_dying:
		return

	if can_attack:
		state = State.ATTACK
