extends Resource

class_name EnemyAI

func take_turn(enemy: Enemy, party: Array, battle_manager: Node) -> void:
	var alive_members = party.filter(func(p): return p.character_data.hp > 0)

	if alive_members.is_empty():
		print("No valid targets!")
		return
	var target = alive_members[randi() % alive_members.size()]
	battle_manager.basic_attack(enemy, target)
	
func slow_member(enemy: Enemy, party: Array, battle_manager: Node) -> void:
	var slow = SpellDB.get_spell("Tardus")
	var faster_members = party.filter(func(p): return p.character_data.spd > enemy.spd)
	if (faster_members.size() >= 2):
		print("damn you got slowed fr")
		#implement slow random partymember that is faster
		
func slow_party(enemy: Enemy, party: Array, battle_manager: Node) -> void:
	var faster_members = party.filter(func(p): return p.character_data.spd > enemy.spd)
	if (faster_members.size() >= 2):
		print("damn yall got slowed fr")
		#implement slow entire party
