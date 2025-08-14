extends Bullet
class_name BossBullet

func _on_body_entered(body):
    if body is Player and PlayerService.player_state.is_alive:
        body.take_damage(bullet_stats.damage)
        queue_free()
