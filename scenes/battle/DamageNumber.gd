extends Node2D

func _ready():
	$DamageAnimation.autoplay = "DamageAnimation"
	$DamageAnimation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func show_damage(amount: int, color: Color = Color.WHITE):
	$DamageNumber.text = str(amount)
	$DamageNumber.modulate = color
	visible = true
	$DamageAnimation.play("DamageAnimation")

func _on_animation_finished(anim_name: String):
	queue_free()
