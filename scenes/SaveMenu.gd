extends Panel

@export var max_slots: int = 3
@export var is_save_menu: bool = true  # toggle between Save or Load mode

@onready var slots_container = $SlotList

func _ready():
	_refresh_slots()

func _refresh_slots():
	for child in slots_container.get_children():	
		child.queue_free()

	for i in range(max_slots):
		var slot_index = i + 1
		var hbox = HBoxContainer.new()

		# Slot Label
		var slot_label = Label.new()
		slot_label.text = "Slot %d: " % slot_index
		hbox.add_child(slot_label)

		# Info label (playtime, gold, location)
		var info_label = Label.new()
		info_label.text = _get_slot_info(slot_index)
		hbox.add_child(info_label)

		# Action button (Save or Load)
		var btn = Button.new()
		btn.text = "Save" if is_save_menu else "Load"
		btn.pressed.connect(func():
			if is_save_menu:
				GameManage.save_game(slot_index)
				_refresh_slots()
			else:
				GameManage.load_game(slot_index)
		)
		hbox.add_child(btn)

		slots_container.add_child(hbox)
		
		# Add "Open Save Folder" button at the bottom
		"""
		var open_btn = Button.new()
		open_btn.text = "Open Save Folder"
		open_btn.pressed.connect(func():
			_open_save_folder()
		)
		slots_container.add_child(open_btn)
		"""

func _open_save_folder():
	var dir_path = ProjectSettings.globalize_path("user://")
	print("Opening save folder:", dir_path)

	# Platform-specific ways to open the folder
	if OS.get_name() == "Windows":
		OS.execute("explorer", [dir_path])
	elif OS.get_name() == "macOS":
		OS.execute("open", [dir_path])
	elif OS.get_name() == "Linux":
		OS.execute("xdg-open", [dir_path])


func _get_slot_info(slot_index: int) -> String:
	var path = "user://savegame_%d.json" % slot_index
	if not FileAccess.file_exists(path):
		return "Empty Slot"

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "Corrupt Save"
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		return "Corrupt Save"

	# Extract playtime
	var playtime: float = data.get("playtime", 0.0)
	var total_seconds = int(playtime)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60

	# Extract first party member
	var party = data.get("party", [])
	if party.size() == 0:
		return "No Party | Playtime: %02d:%02d | %s" % [hours, minutes, GameManage.location]

	var first = party[0]
	var name = first.get("resource_path", "Unknown").get_file().get_basename()
	var level = first.get("level", 1)
	var hp = "%d/%d" % [first.get("hp", 0), first.get("max_hp", 0)]
	var mp = "%d/%d" % [first.get("mp", 0), first.get("max_mp", 0)]

	return "%s Lv.%d | HP: %s | MP: %s | Playtime: %02d:%02d | %s" % [
		name, level, hp, mp, hours, minutes, GameManage.location
	]
