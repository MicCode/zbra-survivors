extends Node2D

func _ready():
	%MobSpawnTimer.wait_time = GameState.spawn_time_s
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
	GameState.increment_score(1)
	var xp = preload("res://player/xp_drop.tscn").instantiate().with_value(ennemy.info.xp_value)
	xp.global_position = ennemy.global_position
	get_node("/root").get_node("./").add_child(xp)

func _on_player_health_depleted():
	%GameOver.show()
	%GameOverSound.play()
	get_tree().paused = true
