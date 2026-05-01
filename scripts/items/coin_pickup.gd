extends Node2D

static var _last_collect_sfx_msec: int = 0

@export var collect_radius := 16.0
@export var magnet_range := 72.0
@export var magnet_speed := 360.0
@export var bob_amplitude := 3.5
@export var bob_speed := 6.0
@export var world_collision_mask := 1
@export var floor_cast_up := 64.0
@export var floor_cast_down := 260.0
@export var floor_offset := 6.0
@export var wall_margin := 3.0

var coin_value := 1

var _player: Node2D = null
var _is_collected := false
var _is_magnetizing := false
var _is_settling := true
var _base_position := Vector2.ZERO
var _bob_time := 0.0
var _ground_y := 0.0
var _has_ground := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const COLLECT_SOUND := preload("res://assets/sprites/effect/sound/coinSound.mp3")


func _ready() -> void:
	if anim != null:
		anim.play("default")
	_base_position = global_position
	_ground_y = global_position.y
	_refresh_player_reference()


func setup(value: int, spread_direction: Vector2 = Vector2.ZERO) -> void:
	coin_value = max(value, 1)
	_is_settling = true

	var initial: Vector2 = global_position
	var random_x: float = randf_range(-38.0, 38.0)
	if abs(spread_direction.x) > 0.01:
		random_x += spread_direction.x * randf_range(18.0, 36.0)

	var settle_target: Vector2 = initial + Vector2(random_x * 0.65, randf_range(-6.0, 6.0))
	settle_target = _snap_to_floor(settle_target)
	var hop_target: Vector2 = Vector2(settle_target.x, settle_target.y - randf_range(42.0, 58.0))

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", hop_target, 0.18).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", settle_target, 0.24).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func() -> void:
		_base_position = global_position
		_ground_y = global_position.y
		_is_settling = false
	)


func _process(delta: float) -> void:
	if _is_collected:
		return

	if not is_instance_valid(_player):
		_refresh_player_reference()
		if not is_instance_valid(_player):
			return

	if not _is_magnetizing and not _is_settling:
		_bob_time += delta
		var bob_offset: float = sin(_bob_time * bob_speed) * bob_amplitude
		global_position = _base_position + Vector2(0.0, bob_offset)

	var distance: float = global_position.distance_to(_player.global_position)
	if distance <= magnet_range:
		_is_magnetizing = true

	if _is_magnetizing:
		var step: float = magnet_speed * delta
		var target: Vector2 = _player.global_position + Vector2(0, -6)
		var desired_x: float = move_toward(global_position.x, target.x, step)
		global_position.x = _resolve_horizontal_move(desired_x)

		if _has_ground:
			global_position.y = _ground_y + sin(_bob_time * bob_speed) * min(bob_amplitude, 2.0)
		else:
			global_position.y = move_toward(global_position.y, target.y, step * 0.85)

		var horizontal_distance: float = abs(global_position.x - _player.global_position.x)
		var vertical_distance: float = abs(global_position.y - _player.global_position.y)
		if horizontal_distance <= collect_radius * 1.4 and vertical_distance <= max(collect_radius * 4.0, 64.0):
			_collect()


func _refresh_player_reference() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D


func _snap_to_floor(candidate: Vector2) -> Vector2:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var from: Vector2 = candidate + Vector2(0, -floor_cast_up)
	var to: Vector2 = candidate + Vector2(0, floor_cast_down)

	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = world_collision_mask
	query.collide_with_areas = false
	query.exclude = [self]

	var hit: Dictionary = space_state.intersect_ray(query)
	if hit.is_empty():
		_has_ground = false
		return candidate

	_has_ground = true
	_ground_y = float(hit.position.y) - floor_offset
	return Vector2(candidate.x, _ground_y)


func _resolve_horizontal_move(desired_x: float) -> float:
	if is_equal_approx(desired_x, global_position.x):
		return global_position.x

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var from: Vector2 = global_position
	var to: Vector2 = Vector2(desired_x, global_position.y)

	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = world_collision_mask
	query.collide_with_areas = false
	query.exclude = [self]

	var hit: Dictionary = space_state.intersect_ray(query)
	if hit.is_empty():
		return desired_x

	if hit.collider == _player:
		return desired_x

	var direction: float = sign(desired_x - global_position.x)
	return float(hit.position.x) - direction * wall_margin


func _collect() -> void:
	if _is_collected:
		return

	_is_collected = true
	visible = false
	set_process(false)
	PlayerStats.add_coins(coin_value)
	_play_collect_sound()
	queue_free()


func _play_collect_sound() -> void:
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - _last_collect_sfx_msec < 70:
		return

	_last_collect_sfx_msec = now_msec

	var sound_node := AudioStreamPlayer2D.new()
	sound_node.stream = COLLECT_SOUND
	sound_node.global_position = global_position
	sound_node.volume_db = -6.0

	var root: Node = get_tree().current_scene
	if root == null:
		root = get_tree().root

	root.add_child(sound_node)
	sound_node.play()
	sound_node.finished.connect(func() -> void:
		sound_node.queue_free()
	)
