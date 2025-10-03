extends Panel

class_name QuestMenu

@onready var tab_container: TabContainer = $TabContainer
@onready var quest_list = $ScrollContainer/QuestList
@onready var desc_label = $Panel/Description

var current_filter := "all"

func _ready():
	# Rename tabs
	tab_container.set_tab_title(0, "All")
	tab_container.set_tab_title(1, "Active")
	tab_container.set_tab_title(2, "Completed")

	# Listen for tab changes
	tab_container.tab_selected.connect(_on_tab_changed)

	# First display
	show_quests()

func _on_tab_changed(tab: int):
	match tab:
		0: current_filter = "all"
		1: current_filter = "active"
		2: current_filter = "completed"
	show_quests()

func show_quests():
	# Clear existing buttons
	for child in quest_list.get_children():
		child.queue_free()

	var first_button: Button = null

	for quest_id in GameManage.quests.keys():
		var quest_data = GameManage.quests[quest_id]
		var quest: Quest = quest_data["quest"]

		# Apply filter
		if current_filter == "active" and quest_data["completed"]:
			continue
		if current_filter == "completed" and !quest_data["completed"]:
			continue

		var btn = Button.new()
		btn.text = quest.title
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# 🎨 Green if completed
		if quest_data["completed"]:
			btn.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			btn.add_theme_color_override("font_color", Color(1, 1, 1))

		btn.pressed.connect(func():
			_show_description(quest, quest_data)
		)

		quest_list.add_child(btn)

		if first_button == null:
			first_button = btn

	if first_button:
		first_button.grab_focus()

func _show_description(quest: Quest, data: Dictionary):
	desc_label.bbcode_enabled = true
	desc_label.clear()

	if data["completed"]:
		desc_label.append_text("[b]%s[/b]\n\n%s\n\n[color=green]Completed![/color]" % [quest.title, quest.description])
	else:
		desc_label.append_text("[b]%s[/b]\n\n%s\n\nProgress:" % [quest.title, quest.description])
		for req in quest.requirements.keys():
			var needed = quest.requirements[req]
			var current = data["progress"].get(req, null)

			if typeof(needed) == TYPE_BOOL:
				var done = current == true
				desc_label.append_text("\n- %s: %s" % [req, "[color=green]Done[/color]" if done else "[color=red]Not yet[/color]"])
			else:
				var cur_val = current if current != null else 0
				desc_label.append_text("\n- %s: %d/%d" % [req, cur_val, int(needed)])
