# InventorySlot.gd
extends TextureButton

class_name InventorySlot

var item: Item = null

func _ready():
	# Change color when focused
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_focus_entered():
	$Name.add_theme_color_override("font_color", Color.YELLOW)

func _on_focus_exited():
	$Name.add_theme_color_override("font_color", Color.WHITE)


func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(1,1,1), false, 2)

func set_item(new_item: Item):
	item = new_item
	texture_normal = item.icon
	tooltip_text = "%s x%d" % [item.name, item.amount]
	$Name.text = item.name
	$Amount.text = ": %d" % item.amount
	
	$Name.add_theme_color_override("font_color", Color.WHITE)
	
	

func _pressed():
	if item.type == "Consumable":
		if item.amount == 0:
			print("You have no %s." % [item.name])
		if item.amount > 0:
			print("Used item: %s" % item.name)
			Nventory.remove_item(item.name)
			get_parent().get_parent().update_inventory_display(Nventory)
			print(item.amount)

func remove():
	Nventory.remove_item(item.name)


func _on_use_button_pressed() -> void:
	if item == Consumable:
		if item.amount == 0:
			print("You have no %s." % [item.name])
		if item.amount > 0:
			print("Used item: %s" % item.name)
			Nventory.remove_item(item.name)
			get_parent().get_parent().update_inventory_display(Nventory)
			print(item.amount)
