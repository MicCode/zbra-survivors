extends Node2D

func _init() -> void:
    Settings.load_from_file()

func _ready() -> void:
    Musics.lvl_1()