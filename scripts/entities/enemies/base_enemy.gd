extends CharacterBody2D
class_name BaseEnemy

const COIN_SCENE := preload("res://scenes/items/coin.tscn")
const BASE_ATTACK_HIT_DELAY := 0.22

enum State {
	IDLE,
	CHASE,
	ATTACK,
	HURT,
	DEAD
}

@export var speed := 100.0
@export var max_health := 30
@export var gravity := 900.0
@export var knockback_force := 200.0
@export var knockback_immune := false
@export var receives_hit_knockback := true
@export var xp_reward := 20
@export var coin_reward := 3
@export var sprite_faces_right := false

@export var detection_range := 220.0
@export var attack_range := 35.0
@export var stop_distance := 24.0
@export var attack_cooldown := 1.0
@export var damage := 10
@export var spawn_patrol_steps_min := 10
@export var spawn_patrol_steps_max := 15
@export var spawn_patrol_step_distance := 14.0
@export var spawn_patrol_speed_scale := 0.8
@export var separation_radius := 42.0
@export var separation_strength := 0.65
@export var health_bar_width := 34.0
@export var health_bar_height := 5.0
@export var health_bar_offset_y := 10.0
@export var show_overhead_health_bar := true
@export_range(0.0, 0.95, 0.01) var damage_reduction_ratio := 0.0
@export var damage_reduction_flat := 0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D = null
var current_health := 0
var state: State = State.IDLE

var can_attack := true
var can_damage := true
var knockback_velocity := Vector2.ZERO
var _personal_attack_offset := 0.0
var _spawn_patrol_active: bool = true
var _spawn_patrol_direction: float = 1.0
var _spawn_patrol_remaining_distance: float = 0.0

var _health_bar_root: Node2D = null
var _health_bar_bg: ColorRect = null
var _health_bar_fill: ColorRect = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	current_health = max_health
	_refresh_player_reference()
	add_to_group("enemies")
	_personal_attack_offset = randf_range(-8.0, 14.0)
	_setup_spawn_patrol()
	_create_health_bar()
	_update_health_bar()
	call_deferred("_snap_to_floor_on_spawn")


func _refresh_player_reference() -> void:
	if is_instance_valid(player):
		return
	player = get_tree().get_first_node_in_group("player") as Node2D


func _snap_to_floor_on_spawn() -> void:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var foot_offset: float = _get_feet_offset()

	var from: Vector2 = global_position + Vector2(0, -120)
	var to: Vector2 = global_position + Vector2(0, 280)

	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1
	query.collide_with_areas = false

	var hit: Dictionary = space_state.intersect_ray(query)
	if hit.is_empty():
		return

	global_position.y = float(hit.position.y) - foot_offset - 0.5
	_update_health_bar_position()


func _get_feet_offset() -> float:
	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return 16.0

	var shape_half_height: float = 16.0

	if collision_shape.shape is CapsuleShape2D:
		var capsule: CapsuleShape2D = collision_shape.shape as CapsuleShape2D
		shape_half_height = capsule.radius + capsule.height * 0.5
	elif collision_shape.shape is CircleShape2D:
		var circle: CircleShape2D = collision_shape.shape as CircleShape2D
		shape_half_height = circle.radius
	elif collision_shape.shape is RectangleShape2D:
		var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
		shape_half_height = rectangle.size.y * 0.5

	return collision_shape.position.y + shape_half_height


func _get_shape_half_height(collision_shape: CollisionShape2D) -> float:
	if collision_shape == null or collision_shape.shape == null:
		return 16.0

	if collision_shape.shape is CapsuleShape2D:
		var capsule: CapsuleShape2D = collision_shape.shape as CapsuleShape2D
		return capsule.radius + capsule.height * 0.5
	if collision_shape.shape is CircleShape2D:
		var circle: CircleShape2D = collision_shape.shape as CircleShape2D
		return circle.radius
	if collision_shape.shape is RectangleShape2D:
		var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
		return rectangle.size.y * 0.5

	return 16.0


