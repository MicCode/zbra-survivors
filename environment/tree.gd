extends StaticBody2D
class_name EnvTree

var is_exploded = false

func explode():
	if !is_exploded:
		is_exploded = true
		%Sprite.play("explode")
		%ExplodeSound.play()

func _on_sprite_animation_finished():
	if is_exploded:
		get_node("Shadow").queue_free()
