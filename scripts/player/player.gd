extends CharacterBody2D

@export var speed := 200
@export var attack_damage := 30
@export var attack_range := 50
@export var gravity := 900
@export var jump_force := -400
@export var attack_cooldown := 0.5

@onready var anim = $AnimatedSprite2D

var can_attack := true
var is_attacking := false
var facing_direction := 1

func _ready():
	add_to_group("player")

func take_damage(amount):
	PlayerStats.current_health -= amount
	print("Player HP: ", PlayerStats.current_health)

	if PlayerStats.current_health <= 0:
		die()

func die():
	pass

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1

	if direction.x != 0:
		facing_direction = sign(direction.x)
		anim.flip_h = facing_direction > 0

	velocity.x = direction.x * speed

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
	
	await get_tree().create_timer(0.45).timeout

	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.has_method("take_damage"):
			continue

		var dist_sq = global_position.distance_squared_to(enemy.global_position)
		var dir_x = enemy.global_position.x - global_position.x

		if dir_x * facing_direction > 0 and dist_sq <= attack_range * attack_range:
			enemy.take_damage(attack_damage, global_position)

	await anim.animation_finished

	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
