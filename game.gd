extends Node2D

var spawn_time_s = 3.0
var score = 0
var player_health = 100.0

func _ready():
	%MobSpawnTimer.wait_time = spawn_time_s
	update_ui()

func spawn_ennemy():
	var new_ennemy = EnnemySpawner.spawn()
	if new_ennemy:
		%SpawnPoint.progress_ratio = randf()
		new_ennemy.global_position = %SpawnPoint.global_position
		new_ennemy.dead.connect(_on_ennemy_death)
		add_child(new_ennemy)

func update_ui():
	%Score.text = str(score)
	%PlayerHealth.value = player_health

func _on_mob_spawn_timer_timeout():
	spawn_ennemy()

func _on_ennemy_death():
	score += 1
	update_ui()

func _on_player_health_changed(new_health):
	player_health = new_health
	update_ui()

func _on_player_health_depleted():
	%GameOver.show()
	get_tree().paused = true
