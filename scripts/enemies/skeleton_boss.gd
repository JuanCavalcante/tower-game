extends "res://scripts/enemies/skeleton.gd"

const EFFECT_FIRE := preload("res://assets/sprites/effect/fire.png")
const EFFECT_SMOKE := preload("res://assets/sprites/effect/smoke.png")
const EFFECT_THUNDER := preload("res://assets/sprites/effect/thunder.png")

var _attack_count: int = 0
var _special_on_cooldown: bool = false
var _effect_sprite: Sprite2D = null


func _ready() -> void:
	max_health = 280
	damage = 22
	speed = 78.0
	knockback_force = 110.0
	attack_cooldown = 1.1
	detection_range = 320.0
	attack_range = 46.0
	stop_distance = 30.0
	xp_reward = 380
	coin_reward = 80
	super._ready()

	_setup_effect_sprite()
	_play_effect(EFFECT_FIRE, Vector2(0, -44), Vector2(0.22, 0.22), Color(1, 1, 1, 0.5), 0.5)


func _on_damage_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player") or not can_damage or _is_dying:
		return

	body.take_damage(damage)
	can_damage = false
	_attack_count += 1

	if _attack_count % 3 == 0 and not _special_on_cooldown:
		await _cast_thunder_special(body)
		await get_tree().create_timer(attack_cooldown + 0.2).timeout
		can_damage = true
		return

	if not _is_hurt and not _is_attacking:
		_is_attacking = true
		anim.play("attack2" if _attack_count % 3 == 0 else "attack1")
	await get_tree().create_timer(1.3).timeout
	can_damage = true


func _cast_thunder_special(body: Node) -> void:
	_special_on_cooldown = true
	_is_attacking = true

	if anim.sprite_frames.has_animation("attack2"):
		anim.play("attack2")

	_play_effect(EFFECT_THUNDER, Vector2(0, -56), Vector2(0.46, 0.46), Color(1, 1, 1, 0.95), 0.45)
	await get_tree().create_timer(0.2).timeout
	_play_effect(EFFECT_SMOKE, Vector2(0, -28), Vector2(0.22, 0.22), Color(1, 1, 1, 0.85), 0.6)

	if body and is_instance_valid(body) and body.has_method("take_damage"):
		body.take_damage(damage + 10)

	await get_tree().create_timer(0.4).timeout
	_is_attacking = false

	await get_tree().create_timer(3.0).timeout
	_special_on_cooldown = false


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
	tween.parallel().tween_property(_effect_sprite, "scale", target_scale, duration * 0.6)
	tween.tween_property(_effect_sprite, "modulate:a", 0.0, duration * 0.45)
	tween.finished.connect(func() -> void:
		if _effect_sprite:
			_effect_sprite.visible = false
	)
