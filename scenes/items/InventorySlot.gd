# InventorySlot.gd
extends TextureButton

var item: Item = null

func set_item(new_item: Item):
	item = new_item
	texture_normal = item.icon
	tooltip_text = "%s x%d" % [item.name, item.amount]

func _pressed():
	if item.amount == 0:
		print("You have no %s." % [item.name])
	if item.amount > 0:
		print("Used item: %s" % item.name)
		Nventory.remove_item(item.name)
		print(item.amount)
		

