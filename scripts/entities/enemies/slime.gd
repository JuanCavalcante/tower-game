extends "res://scripts/entities/enemies/base_enemy.gd"

const MUSHROOM_FRAME_WIDTH := 80
const MUSHROOM_FRAME_HEIGHT := 64

const MUSHROOM_ANIMATIONS := [
	{"name": "idle", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Idle.png", "frames": 7, "speed": 8.0, "loop": true},
	{"name": "run", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Run.png", "frames": 8, "speed": 10.0, "loop": true},
	{"name": "attack", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Attack.png", "frames": 10, "speed": 12.0, "loop": false},
	{"name": "attack_with_stun", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-AttackWithStun.png", "frames": 24, "speed": 12.0, "loop": false},
	{"name": "hurt", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Hit.png", "frames": 5, "speed": 12.0, "loop": false},
	{"name": "hit", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Hit.png", "frames": 5, "speed": 12.0, "loop": false},
	{"name": "stun", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Stun.png", "frames": 18, "speed": 10.0, "loop": false},
	{"name": "death", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Die.png", "frames": 15, "speed": 10.0, "loop": false},
	{"name": "die", "path": "res://assets/sprites/Mushroom with VFX/Mushroom-Die.png", "frames": 15, "speed": 10.0, "loop": false}
]

var _attack_counter: int = 0


func _ready() -> void:
	super._ready()
	anim.sprite_frames = _build_mushroom_sprite_frames()
	if anim.sprite_frames.has_animation("idle"):
		anim.play("idle")


func _build_mushroom_sprite_frames() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()

	for entry in MUSHROOM_ANIMATIONS:
		var animation_name: String = str(entry["name"])
		var texture_path: String = str(entry["path"])
		var frame_count: int = int(entry["frames"])
		var speed: float = float(entry["speed"])
		var is_looping: bool = bool(entry["loop"])

		var sheet: Texture2D = load(texture_path) as Texture2D
		if sheet == null:
			continue

		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, speed)
		frames.set_animation_loop(animation_name, is_looping)

		for frame_index in range(frame_count):
			var atlas_frame: AtlasTexture = AtlasTexture.new()
			atlas_frame.atlas = sheet
			atlas_frame.region = Rect2(
				frame_index * MUSHROOM_FRAME_WIDTH,
				0,
				MUSHROOM_FRAME_WIDTH,
				MUSHROOM_FRAME_HEIGHT
			)
			frames.add_frame(animation_name, atlas_frame)

	return frames


func attack_player() -> void:
	if not can_attack:
		return

	can_attack = false
	_attack_counter += 1

	var use_stun_attack: bool = _attack_counter % 3 == 0 and anim.sprite_frames.has_animation("attack_with_stun")
	if use_stun_attack:
		anim.play("attack_with_stun")
	else:
		anim.play("attack")

	await get_tree().create_timer(0.35, false).timeout
	if player and player.has_method("take_damage") and _can_land_attack_on(player):
		player.take_damage(damage)

	if use_stun_attack and anim.sprite_frames.has_animation("stun"):
		anim.play("stun")
		await get_tree().create_timer(0.25, false).timeout

	await get_tree().create_timer(attack_cooldown, false).timeout
	can_attack = true


func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return

	current_health -= amount
	_update_health_bar()

	knockback_velocity = _build_knockback_velocity(source_position)

	flash()

	if current_health <= 0:
		die()
	else:
		state = State.HURT
		await get_tree().create_timer(0.2, false).timeout
		state = State.IDLE


func update_animation() -> void:
	if state == State.DEAD:
		return

	if state == State.HURT:
		if anim.sprite_frames.has_animation("hurt") and anim.animation != "hurt":
			anim.play("hurt")
		return

	if state == State.ATTACK:
		if anim.animation == "attack_with_stun" or anim.animation == "stun":
			return
		if anim.sprite_frames.has_animation("attack") and anim.animation != "attack":
			anim.play("attack")
		return

	if state == State.CHASE:
		if anim.sprite_frames.has_animation("run") and anim.animation != "run":
			anim.play("run")
		return

	if anim.sprite_frames.has_animation("idle") and anim.animation != "idle":
		anim.play("idle")

func _on_damage_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player") or state == State.DEAD:
		return

	# Entering the damage area nudges the enemy to attack immediately.
	if can_attack:
		state = State.ATTACK
