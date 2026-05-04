extends CharacterBody2D
signal death_sequence_finished

const SWORD_SFX_1 := preload("res://assets/sprites/effect/sound/sword1.mp3")
const SWORD_SFX_2 := preload("res://assets/sprites/effect/sound/sword2.mp3")
const ATTACK_HIT_PROGRESS := 0.6
const DAMAGE_INDICATOR_OFFSET := Vector2(-18, -54)
const DAMAGE_INDICATOR_RISE := Vector2(0, -28)
const DAMAGE_INDICATOR_DURATION := 0.7
const HEAL_INDICATOR_OFFSET := Vector2(-18, -70)
const HEAL_INDICATOR_RISE := Vector2(0, -24)
const HEAL_INDICATOR_DURATION := 0.8
@export var speed := 100
@export var attack_damage := 10
@export var attack_range := 50
@export var attack_vertical_tolerance := 58
@export var gravity := 900
@export var jump_force := -400
@export var attack_cooldown := 1.0
@export var run_speed_threshold := 130.0
@export var acceleration := 900.0
@export var deceleration := 1200.0
@export var dash_speed := 430.0
@export var dash_duration := 0.17
@export var dash_cooldown := 0.65
@export var block_move_speed_multiplier := 0.45
@export var sprite_ground_offset_y := 9.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var can_attack := true
var is_attacking := false
var facing_direction := 1
var is_dead := false
var is_dashing := false
var is_blocking := false
var dash_direction := 1
var dash_time_left := 0.0
var dash_cooldown_left := 0.0
var _shift_was_pressed := false
var _sword_sfx_player: AudioStreamPlayer2D = null

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("player")
	anim.offset = Vector2(anim.offset.x, sprite_ground_offset_y)
	_sword_sfx_player = AudioStreamPlayer2D.new()
	_sword_sfx_player.name = "SwordSfx"
	_sword_sfx_player.volume_db = -7.0
	add_child(_sword_sfx_player)
	_apply_generated_player_frames()
	_ensure_death_animation()


func _apply_generated_player_frames() -> void:
	if anim == null:
		return

	var frames := SpriteFrames.new()
	_add_animation_from_folder(frames, "idle", "idle", true, 7.0)
	_add_animation_from_folder(frames, "walk", "walk", false, 10.0)
	_add_animation_from_folder(frames, "run", "run", false, 14.0)
	_add_animation_from_folder(frames, "dash", "dash", false, 16.0)
	_add_animation_from_folder(frames, "attack", "attack", false, 9.0)
	_add_animation_from_folder(frames, "block", "block", false, 8.0)
	_add_animation_from_folder(frames, "jump", "jump", false, 10.0)

	if frames.has_animation("idle"):
		anim.sprite_frames = frames
		anim.play("idle")


func _add_animation_from_folder(
	frames: SpriteFrames,
	animation_name: String,
	frame_prefix: String,
	loop: bool,
	speed_value: float
) -> void:
	var loaded_any := false
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, loop)
	frames.set_animation_speed(animation_name, speed_value)

	var animation_folder := "res://assets/sprites/player/generated/%s" % frame_prefix
	var folder := DirAccess.open(animation_folder)
	if folder == null:
		frames.remove_animation(animation_name)
		return

	var file_names: PackedStringArray = folder.get_files()
	file_names.sort()
	var expected_prefix := "%s_" % frame_prefix
	for file_name in file_names:
		if not file_name.ends_with(".png"):
			continue
		if not file_name.begins_with(expected_prefix):
			continue
		var texture_path := "%s/%s" % [animation_folder, file_name]
		if not ResourceLoader.exists(texture_path):
			continue
		var frame_texture = load(texture_path)
		if frame_texture is Texture2D:
			frames.add_frame(animation_name, frame_texture, 1.0)
			loaded_any = true

	if not loaded_any:
		frames.remove_animation(animation_name)


func _ensure_death_animation() -> void:
	if anim == null or anim.sprite_frames == null:
		return
	if anim.sprite_frames.has_animation("die"):
		return
	var source_animation := "jump"
	if not anim.sprite_frames.has_animation(source_animation):
		source_animation = "idle"
	if not anim.sprite_frames.has_animation(source_animation):
		return

	var source_frame_count: int = anim.sprite_frames.get_frame_count(source_animation)
	if source_frame_count <= 0:
		return

	anim.sprite_frames.add_animation("die")
	anim.sprite_frames.set_animation_loop("die", false)
	anim.sprite_frames.set_animation_speed("die", 7.0)

	var start_index := maxi(source_frame_count - 4, 0)
	for frame_index in range(start_index, source_frame_count):
		var frame_texture: Texture2D = anim.sprite_frames.get_frame_texture(source_animation, frame_index)
		anim.sprite_frames.add_frame("die", frame_texture, 1.0)


