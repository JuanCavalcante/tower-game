extends "res://scripts/entities/enemies/base_enemy.gd"

const BASE_SKELETON_SCRIPT := "res://scripts/entities/enemies/skeleton.gd"
const SKELETON_ATTACK_HIT_DELAY := 0.28

var _is_hurt := false
var _is_dying := false
var _is_attacking := false
var _attack_index := 0
var _ignoring_player_collision := false
var _stack_escape_on_cooldown := false

func _ready() -> void:
	# Ajuste leve de agilidade para esqueletos comuns sem exagero.
	if get_script() != null and get_script().resource_path == BASE_SKELETON_SCRIPT:
		speed = max(speed, 105.0)
		if attack_cooldown >= 1.0:
			attack_cooldown = 0.82

	super._ready()
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_resolve_player_stack_state()

func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO) -> void:
	if _is_dying:
		return

	var incoming_damage: int = _compute_incoming_damage(amount)
	if incoming_damage <= 0:
		return

	current_health -= incoming_damage
	_update_health_bar()
	knockback_velocity = _build_knockback_velocity(source_position)

	if current_health <= 0:
		_start_death()
	else:
		_start_hurt()

func attack_player() -> void:
	if _is_dying or _is_hurt or _is_attacking or not can_attack:
		return

	can_attack = false
	_is_attacking = true
	_attack_index = (_attack_index + 1) % 2

	var attack_animation: StringName = &"attack1" if _attack_index == 0 else &"attack2"
	if not anim.sprite_frames.has_animation(attack_animation):
		attack_animation = &"attack"

	anim.play(attack_animation)

	await get_tree().create_timer(SKELETON_ATTACK_HIT_DELAY, false).timeout
	_apply_attack_damage(damage)

	if anim.animation == attack_animation:
		await anim.animation_finished

	_is_attacking = false
	await get_tree().create_timer(attack_cooldown, false).timeout
	can_attack = true

func _apply_attack_damage(hit_damage: int) -> void:
	if not is_instance_valid(player) or not player.has_method("take_damage"):
		return

	if _can_land_attack_on(player):
		player.take_damage(hit_damage)

func _start_hurt() -> void:
	if _is_hurt or _is_dying:
		return
	_is_hurt = true
	flash()
	anim.play("hurt")

func _start_death() -> void:
	_is_dying = true
	state = State.DEAD
	can_attack = false
	can_damage = false
	velocity = Vector2.ZERO
	_disable_collision_for_death()
	set_physics_process(false)
	anim.play("die")
	_stop_player_collision_bypass()

func _on_animation_finished() -> void:
	match anim.animation:
		"hurt":
			_is_hurt = false
		"die":
			die()

func update_animation() -> void:
	if _is_dying or _is_hurt or _is_attacking:
		return

	if abs(velocity.x) > 5:
		anim.play("walk")
	else:
		anim.play("idle")

func _on_damage_area_body_entered(body: Node) -> void:
	# Sem dano por contato: apenas sinaliza oportunidade de ataque.
	if not body.is_in_group("player") or _is_dying:
		return

	if can_attack:
		state = State.ATTACK

func _resolve_player_stack_state() -> void:
	if _is_dying or state == State.DEAD:
		_stop_player_collision_bypass()
		return
	if player == null or not is_instance_valid(player):
		_stop_player_collision_bypass()
		return

	var delta_to_player: Vector2 = player.global_position - global_position
	var player_is_below: bool = delta_to_player.y >= 10.0
	var x_overlap: bool = abs(delta_to_player.x) <= 22.0
	var mostly_stacked: bool = abs(velocity.y) <= 38.0
	var should_escape: bool = player_is_below and x_overlap and mostly_stacked

	if should_escape:
		_start_player_collision_bypass()
		if not _stack_escape_on_cooldown:
			_stack_escape_on_cooldown = true
			var escape_direction: float = -sign(delta_to_player.x)
			if abs(escape_direction) < 0.001:
				escape_direction = -1.0 if randi() % 2 == 0 else 1.0

			velocity.x = escape_direction * speed * 1.22
			if is_on_floor():
				velocity.y = -110.0
			_finish_stack_escape_cooldown.call_deferred()
		return

	if _ignoring_player_collision:
		var safe_x_gap: bool = abs(delta_to_player.x) > 38.0
		var player_not_below: bool = delta_to_player.y < 6.0
		if safe_x_gap or player_not_below:
			_stop_player_collision_bypass()

func _finish_stack_escape_cooldown() -> void:
	await get_tree().create_timer(0.55, false).timeout
	_stack_escape_on_cooldown = false

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
