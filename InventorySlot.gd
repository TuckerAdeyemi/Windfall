# InventorySlot.gd
extends TextureButton

var item: Item = null

func set_item(new_item: Item):
	item = new_item
	texture_normal = item.icon
	tooltip_text = "%s x%d" % [item.name, item.amount]

func _pressed():
	if item:
		print("Used item: %s" % item.name)
