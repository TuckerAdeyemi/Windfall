extends ColorRect

func fade_in():
	modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0) # fade to transparent over 1 second

func fade_out():
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0) # fade to black over 1 second
