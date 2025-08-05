extends Node2D

func _init() -> void:
    Settings.load_from_file()

func _ready() -> void:
    GameState.reset()
    Musics.lvl_1()
