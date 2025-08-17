extends Node2D

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    GameLogger.log_event(E.EventLogType.LEVEL_LOADED, "level_1")
    EnemiesService.start_spawning()

func _exit_tree() -> void:
    EnemiesService.stop_spawning()
