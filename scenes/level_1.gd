extends Node2D

func _ready():
	GameService.reset()
	get_tree().paused = false
	GameSettings.apply_audio_settings()
	%MobSpawnTimer.wait_time = GameService.spawn_time_s
	%BackMusicPlayer.play()

func spawn_ennemy():
	var new_ennemy = EnnemiesService.spawn_random()
	if new_ennemy:
		%SpawnPoint.progress_ratio = randf()
		new_ennemy.global_position = %SpawnPoint.global_position
		new_ennemy.dead.connect(_on_ennemy_death)
		add_child(new_ennemy)

func _on_mob_spawn_timer_timeout():
	spawn_ennemy()

func _on_ennemy_death(ennemy: Ennemy):
	GameService.increment_score(1)
	var xp: XpDrop = preload("res://player/xp_drop.tscn").instantiate().with_value(ennemy.ennemy_info.xp_value)
	xp.global_position = ennemy.global_position
	SceneManager.current_scene.call_deferred("add_child", xp)

	if randf() <= GameService.player_state.life_drop_chance:
		var life_flask: LifeFlask = preload("res://equipment/items/life_flask.tscn").instantiate().with_life_amount(1) # TODO make life amount configurable
		life_flask.global_position = ennemy.global_position
		SceneManager.current_scene.call_deferred("add_child", life_flask)


func _on_player_health_depleted():
	%GameOver.show()
	%GameOverSound.play()
	get_tree().paused = true
