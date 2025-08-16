extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    EnemiesService.start_spawning()

func _exit_tree() -> void:
    EnemiesService.stop_spawning()
