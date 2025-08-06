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

func _on_body_entered(body: Node2D):
    if body is Ennemy || body is Boss1:
        pierce(body)

func _on_area_entered(area: Area2D) -> void:
    var parent = area.get_parent()
    if parent is EnvTree and !parent.is_destroyed:
        pierce(area.get_parent())

func pierce(_body: Node2D):
    pierced_bodies += 1
    call_deferred("detonate_if_explosive")
    if pierced_bodies > bullet_stats.pierce_count:
        get_tree().create_timer(bullet_stats.disapear_delay).timeout.connect(func(): call_deferred("queue_free"))

func detonate_if_explosive():
    if bullet_stats.is_explosive:
        var explosive_effect: ExplosiveEffect = load("res://effects/explosive_effect.tscn").instantiate()
        explosive_effect.global_position = global_position
        explosive_effect.damage = bullet_stats.explosion_damage
        explosive_effect.explosion_radius = bullet_stats.explosion_radius
        explosive_effect.is_from_bullet = true
        SceneManager.current_scene.add_child(explosive_effect)
        explosive_effect.explode()
