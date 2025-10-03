extends Node

@onready var player_area = get_parent().get_node("PlayerArea")
@onready var enemy_area = get_parent().get_node("EnemyArea")
@onready var battle_ui = get_parent().get_node("BattleUI")
@onready var music = get_parent().get_node("BattleMusic")
@onready var gomusic = get_parent().get_node("GameOverMusic")
@onready var turn_queue_ui = get_parent().get_node("TurnQueueUI")
@onready var VicDes = get_parent().get_node("VictoryDesc")
@onready var VicBor = get_parent().get_node("VictoryBorder")
@onready var fader = get_parent().get_node("ColorRect")
@onready var VicLab = get_parent().get_node("VictoryDesc/VictoryLabel")
@export var fade: = ColorRect

var turn_pointer_scene = preload("res://scenes/TurnPointer.tscn")
var turn_pointer: Node2D

var battle_character_scene = preload("res://battle/BattleCharacter.tscn")
var enemy_scene = preload("res://battle/enemy_spawn.tscn")
var turn_queue: Array = []
var battlers: Array = []
var current_turn_index = 0

var enemy_nodes: Array = []
var party_nodes: Array = []	

var party = GameManage.party
var enemies = GameManage.enemy_group

var party_alive: bool = true

func _ready():
	GameManage.battle = true

	# === Spawn party ===
	for i in party.size():
		var player_data = party[i]
		var player_instance = battle_character_scene.instantiate()
		player_instance.set_character(player_data)

		var spawn_point = player_area.get_child(i)
		player_instance.position = spawn_point.global_position
		add_child(player_instance)
		
		battlers.append(player_instance)
		party_nodes.append(player_instance)

	# === Spawn enemies ===
	for i in enemies.size():
		var enemy_data = enemies[i]
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.set_character(enemy_data)

		var spawn_point = enemy_area.get_child(i)
		enemy_instance.position = spawn_point.global_position
		add_child(enemy_instance)
		
		battlers.append(enemy_instance)
		enemy_nodes.append(enemy_instance)
		
	if enemies.size() > 0 and enemies[0].battle_theme and party_alive:
		music.stream = enemies[0].battle_theme
		music.play()
	# === Update Battle UI ===
	battle_ui.populate_party_ui(party, party_nodes)
	battle_ui.populate_enemy_ui(enemy_nodes)
	turn_pointer = turn_pointer_scene.instantiate()
	add_child(turn_pointer)
	turn_pointer.visible = false  # hide until first turn
	build_turn_queue()
	process_turn()

func build_turn_queue():
	turn_queue.clear()
	for child in get_children():
		if child.has_method("get_character_data"):
			var char_data = child.get_character_data()
			if char_data.hp > 0:
				var effective_spd = char_data.spd
				for effect in char_data.status_effects:
					if effect.type == "spd_mod":
						effective_spd *= effect.multiplier
				turn_queue.append({
					"battler": child,
					"speed": effective_spd,
					"delay": 0
				})
				
	sort_turn_queue_by_speed()

	current_turn_index = 0
	 	
	turn_queue_ui.update_queue(turn_queue, current_turn_index)

	# Update the turn UI
	#turn_queue_ui.update_queue(turn_queue, current_turn_index)

func apply_delay(battler, delay_amount):
	for entry in turn_queue:
		if entry["battler"] == battler:
			entry["delay"] += delay_amount
			break
	
	# Re-sort the queue based on delay and speed
	turn_queue.sort_custom(sort_by_delay_and_speed)

func sort_turn_queue_by_speed():
	for i in range(turn_queue.size()):
		for j in range(i + 1, turn_queue.size()):
			if turn_queue[j]["speed"] > turn_queue[i]["speed"]:
				var temp = turn_queue[i]
				turn_queue[i] = turn_queue[j]
				turn_queue[j] = temp

var sort_by_delay_and_speed = func(a, b):
	if a["delay"] == b["delay"]:
		return b["speed"] - a["speed"]
	return a["delay"] - b["delay"]

func sort_by_speed(a, b):
	return b["speed"] - a["speed"]

func get_current_turn():
	if turn_queue.size() == 0:
		print("Turn queue is empty!")
		return null  # or handle no-turn case gracefully
	
	return turn_queue[current_turn_index]

func next_turn():
	# Optionally reduce delay or reset speed if dynamic
	var any_party_alive = false
	for party in GameManage.party:
		if party.hp > 0:
			any_party_alive = true
			
	if any_party_alive == false:
		await get_tree().create_timer(10000.0).timeout
		
	var finished = turn_queue.pop_front()
	turn_queue.append(finished)
	current_turn_index = 0  # reset to front since you popped
	turn_queue_ui.update_queue(turn_queue, current_turn_index)
	process_turn()
	
