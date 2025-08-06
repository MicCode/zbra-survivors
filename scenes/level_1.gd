extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    GameState.reset()
    MusicManager.change_music(MusicManager.Music.METAL_1)
    MusicManager.change_layer(MusicManager.MusicLayer.SOFT)
