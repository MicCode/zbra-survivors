extends Node2D

func _ready():
	%GameUI.set_remaining_time(%TimeBeforeBoss.time_left)
	GameService.reset()
	get_tree().paused = false
	GameSettings.apply_audio_settings()
	%MobSpawnTimer.wait_time = GameService.spawn_time_s
	%MusicPlayer.play()

func spawn_ennemy():
	var new_ennemy = EnnemiesService.spawn_random()
	if new_ennemy:
		%SpawnPoint.progress_ratio = randf()
		new_ennemy.global_position = %SpawnPoint.global_position
		add_child(new_ennemy)

func _on_mob_spawn_timer_timeout():
	spawn_ennemy()

func _on_player_health_depleted():
	GameService.show_game_over()

func _on_remaining_time_interval_timeout() -> void:
	%GameUI.set_remaining_time(%TimeBeforeBoss.time_left)
