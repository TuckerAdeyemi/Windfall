extends VBoxContainer

@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var player3 = $Player3
@onready var player4 = $Player4

func set_character(player_node: HBoxContainer, character: Character):
	
	var name_label = player_node.get_node("VBox/Name")
	var title_label = player_node.get_node("VBox/Title")
	var hp_label = player_node.get_node("VBoxContainer/HP")
	var mp_label = player_node.get_node("VBoxContainer/MP")
	var exp_label = player_node.get_node("VBoxContainer/EXP")
	var portrait = player_node.get_node("Portrait")
	var lvl_label = player_node.get_node("VBox/Level")
	
	name_label.text = character.name
	lvl_label.text = "Lvl: %d" % character.level
	title_label.text = character.title
	hp_label.text = "HP: %d / %d" % [character.hp, character.max_hp]
	mp_label.text = "MP: %d / %d" % [character.mp, character.max_mp]
	exp_label.text = "EXP: %d To Next" % character.exp_to_next
	portrait.texture = character.portrait
