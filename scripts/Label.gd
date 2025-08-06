extends Label


func update_text(level, xp, req_exp):
		text = """Level: %s
				Exp: %s
				Next Level: %s
					""" %[level, xp, req_exp]
