extends AnimatedSprite2D
class_name Bleed

func _ready() -> void:
	%ParticlesEmitter.emitting = true

func at(target_position: Vector2, orientation: Enums.Orientations) -> Bleed:
	var spawn_scale = get_global_transform().get_scale()
	var spawn_position = Vector2(target_position)
	match orientation:
		Enums.Orientations.LEFT:
			spawn_position.x -= 16 * spawn_scale.x
			spawn_position.y -= 16 * spawn_scale.y
			%ParticlesEmitter.process_material.direction.x = -1
		Enums.Orientations.RIGHT:
			spawn_position.x += 16 * spawn_scale.x
			spawn_position.y -= 16 * spawn_scale.y
			%ParticlesEmitter.process_material.direction.x = 1
			flip_h = true
	global_position = spawn_position
	return self

func _on_timer_timeout() -> void:
	queue_free()
