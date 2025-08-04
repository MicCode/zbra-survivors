extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    GameState.reset()
    Musics.lvl_1()
