extends StaticBody2D
class_name EnvTree

var is_destroyed = false

func explode():
	if !is_destroyed:
		is_destroyed = true
		%Sprite.play("explode")
		%ExplodeSound.play()

func burn():
	if !is_destroyed:
		is_destroyed = true
		%Sprite.play("burn")
		%ExplodeSound.play()

func _on_sprite_animation_finished():
	if is_destroyed:
		get_node("Shadow").queue_free()


func _on_explode_zone_area_entered(body: Node2D) -> void:
	if !is_destroyed:
		body.queue_free()
		if body is Bullet:
			if body.is_fire:
				burn()
				return
		explode()
