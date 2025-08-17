extends Bullet
class_name BossBullet

var has_dealt_damage = false

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
    if body is Player and PlayerService.player_stats.is_alive and !has_dealt_damage:
        body.take_damage(bullet_stats.damage)
        has_dealt_damage = true

func _on_area_entered(area: Area2D) -> void:
    var parent = area.get_parent()
    if parent is EnvTree and !parent.is_destroyed:
        parent.wither()
