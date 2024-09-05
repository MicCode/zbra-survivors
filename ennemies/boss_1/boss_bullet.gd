extends Bullet
class_name BossBullet

func _on_body_entered(body):
	if body is Player:
		body.take_damage(damage)
		queue_free()
