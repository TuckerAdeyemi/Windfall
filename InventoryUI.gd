extends CanvasLayer

@onready var item_grid = $ItemGrid
@onready var item_desc = $ItemDescription
@onready var use_button = $UseButton
@onready var discard_button = $DiscardButton
@onready var item = $ItemGrid/InventorySlot

var selected_item: Item = null
var on_item_selected: Callable = Callable() # used for equipment menu callbacks

# optional: stat preview callback
var preview_stats_callback: Callable = Callable()
var preview_callback: Callable = Callable()

func _ready():
	"""
	use_button.pressed.connect(func():
			#inventory.remove_item(selected_item.name, 1)
			print("used the item fuck nga")
			#Nventory.remove_item(selected_item.name)
			selected_item.remove()
			update_inventory_display(Nventory)
	)

	discard_button.pressed.connect(func():
		if selected_item:
			#inventory.remove_item(selected_item.name, 1)
			print("got rid of ts")
			Nventory.remove_item(selected_item.name)
			update_inventory_display(Nventory)
	)
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("Scroll Left"):
		print(selected_item.name)
	"""

func show_with_filter(slot_type: String, callback: Callable, preview_callback: Callable = Callable()):
	on_item_selected = callback
	preview_stats_callback = preview_callback
	update_inventory_display(Nventory, slot_type)
	show()

func update_inventory_display(inventory: Inventory, slot_type: String = ""):
	# Save currently selected item name
	var old_selected_name: String = ""
	if selected_item:
		old_selected_name = selected_item.name

	# Reset description + disable buttons
	selected_item = null
	item_desc.text = ""
	use_button.disabled = true
	discard_button.disabled = true

	# Clear old slots
	for child in item_grid.get_children():
		child.queue_free()

	var first_slot: Control = null
	var restored = false

	for inv_item in inventory.items:
		# filter by slot_type if provided
		if slot_type != "" and inv_item.type != slot_type:
			continue

		var slot = preload("res://scenes/items/inventory_slot.tscn").instantiate()
		slot.set_item(inv_item)

		var this_item = inv_item
		# === Focused slot updates ===
		slot.focus_entered.connect(func():
			selected_item = this_item
			item_desc.text = "%s: %s" % [this_item.name, this_item.description]
			use_button.disabled = false
			discard_button.disabled = false
			print("selected %s" % [selected_item.name])

			# Call preview if defined
			if preview_stats_callback.is_valid():
				preview_stats_callback.call(this_item)
		)

		# === Clicked slot ===
		slot.pressed.connect(func():
			if on_item_selected.is_valid():
				on_item_selected.call(this_item)
			hide()
		)

		item_grid.add_child(slot)

		if first_slot == null:
			first_slot = slot

		# Restore focus if this matches the previously selected item
		if old_selected_name != "" and old_selected_name == inv_item.name and not restored:
			slot.grab_focus()
			restored = true

	# Only focus first slot if nothing was restored
	if first_slot and not restored:
		first_slot.grab_focus()

# compare function used by sort_custom
func _compare_items(a: Item, b: Item, priority: String) -> bool:
	var val_a
	var val_b

	match priority:
		"item_type":
			val_a = a.type
			val_b = b.type
		"amount":
			val_a = a.amount
			val_b = b.amount
		"rarity":
			val_a = a.rarity
			val_b = b.rarity
		"name":
			val_a = a.name
			val_b = b.name
		_:
			val_a = a.id
			val_b = b.id

	print("Comparing by %s: %s (%s) vs %s (%s)" % [priority, a.name, str(val_a), b.name, str(val_b)])

	if val_a < val_b:
		return true
	elif val_a > val_b:
		return false

	return a.id < b.id

func sort_inventory(priority: String):
	Nventory.items.sort_custom(Callable(self, "_compare_items").bind(priority))
	update_inventory_display(Nventory)

var current_sort_key: String = "item_type" # default

func _on_sort_button_item_selected(index: int) -> void:
	match index:
		0:
			current_sort_key = "item_type"
		1:
			current_sort_key = "amount"
		2:
			current_sort_key = "rarity"
		_:
			current_sort_key = "name"
	sort_inventory(current_sort_key)

func _on_sort_button_pressed() -> void:
	sort_inventory(current_sort_key)

func _on_use_button_pressed() -> void:
	item._pressed()
