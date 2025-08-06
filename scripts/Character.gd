extends Resource

class_name Character

@export var portrait: Texture
@export var name: String
@export var level: int = 1
@export var hp: int = max_hp
@export var max_hp: int = 150
@export var mp: int = 30
@export var max_mp: int = 30
@export var exp: int
@export var exp_to_next: int
@export var exp_total: int
@export var str : int = 2
@export var mag : int = 2
@export var spd : int = 2
@export var end : int = 2
@export var res : int = 2
@export var luck : int = 1
@export var sprite_path : String
@export var spell_set: SpellSet
@export var animation_frames_path := "res://resources/animations/flynn_sprite_frames.tres"
@export var is_player: bool = true



#unique growth rates for characters
@export var hp_growth: float = 1
@export var mp_growth: float = 1
@export var str_growth: float = 1
@export var mag_growth: float = 1
@export var spd_growth: float = 1
@export var end_growth: float = 1
@export var res_growth: float = 1
@export var luck_growth: float = 1
@export var equipped_weapon: Weapon
@export var title: String 

# Internal growth accumulators (float)
var str_accum: float = 0.0
var mag_accum: float = 0.0
var spd_accum: float = 0.0
var end_accum: float = 0.0
var res_accum: float = 0.0
var luck_accum: float = 0.0
var hp_accum: float = 0.0
var mp_accum: float = 0.0

func _init():
	exp_to_next = get_req_exp(level)
	
	str_accum = str
	mag_accum = mag
	spd_accum = spd
	end_accum = end
	res_accum = res
	luck_accum = luck
	hp_accum = max_hp
	mp_accum = max_mp

func get_learned_spells() -> Array[Magic]:
	var learned: Array[Magic]= []
	if spell_set == null:
		return learned

	for name in spell_set.spells.keys():
		var required_level = spell_set.spells[name]
		if level >= required_level:
			var skill = SpellDB.get_spell(name)
			if skill:
				learned.append(skill)
				
	learned.sort_custom(func(a: Magic, b: Magic) -> bool:
		var a_type = Magic.type_order.get(a.magic_type, 99)
		var b_type = Magic.type_order.get(b.magic_type, 99)

		if a_type == b_type:
			var a_elem = Magic.ELEMENT_ORDER.get(a.element, 999)
			var b_elem = Magic.ELEMENT_ORDER.get(b.element, 999)

			if a_elem == b_elem:
				if a.tier == b.tier:
					return a.name < b.name
				return a.tier < b.tier
			return a_elem < b_elem

		return a_type < b_type
		)
	return learned
	


func get_req_exp(lvl: int) -> int:
	return round(pow(lvl, 2.7) + lvl * 4)
	
static func grant_exp_to_party(amount: int):
	for member in GameManage.party:
		#Uncomment this if you later add an `is_dead` flag
		if member.hp > 0:
			member.gain_exp(amount)
	
func gain_exp(amount: int):
	if level < 100:
		exp += amount
		exp_total += amount

		while exp >= exp_to_next:
			exp -= exp_to_next
			level_up()
	else:
		exp = exp_total
		
func level_up():
	if level < 100:
		level += 1
		exp_to_next = get_req_exp(level)

		var stat_gain := 126.0 / 99.0  # ≈ 1.2857
		
		var hp_gain := 5000.0 / 99.0
		var mp_gain := 500.0 / 99.0

		# Accumulate float growths
		str_accum += stat_gain * str_growth
		mag_accum += stat_gain * mag_growth
		spd_accum += stat_gain * spd_growth
		end_accum += stat_gain * end_growth
		res_accum += stat_gain * res_growth
		luck_accum += stat_gain * luck_growth

		hp_accum += hp_gain * hp_growth
		mp_accum += mp_gain * mp_growth

		# Assign rounded stats (and cap)
		str = min(round(str_accum), 252)
		mag = min(round(mag_accum), 252)
		spd = min(round(spd_accum), 252)
		end = min(round(end_accum), 252)
		res = min(round(res_accum), 252)
		luck = min(round(luck_accum), 252)

		max_hp = min(round(hp_accum), 9999)
		max_mp = min(round(mp_accum), 999)


		#hp = max_hp
		mp = max_mp

		
	
		print(name, " leveled up to Lv", level, "!")
		#var stats = ['max_hp', 'strength', 'magic']
		#var random_stat = stats[randi() % stats.size()]
		#set(random_stat, get(random_stat) + randi() % 4 + 2)
	
	
# Character.gd or similar

#var equipped_armor: Armor = null

func equip_weapon(weapon: Weapon):
	equipped_weapon = weapon
	str += equipped_weapon.atk
	mag += equipped_weapon.mag
	# etc

#func equip_armor(armor: Armor):
#	equipped_armor = armor
#	defense = armor.defense
#	endurance += armor.endurance_bonus
#	res += armor.res_bonus
#	spd += armor.spd_bonus
	# handle immunities or elemental resists if needed

