extends CanvasLayer

@export var party_list: VBoxContainer  # VBoxContainer inside the main panel
@export var enemy_list: VBoxContainer
@export var base_font: Font 
@export var highlight_color: Color = Color(1, 1, 0)  # Yellow for current turn
@export var normal_color: Color = Color(1, 1, 1)     # White for idle text
@export var command_panel: Panel
@export var commands = ["Attack", "Skill", "Magic", "Defend", "Item"]
@onready var battle_manager = get_parent().get_node("BattleManager")
@onready var DamageNumberScene = $DamagePopUp/DamageNumber
@onready var magic_panel = $MagicPanel
@onready var focus_sfx = $AudioStreamPlayer2D
@onready var desc = $MagicPanel/MagicDisplay/Description

signal command_chosen(command_name)
signal target_chosen(target_node)
signal magic_chosen(magic_node)

var current_command: String = ""
var selecting_command := true
var selecting_target := false
var targeting_party = false

var target = null

var selected_enemy_index := 0
var selected_party_index = 0

var first_button: Button = null

var selecting_magic := false
var came_from_magic := false

var battler_backup = null

var backuppnode = null

func _ready():
	var list := command_panel.get_node("ScrollContainer/CommandList") as VBoxContainer

	# Clear existing buttons
	for child in list.get_children():
		child.queue_free()

	
	# Create one Button per command
	
	for cmd in commands:
		var btn := Button.new()
		btn.text = cmd
		
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.custom_minimum_size = Vector2(220, 24)
		btn.connect("pressed", Callable(self, "_on_command_button_pressed").bind(btn.text))


		list.add_child(btn)
		if first_button == null:
			first_button = btn
		btn.connect("focus_entered", Callable(self, "_on_command_focus").bind(btn))

		
	current_command = commands[0]  # Default to first command
	_update_command_selection()
	first_button.grab_focus()
	enemy_list.focus_mode = Control.FOCUS_ALL
	
func _on_command_focus(button: Button):
	current_command = button.text
	_update_command_selection()
	
func _switch_target_group():
	targeting_party = !targeting_party
	if targeting_party:
		if party_list.get_child_count() == 0:
			# fallback if no party members
			targeting_party = false
			return
		selected_party_index = 0
		_update_party_selection()
		party_list.grab_focus()
	else:
		if enemy_list.get_child_count() == 0:
			# fallback if no enemies
			targeting_party = true
			return
		selected_enemy_index = 0
		_update_enemy_selection()
		enemy_list.grab_focus()

func _unhandled_input(event):
	if selecting_target:
		if event.is_action_pressed("ui_down"):
			if targeting_party:
				selected_party_index = (selected_party_index + 1) % party_list.get_child_count()
				_update_party_selection()
			else:
				selected_enemy_index = (selected_enemy_index + 1) % enemy_list.get_child_count()
				_update_enemy_selection()
			
		elif event.is_action_pressed("ui_up"):
			if targeting_party:
				selected_party_index = (selected_party_index - 1 + party_list.get_child_count()) % party_list.get_child_count()
				_update_party_selection()
			else:
				selected_enemy_index = (selected_enemy_index - 1 + enemy_list.get_child_count()) % enemy_list.get_child_count()
				_update_enemy_selection()
		elif event.is_action_pressed("ui_accept"):
			_attack_selected_target()
		elif event.is_action_pressed("Back"):
			if came_from_magic:
				display_spells(battler_backup.character_data)
				selecting_magic = true
				came_from_magic = false  # Reset for safety
				_clear_enemy_selection()
				selected_enemy_index = 0
			else:
				command_panel.visible = true
				selecting_command = true
				_clear_enemy_selection()
				selected_enemy_index = 0
				if first_button:
					first_button.grab_focus()
		elif event.is_action_pressed("Swap"):
			_switch_target_group()
	elif selecting_magic:
		if event.is_action_pressed("Back"):
			selecting_magic = false
			magic_panel.visible = false
			command_panel.visible = true
			selecting_command = true
			if first_button:
				first_button.grab_focus()
		
