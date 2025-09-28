extends Node

func check_mp(caster: Character, spell: Magic) -> bool:
	if (caster.mp < spell.cost):
		print("Not enough MP!")
		return false
	return true

func calculate_healing(caster: Character, spell: Magic) -> int:
	caster.mp -= spell.cost
	
	# Base heal calculation
	var base_heal = spell.power * 5 + int((caster.level / 2) * caster.mag * spell.power / 32)

	# Apply a small random variance,
	var min_heal = int(base_heal * 0.97)
	var max_heal = int(base_heal * 1.03)

	return randi_range(min_heal, max_heal)

func calculate_damage(caster: Character, spell: Magic, target) -> int:
	caster.mp -= spell.cost

	# Base damage calculation
	var base_damage = spell.power * 5 + int((caster.level / 2) * caster.mag * spell.power / 32)

	# Apply a small random variance
	var min_dmg = int(base_damage * 0.97)
	var max_dmg = int(base_damage * 1.03)

	# Reduce by target's endurance (or magic resistance, depending on your stat names)
	var raw_damage = randi_range(min_dmg, max_dmg)
	var truedamage = max(0, raw_damage * (255 - target.res)/256)
	
	var element = ""
	element = spell.element
	
	if target is Enemy:
		if element != "":
			var multiplier = target.elemental_weaknesses.get(element, 1.0)
			truedamage *= multiplier
	
	return truedamage
	

func attack(member: Character, target) -> int:
	# === Base Damage Calculation ===
	var damage = 20 + (member.level * (member.str + member.equipped_weapon.atk)/2 * 3 / 2)
	var truedamage
	if target is Enemy:
		truedamage = (damage * (255 - target.def)/256) + 1
	else:
		truedamage = (damage * (255 - target.end)/256) + 1
		
	# === Get element from member's equipped weapon ===
	var element = ""
	if member.equipped_weapon:
		element = member.equipped_weapon.element

	# === Apply elemental multiplier ===
	if target is Enemy:
		if element != "":
			var multiplier = target.elemental_weaknesses.get(element, 1.0)
			truedamage *= multiplier
		
	# === Crit Check ===
	var crit_roll = randf()
	if crit_roll < member.equipped_weapon.crit_rate:
		print("Critical Hit!")
		truedamage *= 1.5
		
	return truedamage
