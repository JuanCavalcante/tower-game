extends BaseEnemy

var _is_hurt := false
var _is_dying := false
var _is_attacking := false

func _ready():
	super._ready()
	anim.animation_finished.connect(_on_animation_finished)

func take_damage(amount, source_position = Vector2.ZERO):
	if _is_dying:
		return
	current_health -= amount
	_update_health_bar()
	var knockback_dir_x: float = sign(global_position.x - source_position.x)
	if knockback_dir_x == 0.0:
		knockback_dir_x = -1.0 if randf() < 0.5 else 1.0

	# Mantem o knockback principalmente horizontal para evitar que o boss "suba" no player.
	knockback_velocity = Vector2(knockback_dir_x * knockback_force, -28.0)
	if current_health <= 0:
		_start_death()
	else:
		_start_hurt()

func _start_hurt():
	if _is_hurt or _is_dying:
		return
	_is_hurt = true
	flash()
	anim.play("hurt")

func _start_death():
	_is_dying = true
	set_physics_process(false)
	var col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.set_deferred("disabled", true)
	anim.play("die")

func _on_animation_finished():
	match anim.animation:
		"hurt":
			_is_hurt = false
		"attack1", "attack2":
			_is_attacking = false
		"die":
			die()

func update_animation():
	if _is_dying or _is_hurt or _is_attacking:
		return
	if abs(velocity.x) > 5:
		anim.play("walk")
	else:
		anim.play("idle")

func _on_damage_area_body_entered(body):
	if not body.is_in_group("player") or not can_damage or _is_dying:
		return
	body.take_damage(damage)
	can_damage = false
	if not _is_hurt and not _is_attacking:
		_is_attacking = true
		anim.play("attack1")
	await get_tree().create_timer(1.5).timeout
	can_damage = true