func _on_command_button_pressed(command_name):
	current_command = command_name
	print("Command selected:", current_command)
	_update_command_selection()

	selecting_command = false  # Move from _unhandled_input
	emit_signal("command_chosen", current_command)

	if command_name == "Attack":
		_show_enemy_target_selection()
		selecting_target = true
	
func _update_command_selection():
	var list := command_panel.get_node("ScrollContainer/CommandList") as VBoxContainer
	for btn in list.get_children():
		btn.modulate = highlight_color if btn.text == current_command else normal_color

func _show_enemy_target_selection():
	if enemy_list.get_child_count() == 0:
		print("No enemies to select!")
		return
	selecting_target = true
	selected_enemy_index = 0
	_update_enemy_selection()
	enemy_list.grab_focus()
	# clear focus from command buttons

func _update_enemy_selection():
	for i in range(enemy_list.get_child_count()):
		var enemy_row = enemy_list.get_child(i)
		if i == selected_enemy_index:
			enemy_row.modulate = highlight_color
		else:
			enemy_row.modulate = normal_color

func _update_party_selection():
	for i in range(party_list.get_child_count()):
		var party_row = party_list.get_child(i)
		if i == selected_party_index:
			party_row.modulate = highlight_color
		else:
			party_row.modulate = normal_color

func populate_party_ui(party: Array, partynodes: Array, current_turn: int = -1):
	# Clear existing rows
	for child in party_list.get_children():
		child.queue_free()
	backuppnode = partynodes
	
	for i in party.size():
		var member = party[i]
		var mem = partynodes[i]
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10) 

		# Labels
		var name_label = Label.new()
		var hp_label = Label.new()
		var mp_label = Label.new()

		# Set text
		name_label.text = member.name
		hp_label.text = "HP: %d / %d" % [member.hp, member.max_hp]
		mp_label.text = "MP: %d / %d" % [member.mp, member.max_mp]
	
		# Apply base font if available
		#if base_font != null:
		#	name_label.add_theme_font_override("font", base_font)
		#	hp_label.add_theme_font_override("font", base_font)
		#	mp_label.add_theme_font_override("font", base_font)

		# Color logic:
		# Highlight entire row if it's this member's turn
		var text_color = normal_color
		if i == current_turn:
			text_color = highlight_color

		name_label.modulate = text_color

		# HP color based on percentage
		var hp_ratio = float(member.hp) / float(member.max_hp)
		if hp_ratio > 0.3:
			hp_label.modulate = Color(1, 1, 1)  # Green
		elif hp_ratio > 0:
			hp_label.modulate = Color(1, 1, 0)  # Yellow
		else:
			hp_label.modulate = Color(1, 0, 0)  # Red
		
		# If current turn, override HP color with highlight as well
		if i == current_turn:
			hp_label.modulate = highlight_color

		mp_label.modulate = text_color
	
		# Optional: Align name to left, stretch the space after
		name_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

		# Add labels and spacers
		row.add_child(name_label)

		var big_spacer = Control.new()
		big_spacer.size_flags_horizontal = Control.SIZE_EXPAND
		row.add_child(big_spacer)

		row.add_child(hp_label)

		var small_spacer = Control.new()
		small_spacer.custom_minimum_size.x = 8
		row.add_child(small_spacer)

		row.add_child(mp_label)

		party_list.add_child(row)
		row.set_meta("party_node", mem)
		
	
func populate_enemy_ui(enemies: Array):
	
	# Clear existing entries
	for child in enemy_list.get_children():
		child.queue_free()

	for enemy in enemies:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var name_label = Label.new()
		name_label.text = enemy.character_data.name

	#	if enemy_font:
	#		name_label.add_theme_font_override("font", enemy_font)
	#		hp_label.add_theme_font_override("font", enemy_font)

		row.add_child(name_label)
		enemy_list.add_child(row)
		
		row.set_meta("enemy_node", enemy)

