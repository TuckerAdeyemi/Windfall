# Skill.gd (this would be a resource)
extends Resource

class_name Abilities

@export var icon: Texture
@export var name: String
@export var description: String = "Deals light wind damage to the enemy."
@export var power: int
@export var cost: int = 5
@export var spd_mult: float = 1.0 
@export var end_mult: float = 1.0 
@export var res_mult: float = 1.0 
@export var duration: int = 3

@export_enum("Damage", "Heal", "Status", "Buff", "Debuff", "Special") var type: String = "Damage" # Example: "Heal", "Attack", "Buff"
@export var sound_effect: AudioStream
@export var status: Array[Dictionary] = [
	{
	"type": "",
	"scope":"",
	"chance":""
	}
]
