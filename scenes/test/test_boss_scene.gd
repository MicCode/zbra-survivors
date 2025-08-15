extends Node2D

const PLAY_MUSIC = true

func _init():
    Settings.load_from_file()

func _ready() -> void:
    GameService.start_new_game()
    if PLAY_MUSIC:
        MusicManager.set_music(MusicManager.Music.METAL_1)
        MusicManager.set_layer(E.MusicLayer.MEDIUM)

func spawn_boss():
    if !EnemiesService.is_boss_spawned:
        %BossSpawnTrigger.modulate = Color(1, 1, 1, 0.25)
        EnemiesService.spawn_boss(true, %BossSpawnPoint.global_position)

func _on_boss_spawn_trigger_body_entered(_body: Node2D) -> void:
    call_deferred("spawn_boss")