func prompt_player_action(battler) -> void:
	#print("Prompting action for ", battler.character_data.name)
	battler_backup = battler
	# Show command panel and enable input
	command_panel.visible = true
	if first_button != null:
		first_button.grab_focus()
	
	selecting_command = true
	selecting_target = false
	current_command = commands[0]  # optional, useful to re-highlight "Attack"
	_update_command_selection()
	
	# Wait for player to select a command (await returns the signal arguments as an array)
	await command_chosen
	var command = current_command 
	
	if command == "Attack":
		# Show enemy targets and wait for selection
		_show_enemy_target_selection()
		var target = await target_chosen
		print("%s attacks %s!" % [battler.character_data.name, target.character_data.name])
		var truedamage = Math.attack(battler.character_data, target.character_data)
		if truedamage < 0:
			truedamage = 0
		target.character_data.hp -= truedamage
		show_damage_number(target.global_position + Vector2(0, -80), truedamage)
		print("%s took %d damage! It's at %d HP now!"% [target.character_data.name, truedamage, target.character_data.hp])
		populate_party_ui(GameManage.party, backuppnode)
		if target.character_data.hp <= 0:
			target.die()
			on_enemy_death(target)
			battle_manager.remove_dead_from_turn_queue()
			
	if command == "Magic":
		print("%s is casting magic!" % battler.character_data.name)
		display_spells(battler.character_data)
		var magic = await magic_chosen
		print("Whoa! %s is a pretty strong spell!" % magic.name)
		if magic.type == "Damage":
			came_from_magic = true
			_show_enemy_target_selection()
			var target = await target_chosen
			came_from_magic = false
			
			var damage = Math.calculate_damage(battler.character_data, magic, target.character_data)
			target.character_data.hp -= damage
			show_damage_number(target.global_position + Vector2(0, -80), damage)
			print("It took %d damage! It's at %d HP now!"% [damage, target.character_data.hp])
			populate_party_ui(GameManage.party, backuppnode)
			if target.character_data.hp <= 0:
				target.die()
				on_enemy_death(target)
				battle_manager.remove_dead_from_turn_queue()
		elif magic.type == "Heal":
			came_from_magic = true
			_show_enemy_target_selection()
			var target = await target_chosen
			came_from_magic = false
			
			var heal = Math.calculate_healing(battler.character_data, magic)
			target.character_data.hp += min(heal, target.character_data.max_hp - target.character_data.hp)
			show_damage_number(target.global_position + Vector2(0, -80), heal)
			print("%s healed %s for %d HP." % [battler.character_data.name, target.character_data.name, heal])
			populate_party_ui(GameManage.party, backuppnode)
	else:
		print("Not implemented yet.")
	command_panel.visible = false
	battle_manager.check_battle_end()
	battle_manager.next_turn()
	
func on_enemy_death(dead_enemy_node: Node):
	for row in enemy_list.get_children():
		if row.has_meta("enemy_node") and row.get_meta("enemy_node") == dead_enemy_node:
			enemy_list.remove_child(row)
			row.queue_free()
			break
	
func _attack_selected_target():
	if not selecting_target:
		return

	selecting_target = false

	if targeting_party:
		var party_row = party_list.get_child(selected_party_index)
		var party_node = party_row.get_meta("party_node")

		if party_node.character_data.hp <= 0:
			print("Selected party member is already dead.")
			return

		_clear_party_selection()
		emit_signal("target_chosen", party_node)
	else:
		var enemy_row = enemy_list.get_child(selected_enemy_index)
		var enemy_node = enemy_row.get_meta("enemy_node")

		if enemy_node.character_data.hp <= 0:
			print("Selected enemy is already dead.")
			return

		_clear_enemy_selection()
		emit_signal("target_chosen", enemy_node)

