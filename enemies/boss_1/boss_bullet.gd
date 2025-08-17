extends Bullet
class_name BossBullet

func _init():
    is_from_player = false

func _ready() -> void:
    look_at(PlayerService.player_instance.global_position)

func _physics_process(delta):
    # var to_target = (PlayerService.player_instance.global_position - global_position).normalized()
    # direction = direction.lerp(to_target, delta).normalized()
    position += direction * bullet_stats.speed * delta
    travelled_distance += bullet_stats.speed * delta
    if travelled_distance > bullet_stats.fly_range:
        call_deferred("queue_free")

func _on_body_entered(body):
    if body is Player and PlayerService.player_stats.is_alive:
        body.take_damage(bullet_stats.damage)
        queue_free()
