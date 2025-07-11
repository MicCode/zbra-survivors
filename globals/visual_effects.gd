extends Node

func gore_death(sprite: AnimatedSprite2D, delay: float = 0.0) -> PropertyTweener:
    var shader_material: ShaderMaterial = preload("res://effects/gore_death_effect.tres").duplicate(true)
    var noise_texture = shader_material.get_shader_parameter("noiseTexture")
    if noise_texture and noise_texture is NoiseTexture2D:
        var noise = noise_texture.noise
        if noise and noise is FastNoiseLite:
            noise.seed = randi()
    sprite.material = shader_material
    shader_material.set_shader_parameter("progress", 0.2)

    var tween = create_tween()
    tween.tween_interval(delay)
    return tween.tween_property(shader_material, "shader_parameter/progress", 2.0, 0.5)
