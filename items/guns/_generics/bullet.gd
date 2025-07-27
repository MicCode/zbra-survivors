extends Area2D
class_name Bullet

@export var bullet_stats: BulletStats

var pierced_bodies: int = 0
var travelled_distance: float = 0.0

func _enter_tree() -> void:
    if !bullet_stats:
        push_warning("bullet has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://items/guns/_generics/stats/default_bullet_stats.tres")

func _physics_process(delta):
    var direction = Vector2.RIGHT.rotated(rotation)
    position += direction * bullet_stats.speed * delta
    travelled_distance += bullet_stats.speed * delta
    if travelled_distance > bullet_stats.fly_range:
        queue_free()

func _on_body_entered(body):
    if body is Ennemy || body is Boss1 || body is EnvTree:
        pierced_bodies += 1
        if pierced_bodies >= bullet_stats.pierce_count:
            get_tree().create_timer(bullet_stats.disapear_delay).timeout.connect(func(): queue_free())
