extends TextureRect
class_name ControllerButtonIcon

@export var action: Controls.PlayerAction
@export var pressed: bool = false
@export var animate: bool = false


func _ready() -> void:
    update_texture()

func change_action(_action: Controls.PlayerAction):
    action = _action
    update_texture()

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
