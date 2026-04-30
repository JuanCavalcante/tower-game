extends "res://scripts/enemies/skeleton.gd"

const BOSS_ATTACK_HIT_PROGRESS := 0.56
const BOSS_SPECIAL_HIT_PROGRESS := 0.62
const BOSS_SPECIAL_COOLDOWN := 3.0
const BOSS_VERTICAL_TOLERANCE := 130.0
const FLOOR_10_RECOMMENDED_LEVEL := 12
const FLOOR_10_UNDERLEVEL_RESIST_PER_LEVEL := 0.04

var _attack_count := 0
var _special_on_cooldown := false

func _ready() -> void:
	max_health = 280
	damage = 22
	speed = 84.0
	knockback_force = 110.0
	knockback_immune = true
	receives_hit_knockback = false
	attack_cooldown = 0.95
	detection_range = 320.0
	attack_range = 50.0
	stop_distance = 30.0
	xp_reward = 380
	coin_reward = 80
	if GameManager.current_floor == 10:
		show_overhead_health_bar = false
	add_to_group("boss_enemy")
	super._ready()

func attack_player() -> void:
	if _is_dying or _is_hurt or _is_attacking or not can_attack:
		return

	can_attack = false
	_is_attacking = true
	_attack_count += 1

	var use_special := _attack_count % 3 == 0 and not _special_on_cooldown
	var attack_animation: StringName = &"attack2" if use_special and anim.sprite_frames.has_animation("attack2") else &"attack1"
	if not anim.sprite_frames.has_animation(attack_animation):
		attack_animation = &"attack"

	var target_cycle_duration: float = maxf(attack_cooldown, 0.08)
	var attack_started_at: int = Time.get_ticks_msec()
	var hit_progress: float = BOSS_SPECIAL_HIT_PROGRESS if use_special else BOSS_ATTACK_HIT_PROGRESS
	var hit_delay: float = _resolve_attack_hit_delay(attack_animation, target_cycle_duration, hit_progress)

	anim.play(attack_animation)

	if use_special:
		_special_on_cooldown = true
		await get_tree().create_timer(hit_delay, false).timeout
		_apply_boss_attack_damage(damage + 14)
		_start_special_cooldown.call_deferred()
	else:
		await get_tree().create_timer(hit_delay, false).timeout
		_apply_boss_attack_damage(damage)

	if anim.animation == attack_animation:
		await anim.animation_finished

	_is_attacking = false
	var elapsed_seconds: float = float(Time.get_ticks_msec() - attack_started_at) / 1000.0
	var remaining_cycle: float = maxf(target_cycle_duration - elapsed_seconds, 0.0)
	if remaining_cycle > 0.0:
		await get_tree().create_timer(remaining_cycle, false).timeout
	can_attack = true

func _resolve_attack_hit_delay(animation_name: StringName, target_cycle_duration: float, hit_progress: float) -> float:
	if anim == null or anim.sprite_frames == null:
		return target_cycle_duration * hit_progress

	if not anim.sprite_frames.has_animation(animation_name):
		return target_cycle_duration * hit_progress

	var frame_count: int = anim.sprite_frames.get_frame_count(animation_name)
	var base_speed: float = maxf(anim.sprite_frames.get_animation_speed(animation_name), 0.01)
	var base_duration: float = float(frame_count) / base_speed if frame_count > 0 else 0.0
	if base_duration <= 0.0:
		return target_cycle_duration * hit_progress

	var speed_scale: float = maxf(base_duration / target_cycle_duration, 1.0)
	anim.sprite_frames.set_animation_speed(animation_name, base_speed * speed_scale)
	var scaled_duration: float = base_duration / speed_scale
	return scaled_duration * hit_progress

func _start_special_cooldown() -> void:
	await get_tree().create_timer(BOSS_SPECIAL_COOLDOWN, false).timeout
	_special_on_cooldown = false

func _apply_boss_attack_damage(hit_damage: int) -> void:
	if _is_gameplay_paused():
		return
	if not is_instance_valid(player) or not player.has_method("take_damage"):
		return

	if _can_land_attack_on(player):
		player.take_damage(hit_damage)
		return

	# Fallback para evitar falso negativo por diferenca de tamanho entre boss e player.
	var to_player: Vector2 = player.global_position - global_position
	var in_vertical_range: bool = abs(to_player.y) <= BOSS_VERTICAL_TOLERANCE
	var in_horizontal_range: bool = abs(to_player.x) <= maxf(attack_range + 42.0, 78.0)
	var facing_sign := 1.0
	if anim != null:
		facing_sign = -1.0 if anim.flip_h == sprite_faces_right else 1.0
	var in_front: bool = to_player.x * facing_sign >= -18.0

	if in_vertical_range and in_horizontal_range and in_front:
		player.take_damage(hit_damage)


func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO) -> void:
	if _is_dying:
		return

	var incoming_damage: int = _compute_incoming_damage(amount)
	if incoming_damage <= 0:
		return

	current_health -= incoming_damage
	_update_health_bar()
	flash()

	if current_health <= 0:
		_start_death()


func _compute_incoming_damage(raw_amount: int) -> int:
	if raw_amount <= 0:
		return 0

	var adjusted_amount: int = raw_amount
	if GameManager.current_floor == 10:
		var missing_levels: int = maxi(FLOOR_10_RECOMMENDED_LEVEL - PlayerStats.level, 0)
		if missing_levels > 0:
			var level_penalty_ratio: float = clampf(float(missing_levels) * FLOOR_10_UNDERLEVEL_RESIST_PER_LEVEL, 0.0, 0.32)
			adjusted_amount = maxi(int(ceil(float(raw_amount) * (1.0 - level_penalty_ratio))), 1)

	return super._compute_incoming_damage(adjusted_amount)

func get_boss_display_name() -> String:
	return "Rei Esqueleto"

func _on_damage_area_body_entered(body) -> void:
	# Sem dano por contato: apenas habilita o estado de ataque.
	if not body.is_in_group("player") or _is_dying:
		return

	if can_attack:
		state = State.ATTACK
