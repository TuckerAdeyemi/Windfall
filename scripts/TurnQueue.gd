extends Node2D

class_name TurnQueue

var active_char

func initialized():
	active_char = get_child(0)
var something = "completed"
func play_turn():
	await active_char.play_turn().something
	var new_index : int = (active_char.get_index() + 1) % get_child_count()
	print(new_index)
	active_char = get_child(new_index)

