extends EditorProperty

class_name ControllerButtonIconEditor

var texture_rect := TextureRect.new()
var pressed := false
var action: Controls.PlayerAction

func _init():
    texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    texture_rect.custom_minimum_size = Vector2(64, 64)
    add_child(texture_rect)

func update_display():
    if not is_controls_available():
        return
    var control = Controls.get_input_control(action)
    if control:
        var path = ""
        if pressed:
            control.get_pressed_sprite()
        else:
            control.get_idle_sprite()
        if path != "":
            texture_rect.texture = load(path)

func is_controls_available() -> bool:
    return Controls != null \
        and is_instance_valid(Controls) \
        and Controls.get_script() != null \
        and not Controls.get_script().is_placeholder() \
        and Controls.has_method("get_input_control")

func update_property():
    # Pas utilisé ici, mais obligatoire
    pass

func set_value(p_value):
    action = p_value
    update_display()

func get_value():
    return action