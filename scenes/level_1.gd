extends Node2D

var is_boss_spawned = false
const TIME_BEFORE_BOSS_S: float = 180.0

func _ready():
    %TimeBeforeBoss.start(TIME_BEFORE_BOSS_S)
    %GameUI.set_remaining_time(%TimeBeforeBoss.time_left)
    GameService.reset()
    get_tree().paused = false
    SoundPlayer.apply_audio_settings()
    %MobSpawnTimer.wait_time = GameService.spawn_time_s
    SoundPlayer.play_music("theme.mp3")

func spawn_ennemy():
    var new_ennemy = EnnemiesService.spawn_random()
    if new_ennemy:
        %SpawnPoint.progress_ratio = randf()
        new_ennemy.global_position = %SpawnPoint.global_position
        add_child(new_ennemy)

func _on_mob_spawn_timer_timeout():
    spawn_ennemy()

func _on_remaining_time_interval_timeout() -> void:
    %GameUI.set_remaining_time(%TimeBeforeBoss.time_left)

func _on_time_before_boss_timeout() -> void:
    call_deferred("spawn_boss")

func spawn_boss():
    if !is_boss_spawned:
        is_boss_spawned = true
        var boss = preload("res://ennemies/boss_1/boss_1.tscn").instantiate()
        add_child(boss)
        boss.global_position = %BossSpawnPoint.global_position
        SoundPlayer.play_music("boss.mp3")
        GameService.boss_changed.connect(on_boss_changed)

func on_boss_changed(_boss_stats: EnnemyStats, boss_health: float):
    if boss_health <= 0:
        SoundPlayer.play_music("theme.mp3")
