extends Control

@export var queue_box: HBoxContainer
@export var portrait_template: TextureRect


func update_queue(turn_queue: Array, current_index: int):
	for child in queue_box.get_children():
		if child != portrait_template:
			child.queue_free()
	
	for i in range(turn_queue.size()):
		var entry = turn_queue[i]
		var battler = entry["battler"]
		var char_data = battler.character_data
		
		var portrait = portrait_template.duplicate()
		portrait.visible = true
		portrait.texture = char_data.portrait if char_data.portrait else null
		
		if i == current_index:
			portrait.modulate = Color(1, 1, 0)  # Highlight current turn (yellow)
		else:
			portrait.modulate = Color(1, 1, 1)  # Normal
		
		queue_box.add_child(portrait)