func _create_health_bar() -> void:
	if not show_overhead_health_bar:
		return

	_health_bar_root = Node2D.new()
	_health_bar_root.name = "HealthBar"
	add_child(_health_bar_root)

	_health_bar_bg = ColorRect.new()
	_health_bar_bg.name = "Background"
	_health_bar_bg.color = Color(0.12, 0.12, 0.12, 0.85)
	_health_bar_bg.size = Vector2(health_bar_width, health_bar_height)
	_health_bar_root.add_child(_health_bar_bg)

	_health_bar_fill = ColorRect.new()
	_health_bar_fill.name = "Fill"
	_health_bar_fill.color = Color(0.1, 0.9, 0.2, 1.0)
	_health_bar_fill.size = Vector2(health_bar_width, health_bar_height)
	_health_bar_bg.add_child(_health_bar_fill)

	_update_health_bar_position()


func _update_health_bar_position() -> void:
	if _health_bar_root == null:
		return

	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	var shape_half_height: float = _get_shape_half_height(collision_shape)
	var shape_center_y: float = 0.0
	if collision_shape != null:
		shape_center_y = collision_shape.position.y

	var top_y: float = shape_center_y - shape_half_height
	_health_bar_root.position = Vector2(-health_bar_width * 0.5, top_y - health_bar_offset_y)


func _update_health_bar() -> void:
	if _health_bar_fill == null:
		return

	var ratio: float = 0.0
	if max_health > 0:
		ratio = clamp(float(current_health) / float(max_health), 0.0, 1.0)

	_health_bar_fill.size.x = health_bar_width * ratio
	_health_bar_fill.visible = ratio > 0.0
	_health_bar_bg.visible = true


func set_overhead_health_bar_visible(visible: bool) -> void:
	show_overhead_health_bar = visible
	if _health_bar_root != null:
		_health_bar_root.visible = visible


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	apply_gravity(delta)
	_refresh_player_reference()

	if not is_instance_valid(player):
		state = State.IDLE
		velocity.x = 0
		move_and_slide()
		_update_health_bar_position()
		update_animation()
		return

	if _spawn_patrol_active:
		if _is_player_detected():
			_spawn_patrol_active = false
		else:
			_handle_spawn_patrol(delta)
			apply_knockback(delta)
			move_and_slide()
			_update_health_bar_position()
			update_animation()
			return

	update_state()
	handle_state(delta)
	apply_knockback(delta)

	move_and_slide()
	_update_health_bar_position()
	update_animation()


func _setup_spawn_patrol() -> void:
	var min_steps: int = min(spawn_patrol_steps_min, spawn_patrol_steps_max)
	var max_steps: int = max(spawn_patrol_steps_min, spawn_patrol_steps_max)
	var step_count: int = randi_range(min_steps, max_steps)

	_spawn_patrol_direction = -1.0 if randi() % 2 == 0 else 1.0
	_spawn_patrol_remaining_distance = float(step_count) * spawn_patrol_step_distance
	_spawn_patrol_active = _spawn_patrol_remaining_distance > 0.0


func _is_player_detected() -> bool:
	if not is_instance_valid(player):
		return false

	var distance: float = global_position.distance_to(player.global_position)
	return distance <= detection_range


func _handle_spawn_patrol(delta: float) -> void:
	if _spawn_patrol_remaining_distance <= 0.0:
		_spawn_patrol_active = false
		state = State.IDLE
		velocity.x = 0.0
		return

	if is_on_wall():
		_spawn_patrol_direction *= -1.0

	state = State.CHASE
	var patrol_speed: float = speed * spawn_patrol_speed_scale
	velocity.x = _spawn_patrol_direction * patrol_speed
	face_player(_spawn_patrol_direction)

	_spawn_patrol_remaining_distance -= abs(velocity.x) * delta


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.1


func update_state() -> void:
	var distance: float = global_position.distance_to(player.global_position)
	var effective_attack_range: float = max(attack_range + _personal_attack_offset, 12.0)
	
	if state == State.HURT:
		return
	
	if distance <= effective_attack_range:
		state = State.ATTACK
	elif distance <= detection_range:
		state = State.CHASE
	else:
		state = State.IDLE


