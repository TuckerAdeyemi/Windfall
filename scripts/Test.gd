extends Node


@onready var _character = $Character
@onready var _label = $Interface/Label
@onready var pause_menu = $PauseMenu

#@onready var _bar = $Interface/ExperienceBar
# Called when the node enters the scene tree for the first time.
func _ready():

	_label.update_text(_character.level, _character.xp, _character.exp_req)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	#if event.is_action_pressed("Enter"):
	#	get_tree().change_scene_to_file("res://map1.tscn")
	if not event.is_action_pressed("ui_accept"):
		return
	
	_character.gain_exp(100000)
	_label.update_text(_character.level, _character.xp, _character.exp_req)


