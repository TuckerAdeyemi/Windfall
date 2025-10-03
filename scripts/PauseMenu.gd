extends CanvasLayer

class_name PauseMenu

# Left side of Menu
@onready var button_items = $Panel/HBox/VBoxContainer/Items
@onready var button_magic = $Panel/HBox/VBoxContainer/Magic
@onready var button_equip = $Panel/HBox/VBoxContainer/Equip
@onready var button_status = $Panel/HBox/VBoxContainer/Status
@onready var button_quests = $Panel/HBox/VBoxContainer/Quests
@onready var button_config = $Panel/HBox/VBoxContainer/Config
@onready var button_save = $Panel/HBox/VBoxContainer/Save
@onready var button_load = $Panel/HBox/VBoxContainer/Load

@onready var time_display = $Panel/TimeLabel
@onready var gold_display = $Panel/Gold
@onready var location = $Panel/Location
@onready var panel = $Panel
@onready var item_panel = $InvenPanel
@onready var inven = $InvenPanel/InventoryUI
@onready var status_panel = $StatusPanel
@onready var magic_panel = $MagicPanel
@onready var equip_panel = $EquipPanel
@onready var quests_panel = $QuestPanel
@onready var config_panel = $SettingPanel
@onready var save_panel = $SavePanel

@onready var mag_port = $MagicPanel/MagicDisplay/TopInfo/Portrait
@onready var mag_name = $MagicPanel/MagicDisplay/TopInfo/InfoBox/Name
@onready var mag_hp = $MagicPanel/MagicDisplay/TopInfo/InfoBox/HPLabel
@onready var mag_mp = $MagicPanel/MagicDisplay/TopInfo/InfoBox/MPLabel
@onready var desc = $MagicPanel/MagicDisplay/Description
@onready var target_mag = $MagicPanel/TargetPanel

@onready var volume_slider = $SettingPanel/VBoxContainer/HBoxContainer/HSlider
@onready var resolution_option = $SettingPanel/VBoxContainer/HBoxContainer3/OptionButton
@onready var fs_check = $SettingPanel/VBoxContainer/HBoxContainer2/CheckButton

@onready var weapon_slot: Button = $EquipPanel/HBoxContainer/VBoxContainer/WeaponSlot
@onready var armor_slot: Button = $EquipPanel/HBoxContainer/VBoxContainer/ArmorSlot
@onready var accessory_slot: Button = $EquipPanel/HBoxContainer/VBoxContainer/AccessorySlot
@onready var stats_label: RichTextLabel = $EquipPanel/HBoxContainer/VBoxContainer2/StatsLabel
@onready var preview_label: RichTextLabel = $EquipPanel/HBoxContainer/VBoxContainer2/PreviewLabel

@export var color: StyleBox
@onready var party_display = $Panel/HBox/PartyDisplay
@onready var focus_sfx = $AudioStreamPlayer2D
@onready var sfx = $SoundEffects



@onready var parties = GameManage.party

# for magic scope
var target_all := false
var current_spell: Magic = null
var current_caster: Character = null
var volume

# equipment state
var current_equipment = {
	"weapon": null,
	"armor": null,
	"accessory": null
}

func _ready():
	# === Settings ===
	volume_slider.value = AudioServer.get_bus_volume_db(0)
	volume_slider.value_changed.connect(_on_volume_changed)

	resolution_option.add_item("1280x720")
	resolution_option.add_item("1920x1080")
	resolution_option.add_item("2560x1440")
	resolution_option.add_item("3840x2160")
	resolution_option.item_selected.connect(_on_resolution_selected)

	fs_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(_on_fullscreen_toggled)

	# === Panels ===
	item_panel.visible = false
	status_panel.visible = false
	magic_panel.visible = false
	equip_panel.visible = false
	quests_panel.visible = false
	config_panel.visible = false

	GameManage.update_location()
	GameManage.displaygold()
	$InvenPanel/InventoryUI.update_inventory_display(Nventory)

	# === Button focus sfx ===
	for button in $Panel/HBox/VBoxContainer.get_children():
		if button is Button:
			button.focus_entered.connect(play_focus_sfx)

	button_items.pressed.connect(func():
		button_items.grab_focus()
		trigger_selected_button()
	)
	button_magic.pressed.connect(func():
		button_magic.grab_focus()
		trigger_selected_button()
	)

	# === Equipment Slots ===
	weapon_slot.pressed.connect(func(): _open_inventory("weapon"))
	armor_slot.pressed.connect(func(): _open_inventory("armor"))
	accessory_slot.pressed.connect(func(): _open_inventory("accessory"))

	_update_stats()

			
func _on_volume_changed(value):
	# convert slider value to decibels
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))

