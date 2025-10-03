extends Resource

class_name Item
@export var name: String
@export var icon: Texture2D
@export var id: int
@export var description: String
@export_enum("consumable", "weapon", "armor", "accessory") var type: String = "consumable"
@export var amount: int
