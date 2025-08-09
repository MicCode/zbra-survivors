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

func bleed(node_position: Vector2, hit_position: Vector2):
    var bleed_effect = preload("res://effects/bleed.tscn").instantiate().at(node_position, hit_position)
    SceneManager.current_scene.add_child(bleed_effect)

func green_squirt(node_position: Vector2, hit_position: Vector2):
    var bleed_effect = preload("res://effects/green_squirt.tscn").instantiate().at(node_position, hit_position)
    SceneManager.current_scene.add_child(bleed_effect)

func emphases(object: Node, from_scale: float, to_scale: float, to_color: Color):
    create_tween().tween_property(object, "scale", Vector2(to_scale, to_scale), 0.05).finished.connect(func():
        create_tween().tween_property(object, "scale", Vector2(from_scale, from_scale), 0.2)
    )
    create_tween().tween_property(object, "modulate", to_color, 0.05).finished.connect(func():
        create_tween().tween_property(object, "modulate", Color.WHITE, 0.2)
    )