func _play_sword_sfx_start() -> void:
	if _sword_sfx_player == null:
		return

	if _sword_sfx_player.playing:
		_sword_sfx_player.stop()
	_sword_sfx_player.stream = SWORD_SFX_1
	_sword_sfx_player.play()


func _play_sword_sfx_end() -> void:
	if _sword_sfx_player == null:
		return

	if _sword_sfx_player.playing:
		_sword_sfx_player.stop()
	_sword_sfx_player.stream = SWORD_SFX_2
	_sword_sfx_player.play()

func take_damage(amount):
	if GameManager.is_dev_mode:
		return

	if is_dead:
		return
	if is_blocking:
		_show_floating_indicator(
			"BLOCK",
			Color(0.4, 0.8, 1.0, 1.0),
			DAMAGE_INDICATOR_OFFSET,
			DAMAGE_INDICATOR_RISE,
			0.45
		)
		return

	var previous_health: int = PlayerStats.current_health
	var damage_to_apply: int = PlayerStats.get_incoming_damage(int(amount))
	if damage_to_apply <= 0:
		return
	PlayerStats.take_damage(damage_to_apply)
	var damage_taken: int = max(previous_health - PlayerStats.current_health, 0)
	if damage_taken > 0:
		_show_damage_indicator(damage_taken)
	print("Player HP: ", PlayerStats.current_health)

	if PlayerStats.current_health <= 0:
		await die()

func _show_damage_indicator(damage_taken: int) -> void:
	_show_floating_indicator(
		"-%d" % damage_taken,
		Color(1.0, 0.18, 0.12, 1.0),
		DAMAGE_INDICATOR_OFFSET,
		DAMAGE_INDICATOR_RISE,
		DAMAGE_INDICATOR_DURATION
	)

func _show_heal_indicator(heal_received: int) -> void:
	_show_floating_indicator(
		"+%d" % heal_received,
		Color(0.25, 1.0, 0.42, 1.0),
		HEAL_INDICATOR_OFFSET,
		HEAL_INDICATOR_RISE,
		HEAL_INDICATOR_DURATION
	)

