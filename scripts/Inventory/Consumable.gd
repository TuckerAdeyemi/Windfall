extends "res://scripts/Inventory/items.gd"

class_name Consumable

@export var heal_amount: int = 0
@export var gives_exp: int = 0
@export var removes_poison: bool = false


func use(target):
	if heal_amount > 0 and target.has_method("heal"):
		target.heal(heal_amount)
		print("%s healed %d HP" % [target.name, heal_amount])

	if gives_exp > 0 and target.has_method("gain_exp"):
		target.gain_exp(gives_exp)
		print("%s gained %d EXP" % [target.name, gives_exp])

	if removes_poison and target.has_method("remove_status"):
		target.remove_status("Poison")
		print("%s is no longer poisoned!" % target.name)
