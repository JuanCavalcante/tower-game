extends CharacterBody2D
signal death_sequence_finished

const SWORD_SFX_1 := preload("res://assets/sprites/effect/sound/sword1.mp3")
const SWORD_SFX_2 := preload("res://assets/sprites/effect/sound/sword2.mp3")

@export var speed := 200
@export var attack_damage := 10
@export var attack_range := 50
@export var attack_vertical_tolerance := 58
@export var gravity := 900
@export var jump_force := -400
@export var attack_cooldown := 0.5

@onready var anim = $AnimatedSprite2D

var can_attack := true
var is_attacking := false
var facing_direction := 1
var is_dead := false
var _sword_sfx_player: AudioStreamPlayer2D = null

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("player")
	_sword_sfx_player = AudioStreamPlayer2D.new()
	_sword_sfx_player.name = "SwordSfx"
	_sword_sfx_player.volume_db = -7.0
	add_child(_sword_sfx_player)
	_ensure_death_animation()


func _ensure_death_animation() -> void:
	if anim == null or anim.sprite_frames == null:
		return
	if anim.sprite_frames.has_animation("die"):
		return
	if not anim.sprite_frames.has_animation("jump"):
		return

	var jump_frame_count: int = anim.sprite_frames.get_frame_count("jump")
	if jump_frame_count <= 0:
		return

	anim.sprite_frames.add_animation("die")
	anim.sprite_frames.set_animation_loop("die", false)
	anim.sprite_frames.set_animation_speed("die", 7.0)

	var start_index := maxi(jump_frame_count - 4, 0)
	for frame_index in range(start_index, jump_frame_count):
		var frame_texture: Texture2D = anim.sprite_frames.get_frame_texture("jump", frame_index)
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

	PlayerStats.current_health -= amount
	PlayerStats.current_health = max(PlayerStats.current_health, 0)
	print("Player HP: ", PlayerStats.current_health)

	if PlayerStats.current_health <= 0:
		await die()

func die():
	if is_dead:
		return

	is_dead = true
	can_attack = false
	is_attacking = false
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

	PlayerStats.current_health = PlayerStats.max_health
	GameManager.return_to_hub()
	is_dead = false
	set_physics_process(true)
	can_attack = true

func _physics_process(delta):
	if is_dead:
		return

	var direction = Vector2.ZERO

	if Input.is_action_just_pressed("use_potion"):
		if PlayerStats.use_potion(40):
			print("Pocao usada. HP: ", PlayerStats.current_health, "/", PlayerStats.max_health)
		else:
			print("Sem pocao ou HP ja cheio.")

	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1

	if direction.x != 0:
		facing_direction = sign(direction.x)
		anim.flip_h = facing_direction > 0

	velocity.x = direction.x * PlayerStats.get_move_speed(float(speed))

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	velocity.y += gravity * delta

	if is_on_floor() and velocity.y > 0:
		velocity.y = 0

	move_and_slide()

	update_animation()

func update_animation():
	if is_attacking:
		return

	if not is_on_floor():
		anim.play("jump")
	elif velocity.x != 0:
		anim.play("walk")
	else:
		anim.play("idle")

func attack():
	can_attack = false
	is_attacking = true

	anim.play("attack")
	_play_sword_sfx_start()
	
	await get_tree().create_timer(0.45, false).timeout

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

	var dynamic_cooldown: float = PlayerStats.get_attack_cooldown(float(attack_cooldown))
	await get_tree().create_timer(dynamic_cooldown, false).timeout
	can_attack = true
