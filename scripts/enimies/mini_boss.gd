extends CharacterBody2D

@export var speed := 120
@export var max_health := 150
@export var gravity := 900
@export var knockback_force := 100
@export var damage := 15
@export var xp_reward := 100
@onready var anim = $AnimatedSprite2D

var player = null
var current_health := 0
var can_damage = true
var knockback_velocity := Vector2.ZERO

func _ready():
	current_health = max_health
	player = get_tree().get_root().get_node("Main/Game/Player")
	add_to_group("enemies")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.1

	if player:
		var direction = (player.global_position - global_position)

		velocity.x = direction.normalized().x * speed

		if direction.x != 0:
			anim.flip_h = direction.x > 0

	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 10 * delta)

	move_and_slide()

	update_animation()

func take_damage(amount, source_position = Vector2.ZERO):
	current_health -= amount

	var direction = (global_position - source_position).normalized()
	knockback_velocity = direction * knockback_force

	flash()

	if current_health <= 0:
		await get_tree().create_timer(0.1).timeout
		die()

func flash():
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func die():
	PlayerStats.add_xp(xp_reward)

	var floor = get_parent().get_parent()
	if floor.has_method("enemy_killed"):
		floor.enemy_killed(self)

	queue_free()

func _on_damage_area_body_entered(body):
	if body.name == "Player" and can_damage:
		body.take_damage(damage)
		can_damage = false
		await get_tree().create_timer(0.8).timeout
		can_damage = true

func update_animation():
	if abs(velocity.x) > 5:
		anim.play("run")
