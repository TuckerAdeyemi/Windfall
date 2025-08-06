extends EnemyBase

func _process(delta):
	if battle == true:
		GameManage.battle = true
		print("buns")
		start_battle()
		GameManage.battle = false
	battle = false
	
func start_battle():
	var slime = preload("res://resources/enemies/Slime.tres")
	var rod = preload("res://resources/enemies/Elven_Rodent.tres")
	GameManage.enemy_group = [
		#slime.duplicate(),
		slime.duplicate(),
		rod.duplicate(),
		#slime.duplicate()
		]
	
	GameManage.last_scene_path = get_tree().current_scene.scene_file_path
	GameManage.player_start_position = player.global_position
	GameManage.defeated_enemy_path = self.get_path()
	get_tree().change_scene_to_packed(battle_scene)
