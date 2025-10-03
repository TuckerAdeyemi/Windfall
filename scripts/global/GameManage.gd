# GameManager.gd
extends Node
class_name GameManager

@onready var pause_menu: PauseMenu = preload("res://pause_menu.tscn").instantiate()
@onready var particles: GPUParticles2D = pause_menu.get_node("Control/Particles")
@onready var Border: Panel = pause_menu.get_node("Border")
@onready var inventory = Inventory.new()

var player_stats = []
var party: Array[Character] = []     # Flynn, Serena, etc.
var enemy_group: Array[Enemy] = []  # Enemies in this battle
var gold: int = 0
var battle: bool = false

var total_game_time = 0.0  # Total time the game has been running (in seconds)
var game_start_time = 0.0

var last_scene_path: String = ""
var player_start_position: Vector2 = Vector2.ZERO
var defeated_enemy_path: NodePath = NodePath("")

var location: String = "Windfall Forest"

var panel: Panel

var flynn_path = "res://resources/characters/Flynn.tres"
var serena_path = "res://resources/characters/Serena.tres"
var victoria_path = "res://resources/characters/Victoria.tres"
var caelith_path = "res://resources/characters/Caelith.tres"

var flynn = load(flynn_path).duplicate() as Character
var serena = load(serena_path).duplicate() as Character
var victoria = load(victoria_path).duplicate() as Character
var caelith = load(caelith_path).duplicate() as Character



#THIS MAKES THE CODE RUN WHILE PAUSED, IF GAME MANAGER HAS FUTURE ISSUES THIS IS PROBABLY WHY
func _ready():
	add_child(pause_menu)
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel = pause_menu.get_node("Panel")
	panel.visible = false
	
	game_start_time = Time.get_ticks_msec() / 1000.0  # Record the start time in seconds
	print("Game started at: ", game_start_time)
	
	flynn.resource_path = flynn_path
	serena.resource_path = serena_path
	victoria.resource_path = victoria_path
	caelith.resource_path = caelith_path
	
	party = [flynn, serena]
	#party = [flynn, serena, victoria, micheal]

func reset():
	player_stats = {}
	party.clear()
	gold = 0
	
var flags = {}
var quests: Dictionary = {}

func set_flag(key: String, value):
	flags[key] = value

func get_flag(key: String) -> Variant:
	return flags.get(key, false)  # default to false
	
var game_loaded = false  # Flag to track if the game has been loaded

var time_since_load = 0.0  # Variable to store time passed since loading

func _process(delta):
	if not game_loaded:  # Flag to check if the game is loaded
		# This is the normal calculation when not loading
		total_game_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
	else:
		# When game is loaded, accumulate delta time without overwriting total_game_time
		time_since_load += delta
		total_game_time += delta  # Add delta to the previously loaded game time
	
	# Update playtime display
	update_playtime_display()
	if pause_menu.visible:
		pause_menu.update_playtime_display(total_game_time)
	

func update_playtime_display():
	var minutes = int(total_game_time / 60)
	var seconds = int(total_game_time) % 60
	#time_display.text = "Play Time: %02d:%02d" % [minutes, seconds]
	
#opens the pause menu, except in battles where it is disabled. Will modify later to be more general.
func _unhandled_input(event):
	if event.is_action_pressed("Menu") and !(is_game_paused) and !(battle):
		toggle_pause_menu()
		pause_menu.set_initial_focus()
	elif event.is_action_pressed("Back") and pause_menu.visible and !(battle):
		if not panel.visible:
			# If we're in a submenu like status or inventory, go back to main menu
			return_to_main_panel()
		else:
			# Already on main menu, close pause menu
			toggle_pause_menu()
	if event.is_action_pressed("EXP"):
		Character.grant_exp_to_party(1000000)
		pause_menu.show_party(party)
	if event.is_action_pressed("LevelUp"):
		level_up_party()
		pause_menu.show_party(party)
	if event.is_action_pressed("ADDVIC"):
		party.append(victoria)
		party.append(caelith)
		pause_menu.show_party(party)
	if event.is_action_pressed("KILLVIC"):
		party.erase(victoria)
		party.erase(caelith)
		pause_menu.show_party(party)

func level_up_party():
	for member in party:
		# Optional: Skip dead members
		# if member.hp > 0:
		member.level_up()

var is_game_paused := false

func update_location():
	pause_menu.location.text = "Location: " + location
	
func displaygold():
	pause_menu.gold_display.text = "Gold: %d" % [gold]

func add_quest(quest: Quest):
	if !quests.has(quest.id):
		quests[quest.id] = {
			"quest": quest,
			"progress": {},
			"completed": false
		}

func complete_quest(id: String):
	if quests.has(id):
		quests[id]["completed"] = true
		# handle rewards
		var rewards = quests[id]["quest"].rewards
		if rewards.has("gold"):
			gold += rewards["gold"]
			displaygold()
		if rewards.has("item"):
			Nventory.add_item(ItemDB.get_item(rewards["item"]))

#Changed it from pause_menu to panel. May cause issues later.
func toggle_pause_menu():
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	panel.visible = is_game_paused
	#add_child(pause_menu)
	update_pause()
	
	if is_game_paused:
		pause_menu.show_party(party)
		particles.emitting = true
		Border.visible = true
		particles.restart()
	else:
		particles.emitting = false
		particles.restart()
		Border.visible = false
	return

func update_pause():
	if not pause_menu:
		return
	
	var party_list = pause_menu.get_node("Panel/HBox/PartyDisplay")
	for player_node in party_list.get_children():
		reset_player_node(player_node)
	
