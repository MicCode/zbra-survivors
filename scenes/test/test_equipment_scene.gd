extends Node2D

func _init() -> void:
    Settings.load_from_file()

func _ready() -> void:
    GameState.reset()
    GameState.lvl_up_rerolls_remaining = 999
    GameState.lvl_up_exclusions_remaining = 999
    Musics.lvl_1()
