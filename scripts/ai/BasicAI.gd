extends EnemyAI

class_name BasicAI

func take_turn(enemy: Enemy, party: Array, battle_manager: Node) -> void:
	var alive_members = party.filter(func(p): return p.character_data.hp > 0)

	if alive_members.is_empty():
		print("No valid targets!")
		return
	var target = alive_members[randi() % alive_members.size()]
	battle_manager.basic_attack(enemy, target)
