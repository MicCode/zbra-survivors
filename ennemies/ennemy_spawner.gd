extends Node2D

var is_boss_spawned = false
const SPAWN_DISTANCE_MIN: float = 600.0
const SPAWN_DISTANCE_MAX: float = 700.0

func _ready() -> void:
    randomize()
    GameState.remaining_time_changed.emit(GameState.ennemy_spawn_stats.boss_spawn_time)
    %MobSpawnTimer.start(GameState.ennemy_spawn_stats.spawn_time)
    %TimeBeforeBoss.start(GameState.ennemy_spawn_stats.boss_spawn_time)
    GameState.boss_changed.connect(on_boss_changed)

func spawn_ennemy():
    if !SceneManager.current_scene:
        push_error("Cannot spawn ennemy while no current_scene is set in SceneManager")
        return

    var new_ennemy = EnnemiesService.spawn_random()
    if randf() < GameState.ennemy_spawn_stats.elite_spawn_chance:
        new_ennemy.stats.is_elite = true

    new_ennemy.global_position = get_random_point(GameState.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
    new_ennemy.y_sort_enabled = true
    SceneManager.current_scene.get_tree().root.add_child(new_ennemy)
    %MobSpawnTimer.start(GameState.ennemy_spawn_stats.spawn_time)
    GameState.increment_total_spawned(1)

func _on_mob_spawn_timer_timeout():
    spawn_ennemy()

func _on_ui_refresh_timer_timeout() -> void:
    %GameUI.set_remaining_time(%TimeBeforeBoss.time_left)

func _on_time_before_boss_timeout() -> void:
    call_deferred("spawn_boss")

func spawn_boss():
    if !is_boss_spawned:
        is_boss_spawned = true
        var boss = preload("res://ennemies/boss_1/boss_1.tscn").instantiate()
        boss.scale = Vector2(2.5, 2.5)
        boss.global_position = get_random_point(GameState.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
        SceneManager.current_scene.get_tree().root.add_child(boss)
        MusicManager.set_music(MusicManager.Music.METAL_2)

func get_random_point(origin: Vector2, r_min: float, r_max: float) -> Vector2:
    var angle: float = randf() * TAU
    var radius: float = lerp(r_min, r_max, randf())
    return origin + Vector2(cos(angle), sin(angle)) * radius

func on_boss_changed(boss_stats: EnnemyStats, boss_health: float):
    if boss_stats and boss_health <= 0:
        MusicManager.set_music(MusicManager.Music.METAL_1)
