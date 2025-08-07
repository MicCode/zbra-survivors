extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    GameState.reset()
    MusicManager.set_music(MusicManager.Music.METAL_1)
    MusicManager.set_layer(MusicManager.MusicLayer.SOFT)
