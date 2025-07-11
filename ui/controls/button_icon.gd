extends TextureRect
class_name ControllerButtonIcon

@export var key_name: String = "A"
@export var controller_name: String = "keyboard"
@export var pressed: bool = false
@export var animate: bool = false


func _ready() -> void:
    update_texture()

func update_texture():
    if pressed:
        texture = load("res://assets/sprites/ui/controls/" + controller_name + "/" + controller_name + "-" + key_name + "-p.png")
    else:
        texture = load("res://assets/sprites/ui/controls/" + controller_name + "/" + controller_name + "-" + key_name + ".png")

func _on_timer_timeout() -> void:
    if animate:
        pressed = !pressed
        update_texture()
