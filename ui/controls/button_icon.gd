@tool
extends TextureRect
class_name ControllerButtonIcon

@export var action: Controls.PlayerAction:
    set(value):
        action = value
        update_texture()
@export var pressed: bool = false
@export var animate: bool = false

func change_action(_action: Controls.PlayerAction):
    action = _action

func update_texture():
    var control = Controls.get_input_control(action)
    if control:
        if pressed:
            texture = load(control.get_pressed_sprite())
        else:
            texture = load(control.get_idle_sprite())

func _on_timer_timeout() -> void:
    if animate:
        pressed = !pressed
        update_texture()
