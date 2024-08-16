extends Node2D

func _ready():
	%MobSpawnTimer.wait_time = GameState.spawn_time_s

func spawn_ennemy():
	var new_ennemy = EnnemiesService.spawn()
	if new_ennemy:
		%SpawnPoint.progress_ratio = randf()
		new_ennemy.global_position = %SpawnPoint.global_position
		new_ennemy.dead.connect(_on_ennemy_death)
		add_child(new_ennemy)

func _on_mob_spawn_timer_timeout():
	spawn_ennemy()

func _on_ennemy_death():
	GameState.increment_score(1)

func _on_player_health_depleted():
	%GameOver.show()
	get_tree().paused = true