func _on_fullscreen_toggled(pressed: bool):
	if !pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_selected(index):
	var text = resolution_option.get_item_text(index)
	if text == "Fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		var parts = text.split("x")
		if parts.size() == 2:
			var w = int(parts[0])
			var h = int(parts[1])
			DisplayServer.window_set_size(Vector2i(w, h))
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func play_focus_sfx():
	focus_sfx.play()

func show_party(party: Array[Character]):
	if party.size() >= 1:
		party_display.set_character(party_display.get_node("Player1"), party[0])  # Player 1
	if party.size() >= 2:
		party_display.set_character(party_display.get_node("Player2"), party[1])  # Player 2
	if party.size() >= 3:
		party_display.set_character(party_display.get_node("Player3"), party[2])  # Player 3
	if party.size() >= 4:
		party_display.set_character(party_display.get_node("Player4"), party[3])  # Player 3

# Set initial focus to the first button when the menu is shown
func set_initial_focus():
	button_items.grab_focus()

# Handle input for button navigation and actions
func update_playtime_display(total_play_time: float):
	var total_seconds = int(total_play_time)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	time_display.text = "Play Time: %02d:%02d:%02d" % [hours, minutes, seconds]




func _unhandled_input(event):
	#if event.is_action_pressed("Back") and status_panel.visible:
	#	status_panel.visible = false
	#	panel.visible = true
	if event.is_action_pressed("ui_up"):
		move_focus_up()
	elif event.is_action_pressed("ui_down"):
		move_focus_down()
	elif event.is_action_pressed("Enter"):
		trigger_selected_button()
		focus_sfx.play()
	elif event.is_action_pressed("Scroll Left"):
		if (status_panel.visible or magic_panel.visible or equip_panel.visible) and !(item_panel.visible):
			cycle_party(-1)
			focus_sfx.play()
	elif event.is_action_pressed("Scroll Right"):
		if (status_panel.visible or magic_panel.visible or equip_panel.visible) and !(item_panel.visible):
			cycle_party(1)
			focus_sfx.play()
	if event.is_action_pressed("Toggle Scope"):
		if magic_panel.visible and magic_panel.get_node("TargetPanel").visible:
			target_all = !target_all
			update_target_panel()  # Refresh the UI
	
func move_focus_up():
	var focused = get_viewport().gui_get_focus_owner()
	if focused == button_items:
		button_load.grab_focus()
	elif focused == button_magic:
		button_items.grab_focus()
	elif focused == button_equip:
		button_magic.grab_focus()
	elif focused == button_status:
		button_equip.grab_focus()
	elif focused == button_quests:
		button_status.grab_focus()
	elif focused == button_config:
		button_quests.grab_focus()
	elif focused == button_save:
		button_config.grab_focus()
	elif focused == button_load:
		button_save.grab_focus()
		
func move_focus_down():
	var focused = get_viewport().gui_get_focus_owner()
	if focused == button_items:
		button_magic.grab_focus()
	elif focused == button_magic:
		button_equip.grab_focus()
	elif focused == button_equip:
		button_status.grab_focus()
	elif focused == button_status:
		button_quests.grab_focus()
	elif focused == button_quests:
		button_config.grab_focus()
	elif focused == button_config:
		button_save.grab_focus()
	elif focused == button_save:
		button_load.grab_focus()
	elif focused == button_load:
		button_items.grab_focus()

# Perform action when Enter or Accept is pressed
func trigger_selected_button():
	var focused = get_viewport().gui_get_focus_owner()
	
	if focused == button_items:
		item_panel.visible = true
		inven.visible = true
		print("Items")
		Nventory.add_item(ItemDB.potion)
		Nventory.add_item(ItemDB.antidote)
		
		$InvenPanel/InventoryUI.update_inventory_display(Nventory)
		panel.visible = false
	elif focused == button_magic:
		magic_panel.visible = true
		display_spells()
	elif focused == button_equip:
		print("Equip")
		equip_panel.visible = true
		panel.visible = false   # hide main pause menu buttons
		_update_stats()
	elif focused == button_status:
		display_stats()
	elif focused == button_quests:
		print("Quests")
		var quest_res = load("res://resources/quests/clear_ruins.tres")
		var otherquest = load("res://resources/quests/murder_slimes.tres")
		GameManage.add_quest(quest_res)
		GameManage.add_quest(otherquest)
		GameManage.complete_quest("ruin")
		quests_panel.visible = true
		panel.visible = false
		quests_panel.call("show_quests")
		
	elif focused == button_config:
		print("Config")
		config_panel.visible = true
		panel.visible = false
	elif focused == button_save:
		print("Save")
		save_panel.visible = true
		save_panel.is_save_menu = true
		save_panel._refresh_slots()
		panel.visible = false
	elif focused == button_load:
		print("Load")
		save_panel.visible = true
		save_panel.is_save_menu = false
		save_panel._refresh_slots()
		panel.visible = false
		
