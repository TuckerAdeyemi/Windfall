extends StaticBody2D

signal chest_opened
var chest_zone = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	chest_zone = true
	print(chest_zone)

func _on_area_2d_body_exited(body):
	chest_zone = false
	print(chest_zone)
