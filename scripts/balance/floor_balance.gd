extends RefCounted
class_name FloorBalance

const FLOOR_BALANCE := {
	1: {
		"waves": [
			{"count": 6, "delay": 0.50, "rest": 1.20},
			{"count": 6, "delay": 0.45, "rest": 1.00},
			{"count": 8, "delay": 0.40, "rest": 0.80},
		],
		"minion": {"hp": 30, "damage": 8, "xp": 18, "speed": 95.0, "attack_cooldown": 1.10}
	},
	2: {
		"waves": [
			{"count": 4, "delay": 0.35, "rest": 0.80},
			{"count": 8, "delay": 0.50, "rest": 1.20},
			{"count": 6, "delay": 0.30, "rest": 0.60},
		],
		"minion": {"hp": 36, "damage": 9, "xp": 20, "speed": 100.0, "attack_cooldown": 1.05}
	},
	3: {
		"waves": [
			{"count": 6, "delay": 0.35, "rest": 0.80},
			{"count": 4, "delay": 0.25, "rest": 0.50},
			{"count": 10, "delay": 0.45, "rest": 1.00},
		],
		"minion": {"hp": 44, "damage": 10, "xp": 24, "speed": 105.0, "attack_cooldown": 1.0}
	},
	4: {
		"minion": {"hp": 50, "damage": 11, "xp": 28, "speed": 112.0, "attack_cooldown": 0.95}
	},
	5: {
		"minion": {"hp": 58, "damage": 12, "xp": 32, "speed": 118.0, "attack_cooldown": 0.92},
		"miniboss": {"hp": 200, "damage": 22, "xp": 110, "speed": 135.0, "attack_cooldown": 0.85}
	},
	6: {
		"minion": {"hp": 68, "damage": 13, "xp": 36, "speed": 124.0, "attack_cooldown": 0.9}
	},
	7: {
		"minion": {"hp": 80, "damage": 14, "xp": 40, "speed": 132.0, "attack_cooldown": 0.88}
	},
	8: {
		"minion": {"hp": 94, "damage": 16, "xp": 45, "speed": 140.0, "attack_cooldown": 0.86}
	},
	9: {
		"minion": {"hp": 108, "damage": 18, "xp": 50, "speed": 148.0, "attack_cooldown": 0.84}
	},
	10: {
		"boss_unico": {
			"hp": 1200,
			"damage": 42,
			"xp": 220,
			"speed": 170.0,
			"attack_cooldown": 0.75,
			"damage_reduction_ratio": 0.25,
			"damage_reduction_flat": 2
		}
	}
}

static func get_floor_data(floor_number: int) -> Dictionary:
	return FLOOR_BALANCE.get(floor_number, {})