# Print stats for each party member in the terminal
"-------------------------------------------------------------------------------"
var current_party_index := 0

func display_stats():
	status_panel.visible = true
	panel.visible = false  # Hide main menu buttons
	
	var member = GameManage.party[current_party_index]
	#portrait
	status_panel.get_node("VBoxContainer/Portrait").texture = member.portrait
	
	#labels
	status_panel.get_node("VBoxContainer/Name").text = "Name: " + member.name
	status_panel.get_node("VBoxContainer/HP").text = "HP: %d / %d" % [member.hp, member.max_hp]
	status_panel.get_node("VBoxContainer/MP").text = "MP: %d / %d" % [member.mp, member.max_mp]
	status_panel.get_node("VBoxContainer/Level").text = "Level: " + str(member.level)
	status_panel.get_node("VBoxContainer/STR").text = "STR: " + str(member.str)
	status_panel.get_node("VBoxContainer/MAG").text = "MAG: " + str(member.mag)
	status_panel.get_node("VBoxContainer/SPD").text = "SPD: " + str(member.spd)
	status_panel.get_node("VBoxContainer/END").text = "END: " + str(member.end)
	status_panel.get_node("VBoxContainer/RES").text = "RES: " + str(member.res)
	status_panel.get_node("VBoxContainer/LUK").text = "LUK: " + str(member.luck)
	status_panel.get_node("VBoxContainer/EXP").text = "EXP: %d / %d" % [member.exp, member.exp_to_next]
	status_panel.get_node("VBoxContainer/TOTEXP").text = "TOTAL EXP: " + str(member.exp_total)

# === Equipment Functions ===
func _open_inventory(slot_type: String):
	item_panel.visible = true
	inven.show_with_filter(slot_type, func(selected_item: Item):
		_equip_item(slot_type, selected_item)
		get_current_character().equip_item(selected_item)
		
		preview_label.text = ""
		
		item_panel.visible = false
		equip_panel.visible = true
	, func(item: Item):
		_preview_stats(item))

func _preview_stats(item: Item):
	var char = get_current_character()
	if char == null:
		preview_label.text = ""
		return

	var preview_text = "Preview:\n"

	# Show weapon changes
	if item is Weapon:
		var new_str = char.str + item.atk
		preview_text += "STR: %d → %d\n" % [char.real_str, new_str]
		var new_mag = char.mag + item.mag
		preview_text += "MAG: %d → %d\n" % [char.real_mag, new_mag]
		var new_spd = char.spd + item.spd
		preview_text += "SPD: %d → %d\n" % [char.real_spd, new_spd]
		"""
	elif item is Armor:
		var new_end = char.end + item.def
		preview_text += "END: %d → %d\n" % [char.real_end, new_end]
		var new_res = char.res + item.res
		preview_text += "RES: %d → %d\n" % [char.real_res, new_res]
		var new_spd = char.spd + item.spd
		preview_text += "SPD: %d → %d\n" % [char.real_spd, new_spd]

	elif item is Item:
		var new_luck = char.luck + item.luck
		preview_text += "LUK: %d → %d\n" % [char.real_luck, new_luck]
		var new_hp = char.max_hp + item.hp_bonus
		preview_text += "HP: %d → %d\n" % [char.max_hp, new_hp]
		var new_mp = char.max_mp + item.mp_bonus
		preview_text += "MP: %d → %d\n" % [char.max_mp, new_mp]
		"""
	else:
		preview_text = "Cannot equip this item."

	preview_label.text = preview_text

func _equip_item(slot_type: String, item: Item):
	var char = get_current_character()
	if char == null:
		return

	# Remove the item being equipped from inventory
	Nventory.remove_item(item.name, 1)

	# Equip the item (may return something that was unequipped)
	var unequipped = char.equip_item(item)

	# If something was unequipped, add it back to inventory
	if unequipped:
		Nventory.add_item(unequipped)

	_update_stats()
	$InvenPanel/InventoryUI.update_inventory_display(Nventory)

