extends Bullet
class_name BossBullet

func _on_body_entered(body):
    if body is Player:
        body.take_damage(bullet_stats.damage)
        queue_free()
