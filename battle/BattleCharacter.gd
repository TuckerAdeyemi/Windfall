extends Node2D

@onready var sprite = $Sprite2D
@export var anim_sprite: AnimatedSprite2D


func _ready():
	return

var character_data: Character

func set_character(data):
	character_data = data
	#update_sprite()
	load_battle_animation()

func get_character_data():
	return character_data

func update_sprite():
	if character_data == null:
		return

	if character_data.sprite_path != "":
		var sprite_texture = load(character_data.sprite_path)
		if sprite_texture:
			sprite.texture = sprite_texture
			
			
func load_battle_animation():
	if character_data and character_data.animation_frames_path != "":
		var frames = load(character_data.animation_frames_path)
		if frames:
			anim_sprite.sprite_frames = frames
			if frames.has_animation("idle"):
				anim_sprite.play("idle")
			else:
				push_warning("Animation 'idle' not found in " + character_data.animation_frames_path)
		else:
			push_error("Failed to load animation frames from: " + character_data.animation_frames_path)

func die():
	character_data.hp = 0  # Just to be sure
	queue_free()  # Remove from scene — or replace with death animation
	# Tell the BattleScene to remove from queue
	if get_parent().has_method("remove_dead_from_turn_queue"):
		get_parent().remove_dead_from_turn_queue()
