extends Node2D

var display_time: float = 1.0
var appear_time: float = 0.05
var disappear_time: float = 1.0

var all_fonts = [
    load("res://assets/fonts/RubikBurned-Regular.ttf"),
    load("res://assets/fonts/RubikDistressed-Regular.ttf"),
    load("res://assets/fonts/RubikGlitch-Regular.ttf"),
    load("res://assets/fonts/RubikVinyl-Regular.ttf"),
    load("res://assets/fonts/Splash-Regular.ttf"),
    load("res://assets/fonts/SyneTactile-Regular.ttf")
]

func set_text(text: String):
    %Label.text = text

func set_size(size: int):
    %Label.label_settings.font_size = size

func _ready() -> void:
    %Label.label_settings.font = all_fonts[randi_range(0, all_fonts.size() - 1)]
    appear()
    get_tree().create_timer(display_time).timeout.connect(disappear)

func appear():
    var target_rotation = randf_range(-30.0, 30.0)
    var offsets = [randf_range(-20.0, -10.0), randf_range(10.0, 20.0)]
    rotation_degrees = target_rotation + offsets[randi_range(0, 1)]
    scale = Vector2(0.5, 0.5)
    modulate = Color.TRANSPARENT
    var panel_shader: ShaderMaterial = %Panel.material
    panel_shader.set_shader_parameter("progress", 0.0)

    create_tween().tween_property(self, "modulate", Color.WHITE, appear_time / 2)
    create_tween().tween_property(self, "rotation_degrees", target_rotation, appear_time)
    create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), appear_time)

func disappear():
    var panel_shader: ShaderMaterial = %Panel.material
    panel_shader.set_shader_parameter("progress", 0.0)
    create_tween().tween_property(panel_shader, "shader_parameter/progress", 1.2, disappear_time).finished.connect(func():
        queue_free()
    )
