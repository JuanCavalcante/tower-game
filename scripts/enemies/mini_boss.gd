extends "res://scripts/enemies/slime.gd"

const EFFECT_GREEN_FIRE := preload("res://assets/sprites/effect/greenfire.png")
const EFFECT_POISON := preload("res://assets/sprites/effect/poison.png")
const EFFECT_SMOKE := preload("res://assets/sprites/effect/smoke.png")

var _special_charge: int = 0
var _special_ready: bool = false
var _is_casting_special: bool = false
var _effect_sprite: Sprite2D = null


func _ready() -> void:
	max_health = 320
	speed = 95.0
	damage = 16
	knockback_force = 260.0
	attack_cooldown = 1.0
	detection_range = 300.0
	attack_range = 44.0
	stop_distance = 30.0
	xp_reward = 320
	super._ready()

	_setup_effect_sprite()
	_play_effect(EFFECT_GREEN_FIRE, Vector2(0, -35), Vector2(0.2, 0.2), Color(1, 1, 1, 0.55), 0.5)


func attack_player() -> void:
	if _is_casting_special:
		return
	if not can_attack:
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

	await get_tree().create_timer(0.35).timeout
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
		_special_charge += 1
		if _special_charge >= 4:
			_special_ready = true

	if use_stun_attack and anim.sprite_frames.has_animation("stun"):
		anim.play("stun")
		await get_tree().create_timer(0.25).timeout

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _cast_toxic_special() -> void:
	_is_casting_special = true
	state = State.ATTACK

	if anim.sprite_frames.has_animation("attack_with_stun"):
		anim.play("attack_with_stun")
	else:
		anim.play("attack")

	_play_effect(EFFECT_GREEN_FIRE, Vector2(0, -36), Vector2(0.26, 0.26), Color(1, 1, 1, 0.9), 0.55)
	await get_tree().create_timer(0.2).timeout
	_play_effect(EFFECT_POISON, Vector2(0, -15), Vector2(0.32, 0.32), Color(1, 1, 1, 0.95), 0.6)

	if player and player.has_method("take_damage"):
		var distance: float = global_position.distance_to(player.global_position)
		if distance <= detection_range * 0.9:
			player.take_damage(damage + 8)
			await get_tree().create_timer(0.2).timeout
			if player and is_instance_valid(player):
				player.take_damage(4)

	_play_effect(EFFECT_SMOKE, Vector2(0, -24), Vector2(0.25, 0.25), Color(1, 1, 1, 0.8), 0.5)
	await get_tree().create_timer(0.55).timeout

	_special_charge = 0
	_special_ready = false
	_is_casting_special = false


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