func _show_floating_indicator(text: String, color: Color, offset: Vector2, rise: Vector2, duration: float) -> void:
	var indicator_label := Label.new()
	indicator_label.text = text
	indicator_label.z_index = 20
	indicator_label.position = offset
	indicator_label.modulate = color
	indicator_label.add_theme_color_override("font_color", color)
	indicator_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	indicator_label.add_theme_constant_override("outline_size", 4)
	indicator_label.add_theme_font_size_override("font_size", 18)
	add_child(indicator_label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(indicator_label, "position", offset + rise, duration)
	tween.tween_property(indicator_label, "modulate:a", 0.0, duration)
	tween.finished.connect(indicator_label.queue_free)

func die():
	if is_dead:
		return

	is_dead = true
	can_attack = false
	is_attacking = false
	is_dashing = false
	is_blocking = false
	velocity = Vector2.ZERO
	set_physics_process(false)

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("die"):
		anim.play("die")
		await anim.animation_finished
	else:
		await get_tree().create_timer(0.2, false).timeout

	death_sequence_finished.emit()

func respawn_to_hub() -> void:
	if not is_dead:
		return

	PlayerStats.refill_health()
	GameManager.return_to_hub()
	is_dead = false
	is_dashing = false
	is_blocking = false
	dash_cooldown_left = 0.0
	set_physics_process(true)
	can_attack = true

func _physics_process(delta):
	if is_dead:
		return
	dash_cooldown_left = max(dash_cooldown_left - delta, 0.0)

	var direction_x := 0.0

	if Input.is_action_just_pressed("use_potion"):
		var previous_health: int = PlayerStats.current_health
		if PlayerStats.use_potion(40):
			var heal_received: int = max(PlayerStats.current_health - previous_health, 0)
			if heal_received > 0:
				_show_heal_indicator(heal_received)
			print("Pocao usada. HP: ", PlayerStats.current_health, "/", PlayerStats.max_health)
		else:
			print("Sem pocao ou HP ja cheio.")

	if Input.is_action_pressed("right"):
		direction_x += 1
	if Input.is_action_pressed("left"):
		direction_x -= 1

	var shift_pressed := Input.is_key_pressed(KEY_SHIFT)
	var dash_just_pressed := shift_pressed and not _shift_was_pressed
	_shift_was_pressed = shift_pressed

	if direction_x != 0:
		facing_direction = int(sign(direction_x))
		anim.flip_h = facing_direction < 0

	is_blocking = not is_attacking and not is_dashing and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and is_on_floor()

	if dash_just_pressed and not is_attacking and not is_blocking and not is_dashing and dash_cooldown_left <= 0.0:
		is_dashing = true
		dash_direction = facing_direction
		if direction_x != 0:
			dash_direction = int(sign(direction_x))
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown

	if Input.is_action_just_pressed("attack") and can_attack and not is_blocking and not is_dashing:
		attack()

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dashing:
		velocity.y = jump_force

	if is_dashing:
		velocity.x = float(dash_direction) * dash_speed
		dash_time_left -= delta
		if dash_time_left <= 0.0:
			is_dashing = false
	else:
		var current_move_speed := PlayerStats.get_move_speed(float(speed))
		if is_blocking:
			current_move_speed *= block_move_speed_multiplier
		var target_velocity_x := direction_x * current_move_speed
		var blend_rate := acceleration if absf(direction_x) > 0.0 else deceleration
		velocity.x = move_toward(velocity.x, target_velocity_x, blend_rate * delta)

	velocity.y += gravity * delta

	if is_on_floor() and velocity.y > 0:
		velocity.y = 0

	move_and_slide()

	update_animation()

func update_animation():
	if is_attacking:
		return
	if is_dashing:
		_play_animation_state("dash", false)
		return
	if is_blocking:
		_play_animation_state("block", false)
		return

	if not is_on_floor():
		if anim.sprite_frames != null and anim.sprite_frames.has_animation("jump"):
			_play_animation_state("jump", false)
		else:
			_play_animation_state("idle", false)
		return

	var move_speed_abs: float = absf(velocity.x)
	if move_speed_abs <= 1.0:
		_play_animation_state("idle", false)
	elif move_speed_abs >= run_speed_threshold and anim.sprite_frames != null and anim.sprite_frames.has_animation("run"):
		_play_animation_state("run", true)
	elif anim.sprite_frames != null and anim.sprite_frames.has_animation("walk"):
		_play_animation_state("walk", true)
	else:
		_play_animation_state("idle", false)

func _play_animation_state(animation_name: StringName, restart_when_finished: bool) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	if not anim.sprite_frames.has_animation(animation_name):
		return
	if anim.animation != animation_name:
		anim.play(animation_name)
		return
	if restart_when_finished and not anim.is_playing():
		anim.play(animation_name)

func attack():
	can_attack = false
	is_attacking = true
	var attack_start_time: int = Time.get_ticks_msec()
	var attacks_per_second: float = PlayerStats.get_attack_speed_from_cooldown(float(attack_cooldown))
	var target_cycle_duration: float = 1.0 / attacks_per_second

	var attack_frame_count: int = 0
	var base_attack_anim_speed: float = 8.0
	if anim != null and anim.sprite_frames != null and anim.sprite_frames.has_animation("attack"):
		attack_frame_count = anim.sprite_frames.get_frame_count("attack")
		base_attack_anim_speed = max(anim.sprite_frames.get_animation_speed("attack"), 0.01)

	var base_attack_anim_duration: float = 0.0
	if attack_frame_count > 0:
		base_attack_anim_duration = float(attack_frame_count) / base_attack_anim_speed

	if base_attack_anim_duration > 0.0:
		var speed_scale: float = max(base_attack_anim_duration / target_cycle_duration, 1.0)
		anim.sprite_frames.set_animation_speed("attack", base_attack_anim_speed * speed_scale)
	else:
		anim.sprite_frames.set_animation_speed("attack", base_attack_anim_speed)

	anim.play("attack")
	_play_sword_sfx_start()
	
	var current_anim_speed: float = max(anim.sprite_frames.get_animation_speed("attack"), 0.01)
	var current_anim_duration: float = 0.0
	if attack_frame_count > 0:
		current_anim_duration = float(attack_frame_count) / current_anim_speed

	var hit_delay: float = 0.45
	if current_anim_duration > 0.0:
		hit_delay = current_anim_duration * ATTACK_HIT_PROGRESS

	await get_tree().create_timer(hit_delay, false).timeout

	var enemies = get_tree().get_nodes_in_group("enemies")
	var effective_attack_range: float = float(attack_range) + 8.0
	var effective_range_sq: float = effective_attack_range * effective_attack_range

	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.has_method("take_damage"):
			continue

		var to_enemy: Vector2 = enemy.global_position - global_position
		var dist_sq: float = to_enemy.length_squared()
		if abs(to_enemy.y) > float(attack_vertical_tolerance):
			continue

		var is_in_front: bool = to_enemy.x * facing_direction >= -6.0
		if is_in_front and dist_sq <= effective_range_sq:
			if not GameManager.is_dev_mode:
				var hit_roll: int = randi_range(1, 100)
				if hit_roll > PlayerStats.get_hit_chance_percent():
					continue
			var damage_to_apply: int = 999999 if GameManager.is_dev_mode else PlayerStats.get_total_damage(attack_damage)
			enemy.take_damage(damage_to_apply, global_position)

	_play_sword_sfx_end()

	await anim.animation_finished

	is_attacking = false

	var elapsed_seconds: float = float(Time.get_ticks_msec() - attack_start_time) / 1000.0
	var remaining_cycle: float = max(target_cycle_duration - elapsed_seconds, 0.0)
	if remaining_cycle > 0.0:
		await get_tree().create_timer(remaining_cycle, false).timeout
	can_attack = true
