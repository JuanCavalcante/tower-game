extends BaseEnemy

func take_damage(amount, source_position = Vector2.ZERO):
	current_health -= amount
	knockback_velocity = (global_position - source_position).normalized() * knockback_force
	if current_health <= 0:
		flash()
		await get_tree().create_timer(0.1).timeout
		die()

func _on_damage_area_body_entered(body):
	if not body.is_in_group("player") or not can_damage:
		return
	body.take_damage(5)
	can_damage = false
	await get_tree().create_timer(1.0).timeout
	can_damage = true
