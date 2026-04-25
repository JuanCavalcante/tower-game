extends BaseEnemy

@export var damage := 15

var _is_flashing := false

func take_damage(amount, source_position = Vector2.ZERO):
	current_health -= amount
	knockback_velocity = (global_position - source_position).normalized() * knockback_force
	flash()
	if current_health <= 0:
		await get_tree().create_timer(0.1).timeout
		die()

func flash():
	if _is_flashing:
		return
	_is_flashing = true
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	_is_flashing = false

func _on_damage_area_body_entered(body):
	if not body.is_in_group("player") or not can_damage:
		return
	body.take_damage(damage)
	can_damage = false
	await get_tree().create_timer(0.8).timeout
	can_damage = true
