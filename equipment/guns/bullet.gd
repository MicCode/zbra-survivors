extends Area2D
class_name Bullet

var speed: float = 2000
var travel_distance: float = 2000
var is_fire: bool = false
var damage: int = 10
var travelled_distance = 0.0

var pierce_count: int = 0
var pierced_bodies: int = 0

func from(gun_info: GunInfo) -> Bullet:
	return self.with_damage(gun_info.bullet_damage).with_travel_distance(gun_info.fire_range).with_is_fire(gun_info.inflict_fire).with_pierce_count(gun_info.pierce_count)

func with_damage(_damage: int) -> Bullet:
	damage = _damage
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
	if body is Ennemy:
		pierced_bodies += 1
		if pierced_bodies >= pierce_count:
			await get_tree().create_timer(0.01).timeout
			queue_free()
