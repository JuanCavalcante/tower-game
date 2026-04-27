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
	knockback_velocity = (global_position - source_position).normalized() * knockback_force
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
	state = State.DEAD
	can_attack = false
	can_damage = false
	velocity = Vector2.ZERO
	_disable_collision_for_death()
	set_physics_process(false)
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
