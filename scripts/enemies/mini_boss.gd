extends "res://scripts/enemies/slime.gd"

const EFFECT_GREEN_FIRE := preload("res://assets/sprites/effect/greenfire.png")
const EFFECT_POISON := preload("res://assets/sprites/effect/poison.png")
const EFFECT_SMOKE := preload("res://assets/sprites/effect/smoke.png")

var _special_charge: int = 0
var _special_ready: bool = false
var _is_casting_special: bool = false
var _stomp_on_cooldown: bool = false
var _ignoring_player_collision: bool = false
var _effect_sprite: Sprite2D = null


func _ready() -> void:
	max_health = 320
	speed = 95.0
	damage = 16
	knockback_force = 260.0
	knockback_immune = true
	attack_cooldown = 1.0
	detection_range = 300.0
	attack_range = 44.0
	stop_distance = 30.0
	xp_reward = 320
	coin_reward = 45
	super._ready()

	_setup_effect_sprite()
	_play_effect(EFFECT_GREEN_FIRE, Vector2(0, -35), Vector2(0.2, 0.2), Color(1, 1, 1, 0.55), 0.5)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state == State.DEAD:
		if _ignoring_player_collision:
			_stop_player_collision_bypass()
		return
	_resolve_head_lock_state()


func attack_player() -> void:
	if _is_gameplay_paused():
		return
	if _is_casting_special:
		return
	if not can_attack:
		return
	if _should_trigger_stomp_special():
		can_attack = false
		await _cast_stomp_special()
		await get_tree().create_timer(attack_cooldown * 0.8, false).timeout
		can_attack = true
		return

	can_attack = false

	if _special_ready:
		await _cast_toxic_special()
		can_attack = true
		return

	_attack_counter += 1
	var use_stun_attack: bool = _attack_counter % 3 == 0 and anim.sprite_frames.has_animation("attack_with_stun")
	if use_stun_attack:
		anim.play("attack_with_stun")
	else:
		anim.play("attack")

	await get_tree().create_timer(0.35, false).timeout
	if player and player.has_method("take_damage") and _can_land_attack_on(player):
		player.take_damage(damage)
		_special_charge += 1
		if _special_charge >= 4:
			_special_ready = true

	if use_stun_attack and anim.sprite_frames.has_animation("stun"):
		anim.play("stun")
		await get_tree().create_timer(0.25, false).timeout

	await get_tree().create_timer(attack_cooldown, false).timeout
	can_attack = true


func _should_trigger_stomp_special() -> bool:
	if state == State.DEAD:
		return false
	if _stomp_on_cooldown or _is_casting_special:
		return false
	if player == null or not is_instance_valid(player):
		return false

	var delta_to_player: Vector2 = player.global_position - global_position
	var is_player_below: bool = delta_to_player.y >= 12.0
	var is_x_aligned: bool = abs(delta_to_player.x) <= 26.0
	var is_close_enough: bool = delta_to_player.length_squared() <= 44.0 * 44.0

	return is_player_below and is_x_aligned and is_close_enough


func _cast_stomp_special() -> void:
	if state == State.DEAD:
		return
	_is_casting_special = true
	_stomp_on_cooldown = true
	state = State.ATTACK

	if anim.sprite_frames.has_animation("attack_with_stun"):
		anim.play("attack_with_stun")
	elif anim.sprite_frames.has_animation("attack"):
		anim.play("attack")

	_play_effect(EFFECT_SMOKE, Vector2(0, -8), Vector2(0.42, 0.42), Color(1, 1, 1, 0.95), 0.42)
	await get_tree().create_timer(0.12, false).timeout
	if state == State.DEAD:
		return
	_play_effect(EFFECT_GREEN_FIRE, Vector2(0, -22), Vector2(0.28, 0.28), Color(1, 1, 1, 0.85), 0.35)

	if player and is_instance_valid(player) and player.has_method("take_damage") and not _is_gameplay_paused():
		player.take_damage(damage + 6)

	await get_tree().create_timer(0.25, false).timeout
	if state == State.DEAD:
		return
	_is_casting_special = false

	await get_tree().create_timer(1.3, false).timeout
	_stomp_on_cooldown = false


