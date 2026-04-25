extends CharacterBody2D
class_name BaseEnemy

@export var speed := 100
@export var max_health := 30
@export var gravity := 900
@export var knockback_force := 200
@export var xp_reward := 20

@onready var anim = $AnimatedSprite2D

var player: Node2D = null
var current_health := 0
var can_damage := true
var knockback_velocity := Vector2.ZERO

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.1

	if is_instance_valid(player):
		var dir_x := player.global_position.x - global_position.x
		velocity.x = sign(dir_x) * speed
		if dir_x != 0.0:
			anim.flip_h = dir_x > 0

	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 10.0 * delta)
	move_and_slide()
	update_animation()

func flash():
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func die():
	PlayerStats.add_xp(xp_reward)
	var floor_node = _find_floor_node()
	if floor_node:
		floor_node.enemy_killed(self)
	queue_free()

func _find_floor_node():
	var node = get_parent()
	while node:
		if node.has_method("enemy_killed"):
			return node
		node = node.get_parent()
	return null

func update_animation():
	if abs(velocity.x) > 5:
		anim.play("run")
	else:
		anim.play("idle")
