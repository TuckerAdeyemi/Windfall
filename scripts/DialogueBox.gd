extends CanvasLayer

@onready var dialogue_text = $Panel/DialogueText
@onready var choice_box = $Panel/ChoiceBox

var twison_passages = {}
var current_pid = ""
var on_finish = null

var waiting_for_input = false
var next_links = []

func start_twison_dialogue(data: Dictionary, start: String, callback = null):
	twison_passages = data
	current_pid = start
	on_finish = callback
	show_passage(current_pid)

func show_passage(pid: String):
	# Reset UI
	choice_box.hide()
	for btn in choice_box.get_children():
		btn.queue_free()

	var passage = twison_passages.get(pid, null)
	if passage == null:
		if on_finish:
			on_finish.call()
		return

	dialogue_text.text = passage["text"]
	waiting_for_input = true

	if "links" in passage:
		next_links = passage["links"]
	else:
		next_links = []

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and waiting_for_input:
		waiting_for_input = false
		if next_links.is_empty():
			hide()
			if on_finish:
				on_finish.call()
		else:
			show_choices()

func show_choices():
	choice_box.show()
	for link in next_links:
		var btn = Button.new()
		var parts = link["link"].split("|")
		var target_name = parts.size() > 1 if parts.size() > 1 else parts[0]
		btn.text = link["name"]
		btn.pressed.connect(_on_choice_pressed.bind(target_name))
		choice_box.add_child(btn)

func _on_choice_pressed(target_name):
	for pid in twison_passages:
		if twison_passages[pid].get("name") == target_name:
			current_pid = pid
			show_passage(current_pid)
			return
	print("Link target not found:", target_name)