func process_turn():
	var current = get_current_turn()
	if current == null:
		print("No battler to process!")
		return
		
	var battler = current["battler"]
	
	process_damage_effects(battler)
	battle_ui.populate_party_ui(party, party_nodes)

	var pointer_offset = Vector2(0, -80)  # Adjust as needed
	turn_pointer.global_position = battler.global_position + pointer_offset
	turn_pointer.visible = true
	
	
	
	if battler.character_data.hp <= 0:
		next_turn()
		return
		
	print("It's %s's turn" % battler.character_data.name)
	# Let current battler act
	if battler.character_data.is_player:
		battle_ui.prompt_player_action(battler)
		await get_tree().create_timer(0.1).timeout
		
	else:
		await battler.run_ai(self)
		await get_tree().create_timer(0.1).timeout
		process_damage_effects(battler)
		battle_ui.populate_party_ui(party, party_nodes)
		check_battle_end()
		next_turn()
	
	# Advance the queue
func remove_dead_from_turn_queue():
	var original_count = turn_queue.size()

	# Remove entries where the battler's HP is 0 or less
	turn_queue = turn_queue.filter(func(entry):
		return entry["battler"].character_data.hp > 0
	)

	# Clamp the turn index in case it now points past the new list
	current_turn_index = clamp(current_turn_index, 0, max(0, turn_queue.size() - 1))

	# Update the UI
	if turn_queue_ui:
		turn_queue_ui.update_queue(turn_queue, current_turn_index)

func process_damage_effects(battler):
	var effects_to_remove = []
	for effect in battler.character_data.status_effects:
		if effect.type == "poison":
			var dmg = effect.value
			dmg = 0.1 * battler.character_data.max_hp
			battler.character_data.hp = max(0, battler.character_data.hp - dmg)
			
			# Show purple damage text
			battle_ui.show_damage_number(
				battler.global_position + Vector2(0, -80),
				dmg,
				Color(0.6, 0.2, 0.8)  # poison = purple
			)
			
			print("%s took %d poison damage!" % [battler.character_data.name, dmg])
			
			effect.duration -= 1
			if effect.duration <= 0:
				effects_to_remove.append(effect)
	
	for expired in effects_to_remove:
		battler.character_data.status_effects.erase(expired)


func check_battle_end():
	var any_enemies_alive = false
	for enemy in GameManage.enemy_group:
		if enemy.hp > 0:
			any_enemies_alive = true
			break
	var any_party_alive = false
	for party in GameManage.party:
		if party.hp > 0:
			any_party_alive = true
			break
	
	if not any_party_alive:
		party_alive = false
		gameover()
	
	if not any_enemies_alive:
		end_battle()
	
var victory_shown = false

func disable_battle_ui():
	battle_ui.visible = false
		

func end_battle():
	await get_tree().create_timer(1.0).timeout
	disable_battle_ui()
	victory_shown = true
	VicDes.visible = true
	VicBor.visible = true
	var total_exp = 0
	var total_gold = 0
	
	for enemy in GameManage.enemy_group:
		total_exp += enemy.exp_given
	
	for enemy in GameManage.enemy_group:
		total_gold += enemy.money_total

	
	VicLab.text = "Battle is over! %s won! Each party member gained %d EXP. %d Gold gained." % [GameManage.party[0].name, total_exp, total_gold]
	turn_queue_ui.visible = false
	GameManage.gold += total_gold
	for member in GameManage.party:
		if member.hp > 0:
			member.gain_exp(total_exp)
	
	turn_pointer.visible = false

func wait_for_input(action_name: String) -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed(action_name):
			break

func gameover():
	print("Game Over. All party members defeated.")
	VicDes.visible = true
	VicBor.visible = true
	VicLab.text = "Annihilated"
	turn_pointer.visible = false
	turn_queue_ui.visible = false
	party_alive = false
	disable_battle_ui()
	music.stop()
	gomusic.play()	
	
	
func _unhandled_input(event):
	if event.is_action_pressed("ABORT"):
		GameManage.party[0].gain_exp(400)
		end_battle()
	if victory_shown and (event.is_action_pressed("Test")):
		GameManage.battle = false
		fader.fade_out()
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(GameManage.last_scene_path)
		

func basic_attack(attacker, target) -> void:
	var base_damage = attacker.level * 2 * attacker.str
	var variance = randf_range(0.95, 1.05)
	var raw_damage = int(base_damage * variance)
	var final_damage = max(0, (raw_damage * (255 - target.character_data.end) / 256))
	battle_ui.show_damage_number(target.global_position + Vector2(0, -80), final_damage)

	target.character_data.hp -= final_damage
