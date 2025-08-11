extends Node2D

const PLAY_MUSIC = true

func _init():
    Settings.load_from_file()

func _ready() -> void:
    GameState.start_new_game()
    if PLAY_MUSIC:
        MusicManager.set_music(MusicManager.Music.METAL_1)
        MusicManager.set_layer(MusicManager.MusicLayer.MEDIUM)

func spawn_boss():
    if !EnnemiesService.is_boss_spawned:
        %BossSpawnTrigger.modulate = Color(1, 1, 1, 0.25)
        EnnemiesService.spawn_boss(true, %BossSpawnPoint.global_position)

func _on_boss_spawn_trigger_body_entered(_body: Node2D) -> void:
    call_deferred("spawn_boss")
