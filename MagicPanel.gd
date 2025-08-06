extends Panel

@onready var magic_grid = $MagicGrid
#@export var base_font: Font  # Optional for style

func show_spells_for(character: Character):
	# Clear old spells
	for child in magic_grid.get_children():
		child.queue_free()

	# Get known spells
	var spells = character.get_learned_spells()

	for spell in spells:
		var btn = Button.new()
		btn.text = spell.name
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(120, 32)

		#if base_font:
		#	btn.add_theme_font_override("font", base_font)

		# Optional: Store the spell reference for later use
		btn.set_meta("spell_data", spell)

		# Connect button press
		btn.pressed.connect(func():
			print("You selected:", spell.name)
			# You can trigger targeting, description box, etc. here
		)

		magic_grid.add_child(btn)
