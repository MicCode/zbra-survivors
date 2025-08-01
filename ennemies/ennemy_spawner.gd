extends Node2D

func _ready() -> void:
    randomize()
    %MobSpawnTimer.start(GameState.ennemy_spawn_stats.spawn_time)

func spawn_ennemy():
    if !SceneManager.current_scene:
        push_error("Cannot spawn ennemy while no current_scene is set in SceneManager")
        return

    var new_ennemy = EnnemiesService.spawn_random()
    if randf() < GameState.ennemy_spawn_stats.elite_spawn_chance:
        new_ennemy.stats.is_elite = true

    %SpawnPoint.progress_ratio = randf()
    new_ennemy.global_position = %SpawnPoint.global_position
    SceneManager.current_scene.get_tree().root.add_child(new_ennemy)
    %MobSpawnTimer.start(GameState.ennemy_spawn_stats.spawn_time)
    GameState.increment_total_spawned(1)

func _on_mob_spawn_timer_timeout():
    spawn_ennemy()
