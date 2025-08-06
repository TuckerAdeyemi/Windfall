extends CanvasLayer

@onready var item_grid = $ItemGrid

func update_inventory_display(inventory: Inventory):
	for child in item_grid.get_children():
		child.queue_free()
	for item in inventory.items:
		var slot = preload("res://scenes/items/inventory_slot.tscn").instantiate()
		slot.set_item(item)
		item_grid.add_child(slot)
