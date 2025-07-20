extends Node2D
class_name AimGuides

var dispersion_angle = 0.0

func _ready() -> void:
    set_dispersion_angle(dispersion_angle)

func set_dispersion_angle(new_angle: float):
    dispersion_angle = new_angle
    var bound_angle = new_angle / 2
    %Bound1.rotation_degrees = bound_angle
    %Bound2.rotation_degrees = -bound_angle