func handle_state(delta: float) -> void:
	match state:
		State.IDLE:
			velocity.x = 0

		State.CHASE:
			chase_player()

		State.ATTACK:
			velocity.x = 0
			attack_player()

		State.HURT:
			velocity.x = 0


func chase_player() -> void:
	var dir_x: float = player.global_position.x - global_position.x
	var effective_stop_distance: float = max(stop_distance + _personal_attack_offset * 0.35, 12.0)
	
	if abs(dir_x) <= effective_stop_distance:
		velocity.x = 0
		return
	
	var direction: float = sign(dir_x)
	var separation_x: float = _compute_separation_x()
	var target_velocity_x: float = direction * speed + separation_x * speed * separation_strength
	velocity.x = clamp(target_velocity_x, -speed * 1.2, speed * 1.2)
	face_player(dir_x if abs(dir_x) > 0.001 else velocity.x)


func _compute_separation_x() -> float:
	var sum_push_x := 0.0
	var neighbors := 0

	for node in get_tree().get_nodes_in_group("enemies"):
		if node == self:
			continue
		if not (node is Node2D):
			continue

		var other := node as Node2D
		var distance: float = global_position.distance_to(other.global_position)
		if distance <= 0.001 or distance > separation_radius:
			continue

		var away: Vector2 = (global_position - other.global_position).normalized()
		var weight: float = 1.0 - (distance / separation_radius)
		sum_push_x += away.x * weight
		neighbors += 1

	if neighbors == 0:
		return 0.0

	return sum_push_x / float(neighbors)


func face_player(dir_x: float) -> void:
	if dir_x == 0:
		return
	
	anim.flip_h = (dir_x > 0) != sprite_faces_right


func attack_player() -> void:
	if not can_attack:
		return
	
	can_attack = false
	var used_attack_animation := false
	
	if anim.sprite_frames.has_animation("attack"):
		anim.play("attack")

		used_attack_animation = true

	await get_tree().create_timer(BASE_ATTACK_HIT_DELAY, false).timeout

	if player.has_method("take_damage") and _can_land_attack_on(player):
		player.take_damage(damage)

	if used_attack_animation and anim.animation == "attack":
		await anim.animation_finished
	
	await get_tree().create_timer(attack_cooldown, false).timeout
	can_attack = true


func take_damage(amount: int, from_position: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return

	var incoming_damage: int = _compute_incoming_damage(amount)
	if incoming_damage <= 0:
		return

	current_health -= incoming_damage
	_update_health_bar()
	
	knockback_velocity = _build_knockback_velocity(from_position)
	
	flash()
	
	if current_health <= 0:
		die()
	else:
		state = State.HURT
		await get_tree().create_timer(0.2, false).timeout
		state = State.IDLE


func _compute_incoming_damage(raw_amount: int) -> int:
	if raw_amount <= 0:
		return 0

	var reduced_damage: float = float(raw_amount)
	reduced_damage *= 1.0 - clampf(damage_reduction_ratio, 0.0, 0.95)
	reduced_damage -= float(max(damage_reduction_flat, 0))
	return maxi(int(ceil(reduced_damage)), 1)


func apply_knockback(delta: float) -> void:
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 10.0 * delta)


func flash() -> void:
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1, false).timeout
	modulate = Color(1, 1, 1)


func die() -> void:
	state = State.DEAD
	_disable_collision_for_death()
	
	if anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished
	
	PlayerStats.add_xp(xp_reward)
	PlayerStats.register_enemy_kill()
	_drop_coin_pickups(coin_reward)
	
	var floor_node: Node = _find_floor_node()
	if floor_node:
		floor_node.enemy_killed(self)
	
	queue_free()


