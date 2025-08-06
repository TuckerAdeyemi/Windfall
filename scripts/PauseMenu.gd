extends CanvasLayer

class_name PauseMenu

#Left side of Menu
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
@onready var status_panel = $StatusPanel
@onready var magic_panel = $MagicPanel

@onready var mag_port = $MagicPanel/MagicDisplay/TopInfo/Portrait
@onready var mag_name = $MagicPanel/MagicDisplay/TopInfo/InfoBox/Name
@onready var mag_hp = $MagicPanel/MagicDisplay/TopInfo/InfoBox/HPLabel
@onready var mag_mp = $MagicPanel/MagicDisplay/TopInfo/InfoBox/MPLabel
@onready var desc = $MagicPanel/MagicDisplay/Description
@onready var target_mag = $MagicPanel/TargetPanel



#Right side of Menu
#@onready var container = $Panel/PartyDisplay
@onready var party_display = $Panel/HBox/PartyDisplay

@onready var focus_sfx = $AudioStreamPlayer2D
@onready var sfx = $SoundEffects

@onready var potion = preload("res://items/potion.tres")
@onready var ass = preload("res://items/Antidote.tres")

@onready var parties = GameManage.party

#for magic scope
var target_all := false
var current_spell: Magic = null
var current_caster: Character = null

func _ready():
	item_panel.visible = false
	status_panel.visible = false
	magic_panel.visible = false
	GameManage.update_location()
	GameManage.displaygold()
	$InvenPanel/InventoryUI.update_inventory_display(Nventory)
	for button in $Panel/HBox/VBoxContainer.get_children():
		if button is Button:
			button.focus_entered.connect(play_focus_sfx)
			

	
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
		print("GET DUNKED ONNNNNNNNNNNNNNNNNNNN")
		move_focus_down()
	elif event.is_action_pressed("Enter"):
		trigger_selected_button()
		focus_sfx.play()
	elif event.is_action_pressed("Scroll Left"):
		if status_panel.visible or magic_panel.visible:
			cycle_party(-1)
			focus_sfx.play()
	elif event.is_action_pressed("Scroll Right"):
		if status_panel.visible or magic_panel.visible:
			cycle_party(1)
			focus_sfx.play()
	if event.is_action_pressed("Toggle Scope"):  # You can bind this to Tab in Input Map
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
		print("Items")
		#Nventory.add_item(potion)
		#Nventory.add_item(ass)
		#$InvenPanel/InventoryUI.update_inventory_display(Nventory)
		#panel.visible = false
	elif focused == button_magic:
		magic_panel.visible = true
		display_spells()
	elif focused == button_equip:
		print("Equip")
	elif focused == button_status:
		display_stats()
	elif focused == button_quests:
		print("You have no quests.")
	elif focused == button_config:
		print("Config")
	elif focused == button_save:
		print("Save")
		GameManage.save_game()
	elif focused == button_load:
		print("Load")
		GameManage.load_game()

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


func display_spells():
	magic_panel.visible = true
	panel.visible = false  # Hide main menu buttons
	
	var member = GameManage.party[current_party_index]
	
	mag_port.texture = member.portrait
	mag_name.text = member.name
	mag_hp.text = "HP: %d / %d" % [member.hp, member.max_hp]
	mag_mp.text = "MP: %d / %d" % [member.mp, member.max_mp]
	
	# === Clear old spell buttons ===
	var magic_grid = magic_panel.get_node("MagicDisplay/MagicGrid")  # Adjust to your actual node path
	for child in magic_grid.get_children():
		child.queue_free()
	target_mag.visible = false


	# === Get spells ===
	var spells = member.get_learned_spells()

	var first_button: Button = null

	# === Create buttons for each spell ===
	for spell in spells:
		var btn = Button.new()
		btn.text = spell.name
		btn.icon = spell.icon
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(120, 32)
		# Optional: Apply a font override
		#if base_font:
		#	btn.add_theme_font_override("font", base_font)

		# Store spell info for callbacks
		btn.set_meta("spell_data", spell)
		# Handle clicks
		btn.pressed.connect(func():
			print("You selected:", spell.name)
			if spell.type == "Heal":
				show_target_panel(member, spell)
			else:
				print("Casting offensive spell: %s" % spell.name)
			# Optionally: show spell description, cost, or targeting preview here 
		)
		btn.focus_entered.connect(func():
			focus_sfx.play()
			desc.text = "%s: %s (MP: %d)" % [spell.name, spell.description, spell.cost]
		)
		magic_grid.add_child(btn)
		
		if first_button == null:
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
		
"-------------------------------------------------------------------------------"
	
