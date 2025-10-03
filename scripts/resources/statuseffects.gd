extends Resource

class_name StatusEffect

@export var icon: Texture
@export var name: String
@export var type: String         # "spd_mod", "poison", "sleep"
@export var multiplier: float = 1.0  # For buffs/debuffs
@export var duration: int = 1
#@export var source: String = ""
@export var value: int = 0       # Extra data (ex: poison damage, sleep chance)
