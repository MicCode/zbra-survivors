extends Area2D
class_name Bullet

@export var bullet_stats: BulletStats
var ATTRACTION_RANGE: float = 50.0

var pierced_bodies: int = 0
var travelled_distance: float = 0.0
var has_exploded = false
var direction: Vector2
var is_from_player = true

func _enter_tree() -> void:
    if !bullet_stats:
        push_warning("bullet has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://items/weapons/_generics/stats/default_bullet_stats.tres")

func _ready() -> void:
    direction = Vector2.RIGHT.rotated(rotation)


func _physics_process(delta):
    var attraction_force = clamp(PlayerService.player_stats.luck * 5, 0.0, 10.0)
    if is_from_player:
        var target = find_nearest_enemy()
        if target:
            var to_target = (target.global_position - global_position).normalized()
            direction = direction.lerp(to_target, attraction_force * delta).normalized()
            rotation = direction.angle()

    position += direction * bullet_stats.speed * delta
    travelled_distance += bullet_stats.speed * delta
    if travelled_distance > bullet_stats.fly_range:
        call_deferred("queue_free")

func _on_body_entered(body: Node2D):
    if body is Enemy || body is Boss1:
        pierce(body)
        if body.has_method("handle_bullet_hit"):
            body.handle_bullet_hit(self)

func _on_area_entered(area: Area2D) -> void:
    var parent = area.get_parent()
    if parent is EnvTree and !parent.is_destroyed:
        pierce(area.get_parent())

func find_nearest_enemy() -> Node2D:
    var enemies = SceneManager.current_scene.get_tree().get_nodes_in_group("enemies") # Mets tes ennemis dans ce groupe
    var closest_enemy: Node2D = null
    var min_dist = PlayerService.player_stats.luck * 50
    for e in enemies:
        if not is_instance_valid(e):
            continue
        var dist = global_position.distance_to(e.global_position)
        if dist < min_dist:
            min_dist = dist
            closest_enemy = e
    return closest_enemy

func pierce(_body: Node2D):
    pierced_bodies += 1
    call_deferred("detonate_if_explosive")
    if pierced_bodies > bullet_stats.pierce_count:
        get_tree().create_timer(bullet_stats.disapear_delay).timeout.connect(func(): call_deferred("queue_free"))

func detonate_if_explosive():
    if bullet_stats.is_explosive and not has_exploded:
        var explosive_effect: ExplosiveEffect = load("res://effects/explosive_effect.tscn").instantiate()
        explosive_effect.global_position = global_position
        explosive_effect.damage = bullet_stats.explosion_damage
        explosive_effect.explosion_radius = bullet_stats.explosion_radius
        explosive_effect.is_from_bullet = true
        SceneManager.current_scene.add_child(explosive_effect)
        explosive_effect.explode()
        has_exploded = true