func _resolve_head_lock_state() -> void:
	if state == State.DEAD:
		return
	if player == null or not is_instance_valid(player):
		return

	var delta_to_player: Vector2 = player.global_position - global_position
	var player_is_below: bool = delta_to_player.y >= 12.0
	var x_overlap: bool = abs(delta_to_player.x) <= 24.0
	var mostly_stacked: bool = abs(velocity.y) <= 36.0

	if player_is_below and x_overlap and mostly_stacked:
		_start_player_collision_bypass()
		var escape_direction: float = -sign(delta_to_player.x)
		if abs(escape_direction) < 0.001:
			escape_direction = -1.0 if randi() % 2 == 0 else 1.0

		velocity.x = escape_direction * speed * 1.35
		if is_on_floor():
			velocity.y = -120.0
		if not _is_casting_special and not _stomp_on_cooldown:
			_stomp_on_cooldown = true
			_cast_stomp_special.call_deferred()
		return

	if _ignoring_player_collision:
		var safe_x_gap: bool = abs(delta_to_player.x) > 40.0
		var player_not_below: bool = delta_to_player.y < 8.0
		if safe_x_gap or player_not_below:
			_stop_player_collision_bypass()


func _start_player_collision_bypass() -> void:
	if _ignoring_player_collision:
		return
	if player == null or not is_instance_valid(player):
		return
	add_collision_exception_with(player)
	_ignoring_player_collision = true


func _stop_player_collision_bypass() -> void:
	if not _ignoring_player_collision:
		return
	if player != null and is_instance_valid(player):
		remove_collision_exception_with(player)
	_ignoring_player_collision = false


func _cast_toxic_special() -> void:
	if state == State.DEAD:
		return
	_is_casting_special = true
	state = State.ATTACK

	if anim.sprite_frames.has_animation("attack_with_stun"):
		anim.play("attack_with_stun")
	else:
		anim.play("attack")

	_play_effect(EFFECT_GREEN_FIRE, Vector2(0, -36), Vector2(0.26, 0.26), Color(1, 1, 1, 0.9), 0.55)
	await get_tree().create_timer(0.2, false).timeout
	if state == State.DEAD:
		return
	_play_effect(EFFECT_POISON, Vector2(0, -15), Vector2(0.32, 0.32), Color(1, 1, 1, 0.95), 0.6)

	if player and player.has_method("take_damage") and not _is_gameplay_paused():
		var distance: float = global_position.distance_to(player.global_position)
		if distance <= detection_range * 0.9:
			player.take_damage(damage + 8)
			await get_tree().create_timer(0.2, false).timeout
			if player and is_instance_valid(player) and not _is_gameplay_paused():
				player.take_damage(4)

	_play_effect(EFFECT_SMOKE, Vector2(0, -24), Vector2(0.25, 0.25), Color(1, 1, 1, 0.8), 0.5)
	await get_tree().create_timer(0.55, false).timeout
	if state == State.DEAD:
		return

	_special_charge = 0
	_special_ready = false
	_is_casting_special = false


func die() -> void:
	if state == State.DEAD:
		return

	_is_casting_special = false
	_stomp_on_cooldown = false
	can_attack = false
	velocity = Vector2.ZERO
	_stop_player_collision_bypass()
	super.die()


func _setup_effect_sprite() -> void:
	_effect_sprite = Sprite2D.new()
	_effect_sprite.name = "BossEffect"
	_effect_sprite.centered = true
	_effect_sprite.z_index = 12
	_effect_sprite.visible = false
	add_child(_effect_sprite)


func _play_effect(texture: Texture2D, offset: Vector2, target_scale: Vector2, tint: Color, duration: float) -> void:
	if _effect_sprite == null or texture == null:
		return

	_effect_sprite.texture = texture
	_effect_sprite.position = offset
	_effect_sprite.scale = target_scale * 0.65
	_effect_sprite.modulate = Color(tint.r, tint.g, tint.b, 0.0)
	_effect_sprite.visible = true

	var tween: Tween = create_tween()
	tween.tween_property(_effect_sprite, "modulate:a", tint.a, duration * 0.25)
	tween.parallel().tween_property(_effect_sprite, "scale", target_scale, duration * 0.55)
	tween.tween_property(_effect_sprite, "modulate:a", 0.0, duration * 0.45)
	tween.finished.connect(func() -> void:
		if _effect_sprite:
			_effect_sprite.visible = false
	)
