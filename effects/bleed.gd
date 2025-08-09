extends AnimatedSprite2D
class_name Bleed

var sprite_from_left = false

func at(target_position: Vector2, force_from: Vector2) -> Bleed:
    var orientation: Enums.Orientations
    if force_from.x < target_position.x:
        if sprite_from_left:
            orientation = Enums.Orientations.LEFT
        else:
            orientation = Enums.Orientations.RIGHT
    else:
        if sprite_from_left:
            orientation = Enums.Orientations.RIGHT
        else:
            orientation = Enums.Orientations.LEFT

    var spawn_scale = get_global_transform().get_scale()
    var spawn_position = Vector2(target_position)
    match orientation:
        Enums.Orientations.LEFT:
            spawn_position.x -= 16 * spawn_scale.x
            spawn_position.y -= 16 * spawn_scale.y
            flip_h = sprite_from_left
        Enums.Orientations.RIGHT:
            spawn_position.x += 16 * spawn_scale.x
            spawn_position.y -= 16 * spawn_scale.y
            flip_h = !sprite_from_left
    global_position = spawn_position
    return self

func _on_timer_timeout() -> void:
    queue_free()
