extends StaticBody2D

@onready var open: Sprite2D = $open
@onready var closed: Sprite2D = $closed
@onready var sfx: AudioStreamPlayer2D = $SFX

@export var chest_id: String = "chest_forest_1"
@export var contains: Item
@export var amount: int
@export var message: String

signal chest_opened 

var chest_zone = false
var opened: bool = false
var ready_complete = false


func _ready():
	add_to_group("chests")
	ready_complete = true
	if GameManage.get_flag(chest_id):
		opened = true
		open.visible = true
		closed.visible = false
		$CollisionShape2D.disabled = true

func refresh_state():
	if GameManage.get_flag(chest_id):
		opened = true
		open.visible = true
		closed.visible = false
		$CollisionShape2D.disabled = true
	else:
		opened = false
		open.visible = false
		closed.visible = true
		$CollisionShape2D.disabled = false


func _on_area_2d_body_entered(body):
	if ready_complete and body.name == "Player":
		chest_zone = true
		print(chest_zone)

func _on_area_2d_body_exited(body):
	if ready_complete and body.name == "Player":
		chest_zone = false
		print(chest_zone)

func _unhandled_input(event):
	if chest_zone and event.is_action_pressed("Chest"):
		if opened:
			print("Already opened.")
		else:
			sfx.play()
			while amount > 0:
				Nventory.add_item(contains.duplicate())
				amount -= 1
			opened = true
			print("You received: ", contains.name)
			GameManage.set_flag(chest_id, true)
			open.visible = true
			closed.visible = false
