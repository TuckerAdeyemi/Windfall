extends CanvasLayer

@onready var dialogue_text = $Panel/DialogueText
@onready var choice_box = $Panel/ChoiceBox

var twison_passages = {}
var current_pid = ""
var on_finish = null

func start_twison_dialogue(data: Dictionary, start: String, callback = null):
	twison_passages = data
	current_pid = start
	on_finish = callback
	show_passage(current_pid)

func show_passage(pid: String):
	choice_box.hide()
	for btn in choice_box.get_children():
		btn.queue_free()
	
	var passage = twison_passages.get(pid, null)
	if passage == null:
		if on_finish:
			on_finish.call()
		return
	
	dialogue_text.text = passage["text"]

	if "links" in passage:
		choice_box.show()
		for link in passage["links"]:
			var btn = Button.new()
			btn.text = link["name"]
			btn.pressed.connect(_on_choice_pressed.bind(link["link"]))
			choice_box.add_child(btn)
	else:
		await get_tree().create_timer(2.0).timeout
		hide()
		if on_finish:
			on_finish.call()

func _on_choice_pressed(target_name):
	for pid in twison_passages:
		if twison_passages[pid].get("name") == target_name:
			current_pid = pid
			show_passage(current_pid)
			return
