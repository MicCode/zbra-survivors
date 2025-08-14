extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    MusicManager.set_music(MusicManager.Music.METAL_1)
    MusicManager.set_layer(E.MusicLayer.SOFT)
    EnnemiesService.start_spawning()

func _exit_tree() -> void:
    EnnemiesService.stop_spawning()