func _build_knockback_velocity(from_position: Vector2) -> Vector2:
	if knockback_immune or not receives_hit_knockback:
		return Vector2.ZERO

	var knockback_direction: Vector2 = global_position - from_position
	if knockback_direction.length_squared() < 0.0001:
		knockback_direction = Vector2(1, 0)

	var impulse: Vector2 = knockback_direction.normalized() * knockback_force
	var max_upward: float = knockback_force * 0.35
	var max_downward: float = knockback_force * 0.2
	impulse.y = clamp(impulse.y, -max_upward, max_downward)

	var min_horizontal: float = knockback_force * 0.35
	if abs(impulse.x) < min_horizontal:
		impulse.x = sign(knockback_direction.x if abs(knockback_direction.x) > 0.001 else 1.0) * min_horizontal

	return impulse

func _is_player_inside_damage_area(player_node: Node2D) -> bool:
	if not is_instance_valid(player_node):
		return false

	var damage_area: Area2D = get_node_or_null("DamageArea") as Area2D
	if damage_area == null:
		return false
	if not damage_area.monitoring:
		return false

	for body in damage_area.get_overlapping_bodies():
		if body == player_node:
			return true

	return false

func _can_land_attack_on(player_node: Node2D) -> bool:
	if _is_gameplay_paused():
		return false
	if state == State.DEAD:
		return false

	return _is_player_inside_damage_area(player_node) or _is_player_in_attack_hitbox(player_node)


func _is_gameplay_paused() -> bool:
	return get_tree() != null and get_tree().paused


func _is_player_in_attack_hitbox(player_node: Node2D) -> bool:
	if not is_instance_valid(player_node):
		return false

	var effective_attack_range: float = max(attack_range + _personal_attack_offset, 12.0)
	var delta_to_player: Vector2 = player_node.global_position - global_position
	if abs(delta_to_player.y) > 66.0:
		return false

	var facing_sign: float = 1.0
	if anim != null:
		facing_sign = -1.0 if anim.flip_h == sprite_faces_right else 1.0

	return delta_to_player.length_squared() <= effective_attack_range * effective_attack_range and delta_to_player.x * facing_sign >= -6.0


func _disable_collision_for_death() -> void:
	collision_layer = 0
	collision_mask = 0

	var body_collision: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_collision != null:
		body_collision.disabled = true
		body_collision.set_deferred("disabled", true)

	var damage_area: Area2D = get_node_or_null("DamageArea") as Area2D
	if damage_area == null:
		return

	damage_area.monitoring = false
	damage_area.monitorable = false
	damage_area.collision_layer = 0
	damage_area.collision_mask = 0

	for child in damage_area.get_children():
		if child is CollisionShape2D:
			var damage_shape := child as CollisionShape2D
			damage_shape.disabled = true
			damage_shape.set_deferred("disabled", true)


func _drop_coin_pickups(total_value: int) -> void:
	if total_value <= 0:
		return

	if COIN_SCENE == null:
		PlayerStats.add_coins(total_value)
		return

	var parent_node: Node = get_parent()
	if parent_node == null:
		PlayerStats.add_coins(total_value)
		return

	var coin_count: int = clamp(total_value, 1, 8)
	var base_value: int = total_value / coin_count
	var remainder: int = total_value % coin_count

	for index in range(coin_count):
		var coin := COIN_SCENE.instantiate()
		if coin == null:
			continue

		parent_node.add_child(coin)
		(coin as Node2D).global_position = global_position + Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0))

		var value_for_coin := base_value
		if index < remainder:
			value_for_coin += 1

		if coin.has_method("setup"):
			coin.call("setup", value_for_coin, Vector2(sign(randf() - 0.5), 0.0))


func _find_floor_node() -> Node:
	var node: Node = get_parent()
	while node:
		if node.has_method("enemy_killed"):
			return node
		node = node.get_parent()
	return null


func update_animation() -> void:
	if state == State.DEAD:
		return
	
	match state:
		State.IDLE:
			if anim.sprite_frames.has_animation("idle") and anim.animation != "idle":
				anim.play("idle")

		State.CHASE:
			if anim.sprite_frames.has_animation("run") and anim.animation != "run":
				anim.play("run")

		State.ATTACK:
			if anim.sprite_frames.has_animation("attack") and anim.animation != "attack":
				anim.play("attack")

		State.HURT:
			if anim.sprite_frames.has_animation("hurt") and anim.animation != "hurt":
				anim.play("hurt")
