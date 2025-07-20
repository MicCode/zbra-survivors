extends Node
class_name InputControl

@export var controller_name: String = "keyboard"
@export var button_name: String = "A"

static func with(_controller_name: String, _button_name: String) -> InputControl:
    var input_control = InputControl.new()
    input_control.controller_name = _controller_name
    input_control.button_name = _button_name
    return input_control

func get_idle_sprite() -> String:
    return "res://assets/sprites/ui/controls/%s/%s-%s.png" % [controller_name, controller_name, button_name]

func get_pressed_sprite() -> String:
    return "res://assets/sprites/ui/controls/%s/%s-%s-p.png" % [controller_name, controller_name, button_name]
