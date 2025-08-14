extends AnimatedSprite2D
class_name Bleed

var sprite_from_left = false

func at(target_position: Vector2, force_from: Vector2) -> Bleed:
    var orientation: E.Orientation
    if force_from.x < target_position.x:
        if sprite_from_left:
            orientation = E.Orientation.LEFT
        else:
            orientation = E.Orientation.RIGHT
    else:
        if sprite_from_left:
            orientation = E.Orientation.RIGHT
        else:
            orientation = E.Orientation.LEFT

    var spawn_scale = get_global_transform().get_scale()
    var spawn_position = Vector2(target_position)
    match orientation:
        E.Orientation.LEFT:
            spawn_position.x -= 16 * spawn_scale.x
            spawn_position.y -= 16 * spawn_scale.y
            flip_h = sprite_from_left
        E.Orientation.RIGHT:
            spawn_position.x += 16 * spawn_scale.x
            spawn_position.y -= 16 * spawn_scale.y
            flip_h = !sprite_from_left
    global_position = spawn_position
    return self

func _on_timer_timeout() -> void:
    queue_free()