func _clear_party_selection():
	for i in range(party_list.get_child_count()):
		var row = party_list.get_child(i)
		row.modulate = normal_color

func _clear_enemy_selection():
	for i in range(enemy_list.get_child_count()):
		var row = enemy_list.get_child(i)
		row.modulate = normal_color

func show_damage_number(position: Vector2, amount: int):
	DamageNumberScene.position = position
	DamageNumberScene.show_damage(amount)

func display_spells(member: Character):
	selecting_magic = true
	magic_panel.visible = true
	
	# === Clear old spell buttons ===
	var magic_grid = magic_panel.get_node("MagicDisplay/MagicGrid")  # Adjust to your actual node path
	for child in magic_grid.get_children():
		child.queue_free()

	# === Get spells ===
	var spells = member.get_learned_spells()

	var first_button: Button = null

	# === Create buttons for each spell ===
	for spell in spells:
		var btn = Button.new()
		btn.text = spell.name + " (MP: " + str(spell.cost) + ") "
			# Scale down the icon
		var icon_texture = spell.icon
		if icon_texture and icon_texture is Texture2D:
			var image = icon_texture.get_image()
			image.resize(24, 24, Image.INTERPOLATE_LANCZOS)
			var new_texture = ImageTexture.create_from_image(image)
			btn.icon = new_texture
		#btn.icon = spell.icon
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(60, 32)
		# Optional: Apply a font override
		#if base_font:
		#	btn.add_theme_font_override("font", base_font)
		btn.set_meta("spell_data", spell)
		if Math.check_mp(member, spell) == false:
			btn.modulate = Color(0.5, 0.5, 0.5, 1)
			btn.disabled = true
		# Store spell info for callbacks
		else:
			btn.pressed.connect(func():
				print("You selected:", spell.name)
				if Math.check_mp(member, spell) == false:
					print("Not enough MP to cast %s!" % spell.name)
					# Optionally play error sound or shake
					return
				emit_signal("magic_chosen", spell)
				selecting_magic = false
				if spell.type == "Heal":
					#show_target_panel(member, spell)
					print("Healing for %d." % Math.calculate_healing(member, spell))
					populate_party_ui(GameManage.party, backuppnode)
				if spell.type == "Damage":
					populate_party_ui(GameManage.party, backuppnode)
				if spell.type == "Buff":
					emit_signal("magic_chosen", spell)
				if spell.type == "Debuff":
					emit_signal("magic_chosen", spell)
					magic_panel.visible = false
				if spell.type == "Status":
					emit_signal("magic_chosen", spell)
				else:
					print("Casting offensive spell: %s" % spell.name)
				magic_panel.visible = false
			)
		btn.focus_entered.connect(func():
			focus_sfx.play()
			desc.text = "%s" % spell.description
		)
		magic_grid.add_child(btn)
		
		if first_button == null:
			first_button = btn
			
		if first_button:
			await get_tree().process_frame  # Wait one frame
			first_button.grab_focus()

"""
Break if needed.
		if target is Resource:
			print("does this even get used?")
			print("%s attacks %s!" % [battler.character_data.name, target.name])
			var truedamage = Math.attack(battler.character_data, target)
			if truedamage < 0:
				truedamage = 0
			target.hp -= truedamage
			var party_row = party_list.get_child(selected_party_index)
			var party_resource = party_row.get_meta("party_node")
			var party_node = party_row
			show_damage_number(battler.global_position + Vector2(0, -80), truedamage)
			print("%s took %d damage! It's FUCK  at %d HP now!"% [target.name, truedamage, target.hp])
			populate_party_ui(GameManage.party, backuppnode)
			if target.hp <= 0:
				party_node.die()
				on_enemy_death(target)
				battle_manager.remove_dead_from_turn_queue()
		else:
"""
