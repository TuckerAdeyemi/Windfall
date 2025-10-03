extends Item

class_name Weapon

@export var atk: int = 1
@export var hit_rate: float = 0.95
@export var crit_rate: float = 0.05
@export var weight: int = 1
@export var str : int = 0
@export var mag: int = 0
@export var spd : int = 0
@export var def : int = 0
@export var res : int = 0
@export var luck : int = 0

@export_enum("Swords", "Knives", "Spears", "Rods", "Axes", "Staffs", "Scythes", "Bows") var weapon_type: String
@export_enum("Common", "Uncommon", "Rare", "Epic", "Divine") var rarity: String = "Common"
@export_enum("Slash", "Pierce", "Blunt", "Magic") var attack_type: String = "Slash"
@export_enum("Neutral", "Fire", "Ice", "Lightning", "Earth", "Wind", "Light", "Dark", "Time") var element: String = "Neutral" 
@export var sprite: Texture
