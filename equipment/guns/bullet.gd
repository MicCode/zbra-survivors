extends Area2D
class_name Bullet

@export var gun_name: String = "gun"

var speed: float = 2000
var travel_distance: float = 2000
var is_fire: bool = false
var damage: int = 10
var travelled_distance = 0.0

var pierce_count: int = 0
var pierced_bodies: int = 0
var bullet_disapear_delay: float = 0.01

func from(gun_info: GunInfo) -> Bullet:
    return self.with_damage(gun_info.bullet_damage).with_travel_distance(gun_info.fire_range).with_is_fire(gun_info.inflict_fire).with_pierce_count(gun_info.pierce_count)

func with_damage(_damage: int) -> Bullet:
    damage = _damage
    return self

func with_speed(_speed: float) -> Bullet:
    speed = _speed
    return self

func with_travel_distance(_travel_distance: float) -> Bullet:
    travel_distance = _travel_distance
    return self

func with_is_fire(_is_fire: bool) -> Bullet:
    is_fire = _is_fire
    return self

func with_pierce_count(_pierce_count: int) -> Bullet:
    pierce_count = _pierce_count
    return self

func _physics_process(delta):
    var direction = Vector2.RIGHT.rotated(rotation)
    position += direction * speed * delta
    travelled_distance += speed * delta
    if travelled_distance > travel_distance:
        queue_free()

func _on_body_entered(body):
    if body is Ennemy || body is Boss1:
        pierced_bodies += 1
        if pierced_bodies >= pierce_count:
            get_tree().create_timer(bullet_disapear_delay).timeout.connect(func(): queue_free())
