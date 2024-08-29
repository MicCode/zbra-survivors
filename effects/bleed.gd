extends AnimatedSprite2D
class_name Bleed

func at(target_position: Vector2, orientation: Enums.Orientations) -> Bleed:
	var scale = get_global_transform().get_scale()
	var position = Vector2(target_position)
	match orientation:
		Enums.Orientations.LEFT:
			position.x -= 16 * scale.x
			position.y -= 16 * scale.y
		Enums.Orientations.RIGHT:
			position.x += 16 * scale.x
			position.y -= 16 * scale.y
			flip_h = true
	global_position = position
	return self

func _on_timer_timeout() -> void:
	queue_free()