func _update_stats():
	var char = get_current_character()
	if char == null:
		stats_label.text = "No party member."
		weapon_slot.text = "Empty"
		armor_slot.text = "Empty"
		accessory_slot.text = "Empty"
		return

	char.update_stats()
	stats_label.text = "Name: %s\nHP: %d/%d\nATK: %d\nDEF: %d\nSPD: %d\nMAG: %d\nEND: %d\nRES: %d\nLUK: %d" % [
		char.name, char.hp, char.max_hp,
		char.real_str, char.real_end, char.real_spd,
		char.real_mag, char.real_end, char.real_res, char.real_luck
	]

	weapon_slot.text = char.equipped_weapon.name if char.equipped_weapon else "Empty"
	armor_slot.text = char.equipped_armor.name if char.equipped_armor else "Empty"
	accessory_slot.text = char.equipped_accessory.name if char.equipped_accessory else "Empty"

func display_spells():
	magic_panel.visible = true
	panel.visible = false  

	var member = GameManage.party[current_party_index]

	mag_port.texture = member.portrait
	mag_name.text = member.name
	mag_hp.text = "HP: %d / %d" % [member.hp, member.max_hp]
	mag_mp.text = "MP: %d / %d" % [member.mp, member.max_mp]

	var magic_grid = magic_panel.get_node("MagicDisplay/MagicGrid")
	for child in magic_grid.get_children():
		child.queue_free()
	target_mag.visible = false

	var learned = member.get_learned_spells()
	var all_spells = member.spell_set.spells  # Dictionary { "Fire" : 3, "Cure" : 5 }

	var first_button: Button = null

	for spell_name in all_spells.keys():
		var required_level = all_spells[spell_name]
		var spell = SpellDB.get_spell(spell_name)

		if spell == null:
			continue

		var btn = Button.new()
		btn.text = spell.name
		btn.icon = spell.icon
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(120, 32)

		if member.level >= required_level:
			# ✅ Learned spell
			btn.disabled = false
			btn.pressed.connect(func():
				print("You selected:", spell.name)
				if spell.type == "Heal":
					show_target_panel(member, spell)
				else:
					print("Casting offensive spell: %s" % spell.name)
			)
			btn.focus_entered.connect(func():
				focus_sfx.play()
				desc.text = "%s: %s (MP: %d)" % [spell.name, spell.description, spell.cost]
			)
		else:
			# ❌ Locked spell
			btn.disabled = true
			btn.focus_entered.connect(func():
				focus_sfx.play()
				desc.text = "%s: Unlocks at Lv. %d" % [spell.name, required_level]
			)

		magic_grid.add_child(btn)

		if first_button == null and not btn.disabled:
			first_button = btn

	if first_button:
		first_button.grab_focus()

func show_target_panel(caster: Character, spell: Magic):
	current_spell = spell
	current_caster = caster
	target_all = false
	target_mag.visible = true
	update_target_panel()
	
	
	if target_mag.get_child_count() > 0:
		target_mag.get_child(0).grab_focus()

func update_target_panel():
	var target_panel = magic_panel.get_node("TargetPanel")
	target_panel.visible = true
	for child in target_panel.get_children():
		child.queue_free()


	if target_all:
		# Just one button: apply healing to all
		var btn = Button.new()
		btn.text = "Heal All"
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(160, 32)
		btn.pressed.connect(func():
			sfx.stream = current_spell.sound_effect
			sfx.play()
			for member in GameManage.party:
				var heal = (Math.calculate_healing(current_caster, current_spell)) / 2
				member.hp = min(member.hp + heal, member.max_hp)
				print("%s healed %s for %d HP (AoE)" % [current_caster.name, member.name, heal])
			target_panel.visible = false
		)
		target_panel.add_child(btn)
	else:
		# List individual party members
		for member in GameManage.party:
			var btn = Button.new()
			btn.text = member.name + " (HP: %d/%d)" % [member.hp, member.max_hp]
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.custom_minimum_size = Vector2(160, 32)
			btn.pressed.connect(func():
				sfx.stream = current_spell.sound_effect
				sfx.play()
				var heal = Math.calculate_healing(current_caster, current_spell)
				member.hp = min(member.hp + heal, member.max_hp)
				print("%s healed %s for %d HP" % [current_caster.name, member.name, heal])
				target_panel.visible = false
			)
			target_panel.add_child(btn)

	# Focus first button
	if target_panel.get_child_count() > 0:
		target_panel.get_child(0).grab_focus()

func get_current_character() -> Character:
	if GameManage.party.is_empty():
		return null
	return GameManage.party[current_party_index]

func cycle_party(direction: int):
	var party = GameManage.party
	if party.size() == 0:
		return

	current_party_index = (current_party_index + direction) % party.size()
	if current_party_index < 0:
		current_party_index = party.size() - 1
	if status_panel.visible == true:
		display_stats()
	elif magic_panel.visible == true:
		display_spells()
	elif equip_panel.visible == true:
		_update_stats()
"-------------------------------------------------------------------------------"
	
