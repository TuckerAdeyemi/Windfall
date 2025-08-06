extends Label

func _ready():
	$DamageAnimation.autoplay = "DamageAnimation"
func show_damage(amount: int):
	text = str(amount)
	$DamageAnimation.play("DamageAnimation")
