extends EnemyBase

func _process(delta):
	if battle == true:
		GameManage.battle = true
		start_battle()
		GameManage.battle = false
	battle = false
	
func start_battle():

	GameManage.enemy_group = [
		#slime.duplicate(),
		EnemyPreloader.slime.duplicate(),
		EnemyPreloader.rod.duplicate(),
		EnemyPreloader.wolf.duplicate()
		#slime.duplicate()
		]
	
	GameManage.last_scene_path = get_tree().current_scene.scene_file_path
	GameManage.player_start_position = player.global_position
	GameManage.defeated_enemy_path = self.get_path()
	get_tree().change_scene_to_packed(battle_scene)
