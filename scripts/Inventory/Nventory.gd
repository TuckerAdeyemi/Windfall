extends Node

class_name Inventory

var items: Array[Item] = []

func add_item(item: Item):
	for i in items:
		if i.name == item.name:
			i.amount += item.amount
			return
	items.append(item.duplicate())  # Duplicate to avoid shared references

func remove_item(item_name: String, amount: int = 1):
	for i in items:
		if i.name == item_name:
			i.amount -= amount
			if i.amount <= 0:
				items.erase(i)
			return

func has_item(item_name: String, amount: int = 1) -> bool:
	for i in items:
		if i.name == item_name and i.amount >= amount:
			return true
	return false
