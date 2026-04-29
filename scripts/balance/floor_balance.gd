extends RefCounted
class_name FloorBalance

const FLOOR_BALANCE := {
	1: {
		"waves": [
			{"count": 3, "delay": 0.85, "rest": 1.4},
			{"count": 4, "delay": 0.8, "rest": 1.3},
			{"count": 5, "delay": 0.75, "rest": 1.2}
		],
		"minion": {"hp": 30, "damage": 8, "xp": 18, "speed": 95.0, "attack_cooldown": 1.10}
	},
	2: {
		"minion": {"hp": 36, "damage": 9, "xp": 20, "speed": 100.0, "attack_cooldown": 1.05}
	},
	3: {
		"minion": {"hp": 44, "damage": 10, "xp": 24, "speed": 105.0, "attack_cooldown": 1.0},
		"miniboss": {"hp": 96, "damage": 20, "xp": 56, "speed": 210.0, "attack_cooldown": 0.52}
	},
	4: {
		"minion": {"hp": 50, "damage": 11, "xp": 28, "speed": 112.0, "attack_cooldown": 0.95},
		"boss": {"hp": 120, "damage": 24, "xp": 72, "speed": 224.0, "attack_cooldown": 0.48}
	},
	5: {
		"minion": {"hp": 58, "damage": 12, "xp": 32, "speed": 118.0, "attack_cooldown": 0.92},
		"boss": {"hp": 140, "damage": 26, "xp": 84, "speed": 236.0, "attack_cooldown": 0.46}
	},
	6: {
		"minion": {"hp": 68, "damage": 13, "xp": 36, "speed": 124.0, "attack_cooldown": 0.9},
		"boss": {"hp": 164, "damage": 28, "xp": 98, "speed": 248.0, "attack_cooldown": 0.44}
	},
	7: {
		"minion": {"hp": 80, "damage": 14, "xp": 40, "speed": 132.0, "attack_cooldown": 0.88},
		"boss": {"hp": 192, "damage": 31, "xp": 116, "speed": 264.0, "attack_cooldown": 0.42}
	},
	8: {
		"minion": {"hp": 94, "damage": 16, "xp": 45, "speed": 140.0, "attack_cooldown": 0.86},
		"boss": {"hp": 226, "damage": 34, "xp": 136, "speed": 280.0, "attack_cooldown": 0.4}
	},
	9: {
		"minion": {"hp": 108, "damage": 18, "xp": 50, "speed": 148.0, "attack_cooldown": 0.84},
		"boss": {"hp": 264, "damage": 38, "xp": 160, "speed": 296.0, "attack_cooldown": 0.38}
	},
	10: {
		"boss": {"hp": 340, "damage": 44, "xp": 220, "speed": 320.0, "attack_cooldown": 0.34}
	}
}

static func get_floor_data(floor_number: int) -> Dictionary:
	return FLOOR_BALANCE.get(floor_number, {})
