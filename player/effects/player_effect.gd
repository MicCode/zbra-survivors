extends Node2D
class_name PlayerEffect

enum Effects {
    FIRE_RADIATION,
    TIMEWARP
}

signal finished
@export var duration: float
@export var effect: Effects

var remaining_time: float
var _internal_timer: SceneTreeTimer

func _enter_tree() -> void:
    _internal_timer = get_tree().create_timer(duration)
    _internal_timer.timeout.connect(func():
        finished.emit()
        queue_free()
    )

func get_remaining_time() -> float:
    return _internal_timer.time_left
