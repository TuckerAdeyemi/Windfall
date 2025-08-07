extends Node2D

@onready var pause_menu = $PauseMenu
@onready var time_display = $PauseMenu/Panel/TimeLabel # Reference to the label showing the time
#@onready var player = get_node("Player")

var party: Array[Character] = []
var loader = DialogueLoader


func _ready():
	pause_menu.visible = false
	GameManage.location = "Windfall Forest"
	

	DialogueLoader.load_twison("res://dialouge/test.json")

	
	var player = get_node_or_null("Player")
	if player and GameManage.player_start_position:
		player.global_position = GameManage.player_start_position
		
	if GameManage.defeated_enemy_path != NodePath(""):
		var enemy = get_node_or_null(GameManage.defeated_enemy_path)
		if enemy:
			enemy.visible = false
			enemy.set_process(false)
	
	#var base_resolution = Vector2(1920, 1080)
	#var screen_size = get_viewport().get_visible_rect().size
	#var scale = Vector2(screen_size) / base_resolution  # Convert to Vector2 first
	#$PauseMenu/Panel/HBox.scale = scale
	
func _unhandled_input(event):
	if event.is_action_pressed("Die"):
		print("fuck")
		$DialogueBox.start_twison_dialogue(loader.passages, loader.start_pid)