func reset_player_node(player_node: Node):
	var name_label = player_node.get_node("VBox/Name")
	var title_label = player_node.get_node("VBox/Title")
	var lvl_label = player_node.get_node("VBox/Level")
	var hp_label = player_node.get_node("VBoxContainer/HP")
	var mp_label = player_node.get_node("VBoxContainer/MP")
	var exp_label = player_node.get_node("VBoxContainer/EXP")
	var portrait = player_node.get_node("Portrait")

	name_label.text = ""
	title_label.text = ""
	lvl_label.text = ""
	hp_label.text = ""
	mp_label.text = ""
	exp_label.text = ""
	portrait.texture = null

func return_to_main_panel():
	# Are we in the Equip workflow? (inventory opened from equip panel)
	if pause_menu.get_node("InvenPanel").visible and pause_menu.get_node("EquipPanel").visible:
		# Just close inventory, stay in Equip
		pause_menu.get_node("InvenPanel").visible = false
		pause_menu.get_node("InvenPanel/InventoryUI").visible = false

		# Reset preview text
		var preview = pause_menu.get_node("EquipPanel/HBoxContainer/VBoxContainer2/PreviewLabel")
		if preview:
			preview.text = ""

		# Keep focus on equip menu
		pause_menu._update_stats()
		return

	# === Otherwise go back to main menu ===
	pause_menu.show_party(party)
	pause_menu.panel.visible = true

	# Hide sub-panels
	pause_menu.get_node("StatusPanel").visible = false
	pause_menu.get_node("InvenPanel/InventoryUI").visible = false
	pause_menu.get_node("MagicPanel").visible = false
	pause_menu.get_node("SettingPanel").visible = false
	pause_menu.get_node("EquipPanel").visible = false
	pause_menu.get_node("QuestPanel").visible = false
	pause_menu.get_node("InvenPanel").visible = false
	pause_menu.get_node("SavePanel").visible = false

	# Clear preview text
	var preview = pause_menu.get_node("EquipPanel/HBoxContainer/VBoxContainer2/PreviewLabel")
	if preview:
		preview.text = ""

	# Reset focus to main menu buttons
	pause_menu.set_initial_focus()

func save_game(slot: int):
	var player = get_tree().current_scene.get_node("Player")
	var save_data = {
		"player_position": { "x": player.global_position.x, "y": player.global_position.y},
		"gold": gold,
		"party": [],
		"inventory": Nventory.to_array(),
		"flags": flags,
		"playtime": total_game_time
	}

	# Save party members' data
	for member in party:
		var character_data = {
			"resource_path": member.resource_path,  # Path to the .tres file
			"level": member.level,
			"hp": member.hp,
			"max_hp": member.max_hp,
			"mp": member.mp,
			"max_mp": member.max_mp,
			"str": member.str,
			"mag": member.mag,
			"end": member.end,
			"spd": member.spd,
			"res": member.res,
			"luck": member.luck,
			"exp": member.exp,
			"exp_to_next": member.exp_to_next,
			"exp_total": member.exp_total,
			
			"str_accum": member.str_accum,
			"mag_accum": member.mag_accum,
			"spd_accum": member.spd_accum,
			"end_accum": member.end_accum,
			"res_accum": member.res_accum,
			"luck_accum": member.luck_accum,
			"hp_accum": member.hp_accum,
			"mp_accum": member.mp_accum,
		}
		save_data["party"].append(character_data)

	# Save inventory


	# Write to file
	var path = "user://savegame_%d.json" % slot
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game saved to slot %d!" % slot)

func load_game(slot: int):
	var path = "user://savegame_%d.json" % slot
	if not FileAccess.file_exists(path):
		print("No save file in slot %d" % slot)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		print("Failed to load save slot %d" % slot)
		return false

	# Restore gold, flags, etc.
	gold = data["gold"]
	flags = data.get("flags", {})
	for chest in get_tree().get_nodes_in_group("chests"):
		chest.refresh_state()
	Nventory.from_array(data.get("inventory", []))
	total_game_time = data["playtime"]

	# Restore player position
	var player = get_tree().current_scene.get_node("Player")
	player.global_position = Vector2(data["player_position"]["x"], data["player_position"]["y"])

	# Restore party
	party.clear()
	for char_data in data["party"]:
		var char_res = load(char_data["resource_path"])
		var char = char_res.duplicate()
		char.level = char_data["level"]
		char.hp = char_data["hp"]
		char.max_hp = char_data["max_hp"]
		char.mp = char_data["mp"]
		char.max_mp = char_data["max_mp"]
		char.str = char_data["str"]
		char.mag = char_data["mag"]
		char.end = char_data["end"]
		char.spd = char_data["spd"]
		char.res = char_data["res"]
		char.luck = char_data["luck"]
		char.exp = char_data["exp"]
		char.exp_to_next = char_data["exp_to_next"]
		char.exp_total = char_data["exp_total"]
		
		char.str_accum = char_data["str_accum"]
		char.mag_accum = char_data["mag_accum"]
		char.spd_accum = char_data["spd_accum"]
		char.end_accum = char_data["end_accum"]
		char.res_accum = char_data["res_accum"]
		char.luck_accum = char_data["luck_accum"]
		char.hp_accum = char_data["hp_accum"]
		char.mp_accum = char_data["mp_accum"]
		party.append(char)

	# Restore inventor

	print("Game loaded from slot %d!" % slot)
	return true
