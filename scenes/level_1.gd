extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    GameState.reset()
    SoundPlayer.stop_music()
    MusicManager.change_music(MusicManager.Music.ELECTRO_2)
    MusicManager.change_layer(MusicManager.MusicLayer.MEDIUM)
    MusicManager.play()
