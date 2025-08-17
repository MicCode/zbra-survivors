extends AnimatedSprite2D
class_name Bleed

var sprite_from_left = false

func at(target_position: Vector2, force_from: Vector2) -> Bleed:
    var is_from_left: bool = false
    if force_from.x < target_position.x:
        is_from_left = sprite_from_left
    else:
        is_from_left = not sprite_from_left

    var spawn_scale = get_global_transform().get_scale()
    var spawn_position = Vector2(target_position)
    if is_from_left:
        spawn_position.x -= 16 * spawn_scale.x
        spawn_position.y -= 16 * spawn_scale.y
        flip_h = sprite_from_left
    else:
        spawn_position.x += 16 * spawn_scale.x
        spawn_position.y -= 16 * spawn_scale.y
        flip_h = !sprite_from_left
    global_position = spawn_position
    return self

func _on_timer_timeout() -> void:
    queue_free()
