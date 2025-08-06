# SkillDB.gd
extends Node

var all_magic = {}

func _ready():
	all_magic["Aeris"] = preload("res://resources/skills/spells/wind/aeris.tres")#low wind
	all_magic["Ventus"] = preload("res://resources/skills/spells/wind/ventus.tres")#medium wind
	all_magic["Caelos"] = preload("res://resources/skills/spells/wind/caelos.tres")#heavy wind
	
	all_magic["Ignis"] = preload("res://resources/skills/spells/fire/ignis.tres")#low fire
	all_magic["Pyra"] = preload("res://resources/skills/spells/fire/pyra.tres")#medium fire
	all_magic["Empyros"] = preload("res://resources/skills/spells/fire/empyros.tres")#heavy fire
	
	all_magic["Glacia"] = preload("res://resources/skills/spells/ice/glacia.tres")#low ice
	all_magic["Crya"] = preload("res://resources/skills/spells/ice/crya.tres")#medium ice
	all_magic["Nivalos"] = preload("res://resources/skills/spells/ice/nivalos.tres")#heavy ice
	
	all_magic["Curia"] = preload("res://resources/skills/spells/heal/curia.tres")#low heal
	all_magic["Sanare"] = preload("res://resources/skills/spells/heal/sanare.tres")#medium heal
	all_magic["Vitalros"] = preload("res://resources/skills/spells/heal/vitalros.tres")#heavy heal	

	all_magic["Gaion"] = preload("res://resources/skills/spells/earth/gaion.tres") # low earth - creates a small quake or stone spikes
	all_magic["Terra"] = preload("res://resources/skills/spells/earth/terra.tres") # medium earth - raises barriers or rocks from the ground
	all_magic["Seismoros"] = preload("res://resources/skills/spells/earth/seismoros.tres") # heavy earth - causes a localized earthquake

	all_magic["Fulmen"] = preload("res://resources/skills/spells/lightning/fulmen.tres") # low lightning - strikes a single target with a spark
	all_magic["Brontis"] = preload("res://resources/skills/spells/lightning/brontis.tres") # medium lightning - sends a bolt arcing through multiple enemies
	all_magic["Astraphos"] = preload("res://resources/skills/spells/lightning/astraphos.tres") # heavy lightning - summons a storm to strike all foes

	all_magic["Luxis"] = preload("res://resources/skills/spells/LightDark/luxis.tres") # low light - emits blinding light, may heal or boost
	all_magic["Solarios"] = preload("res://resources/skills/spells/LightDark/solarios.tres") # medium light - sears enemies or heals allies in an area
	all_magic["Mortis"] = preload("res://resources/skills/spells/LightDark/mortis.tres") # low dark - drains energy or weakens target
	all_magic["Thanatos"] = preload("res://resources/skills/spells/LightDark/thanatos.tres") # heavy dark - instills fear or causes high necrotic damage

	all_magic["Chronos"] = preload("res://resources/skills/spells/time/chronos.tres") # medium fast - speeds up ally’s turn rate
	all_magic["Acceleros"] = preload("res://resources/skills/spells/time/acceleros.tres") # heavy fast - rapidly accelerates actions for a short time
	all_magic["Deceleros"] = preload("res://resources/skills/spells/time/deceleros.tres") # medium slow - delays target’s next action
	all_magic["Moratos"] = preload("res://resources/skills/spells/time/moratos.tres") # heavy slow - massively slows or stuns target
	all_magic["Tempus"] = preload("res://resources/skills/spells/time/tempus.tres")#low fast
	all_magic["Tardus"] = preload("res://resources/skills/spells/time/tardus.tres")#low slow
	
	all_magic["Aegis"] = preload("res://resources/skills/spells/buff/aegis.tres") 
	all_magic["Fortis"] = preload("res://resources/skills/spells/buff/fortis.tres")
	all_magic["Bastionos"] = preload("res://resources/skills/spells/buff/bastionos.tres")
	# Add more as needed

func get_spell(name: String) -> Magic:
	return all_magic.get(name, null)
