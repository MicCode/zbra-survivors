extends Node2D
class_name DirectionMarker

@export var distance_from_origin: float = 100.0
var target: Node2D

func _process(_delta: float) -> void:
    if target:
        look_at(target.global_position)
        if (target.global_position - global_position).length() < distance_from_origin:
            hide()
        else:
            show()
