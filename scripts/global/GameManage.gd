# GameManager.gd
extends Node
class_name GameManager

@onready var pause_menu: PauseMenu = preload("res://pause_menu.tscn").instantiate()
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
	print("Game started at:", game_start_time)
	
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
	if event.is_action_pressed("Enter") and !(is_game_paused) and !(battle):
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
	if event.is_action_pressed("LevelUp"):
		level_up_party()
	if event.is_action_pressed("ADDVIC"):
		party.append(victoria)
		party.append(caelith)
	if event.is_action_pressed("KILLVIC"):
		party.erase(victoria)
		party.erase(caelith)
		print("are they dead?")
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
	
#Toggles the pause menu
#Changed it from pause_menu to panel. May cause issues later.
func toggle_pause_menu():
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	panel.visible = is_game_paused
	add_child(pause_menu)
	update_pause()
	if is_game_paused:
		pause_menu.show_party(party)
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
	# Show main panel
	pause_menu.panel.visible = true
	
	# Hide sub-panels
	pause_menu.get_node("StatusPanel").visible = false
	pause_menu.get_node("InvenPanel").visible = false
	pause_menu.get_node("MagicPanel").visible = false
	# Add more if you have others, like pause_menu.get_node("Panel/EquipPanel").visible = false

	# Reset focus to main menu buttons
	pause_menu.set_initial_focus()

func save_game():
	var player = get_tree().current_scene.get_node("Player")
	var save_data = {
		"player_position": { "x": player.global_position.x, "y": player.global_position.y},
		"gold": gold,
		"party": [],
		"inventory": [],
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
	for item in inventory.items:
		save_data["inventory"].append({
			"name": item.name,
			"amount": item.amount
		})

	# Write to file
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game Saved!")

func load_game():
	if not FileAccess.file_exists("user://savegame.json"):
		print("No save file found.")
		return

	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()

	#Restore basic values
	gold = save_data.get("gold", 0)
	total_game_time = save_data.get("playtime", 0.0)
	var player = get_tree().current_scene.get_node("Player")
	var pos_data = save_data["player_position"]
	player.global_position = Vector2(pos_data["x"], pos_data["y"])


	#Restore party
	party.clear()
	for character_data in save_data["party"]:
		print("Loading resource:", character_data["resource_path"])
		var character = load(character_data["resource_path"]).duplicate()
		
		# Restore all saved stats
		character.level = character_data["level"]
		character.hp = character_data["hp"]
		character.max_hp = character_data["max_hp"]
		character.mp = character_data["mp"]
		character.max_mp = character_data["max_mp"]
		character.str = character_data["str"]
		character.mag = character_data["mag"]
		character.end = character_data["end"]
		character.spd = character_data["spd"]
		character.res = character_data["res"]
		character.luck = character_data["luck"]
		character.exp = character_data["exp"]
		character.exp_to_next = character_data["exp_to_next"]
		character.exp_total = character_data["exp_total"]
		
		character.str_accum = character_data["str_accum"]
		character.mag_accum = character_data["mag_accum"]
		character.spd_accum = character_data["spd_accum"]
		character.end_accum = character_data["end_accum"]
		character.res_accum = character_data["res_accum"]
		character.luck_accum = character_data["luck_accum"]
		character.hp_accum = character_data["hp_accum"]
		character.mp_accum = character_data["mp_accum"]
		
		# Add to party
		party.append(character)


	# Restore inventory
	inventory.items.clear()
	#for item_data in save_data["inventory"]:
	#	var item = ItemDB.get_item(item_data["name"]).duplicate()  # You may need an item database
	#	item.amount = item_data["amount"]
	#	inventory.items.append(item)
	
	#is_game_paused = false
	#get_tree().paused = false
	#pause_menu.panel.visible = false
	
	update_playtime_display()

	game_loaded = true

	print("Game Loaded!")




