extends Node2D

var is_boss_spawned = false
const TIME_BEFORE_BOSS_S: float = 300.0

func _ready():
	%TimeBeforeBoss.start(TIME_BEFORE_BOSS_S)
	%GameUI.set_remaining_time(%TimeBeforeBoss.time_left)
	GameService.reset()
	get_tree().paused = false
	GameSettings.apply_audio_settings()
	%MobSpawnTimer.wait_time = GameService.spawn_time_s
	%MusicPlayer.play()
	GameService.music_player_instance = %MusicPlayer

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

func _on_time_before_boss_timeout() -> void:
	call_deferred("spawn_boss")

func spawn_boss():
	if !is_boss_spawned:
		is_boss_spawned = true
		var boss = preload("res://ennemies/boss_1/Boss1.tscn").instantiate()
		add_child(boss)
		boss.global_position = %BossSpawnPoint.global_position
		%MusicPlayer.switch_to("BossBattle")
		GameService.boss_changed.connect(on_boss_changed)

func on_boss_changed(new_boss_info: EnnemyInfo):
	if new_boss_info.health <= 0:
		%MusicPlayer.switch_to("MainTheme")
