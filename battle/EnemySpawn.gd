extends Node2D

@export var sprite: Sprite2D

func _ready():
	return

var character_data: Enemy

func flash_sprite() -> void:
	var saved_material: Material = sprite.material
	sprite.material = null
	sprite.modulate = Color.WHITE

	await get_tree().create_timer(0.1).timeout

	sprite.modulate = Color(1, 1, 1, 1)
	sprite.material = saved_material


func set_character(data):
	character_data = data
	update_sprite()

func get_character_data():
	return character_data

func update_sprite():
	if character_data == null:
		return

	if character_data.sprite_path != "":
		var realpath := character_data.sprite_path
		var sprite_texture = load(realpath)
		if sprite_texture:
			sprite.texture = sprite_texture
			
func run_ai(battle_manager: Node):
	
	await flash_sprite()
	
	await get_tree().create_timer(1.0).timeout
	
	await character_data.ai_script.take_turn(character_data, battle_manager.party_nodes, battle_manager)
	
	return

func die():
	character_data.hp = 0  # Just to be sure
	var tree = get_tree()
	
	if has_node("DeathSFX"):
		$DeathSFX.play()
	
	var original = sprite.material
	if original is ShaderMaterial:
		var new_mat = original.duplicate()
		sprite.material = new_mat
		var mat = new_mat

		var duration := 0.8
		var steps := 20
		
		for i in range(steps + 1):
			var cutoff = float(i) / steps
			mat.set_shader_parameter("cutoff", cutoff)
			await tree.create_timer(duration / steps).timeout  # Use cached tree
			
	queue_free()

	# Tell the BattleScene to remove from queue
	if get_parent().has_method("remove_dead_from_turn_queue"):
		get_parent().remove_dead_from_turn_queue()
