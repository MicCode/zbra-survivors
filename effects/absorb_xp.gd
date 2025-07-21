extends GenericEffect
class_name AbsorbXpEffect

var shader_material: ShaderMaterial

func _ready() -> void:
    shader_material = %ShaderPanel.material as ShaderMaterial

func fade_in():
    shader_material.set_shader_parameter("portal_tint", Color.TRANSPARENT)
    get_tree().create_tween().tween_property(shader_material, "shader_parameter/portal_tint", Color.WHITE, fade_duration)
    return super.fade_in()

func fade_out():
    get_tree().create_tween().tween_property(shader_material, "shader_parameter/portal_tint", Color.TRANSPARENT, fade_duration)
    return super.fade_out()
