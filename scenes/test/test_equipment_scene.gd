extends Node2D

func _init() -> void:
    Settings.load_from_file()

func _ready() -> void:
    GameState.reset()
    GameState.lvl_up_rerolls_remaining = 999
    GameState.lvl_up_exclusions_remaining = 999
    MusicManager.set_music(MusicManager.Music.METAL_1)
    MusicManager.set_layer(MusicManager.MusicLayer.MEDIUM)


func _on_check_button_toggled(toggled_on: bool) -> void:
    if toggled_on:
        EnnemiesService.start_spawning()
    else:
        EnnemiesService.stop_spawning()
