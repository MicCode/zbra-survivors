extends Area2D
class_name GunProjectile

var speed: float = 2000
var travel_distance: float = 2000
var is_fire: bool = false
var damage: int = 10
var travelled_distance = 0.0

func with_damage(_damage: int) -> GunProjectile:
	damage = _damage
	return self

func with_travel_distance(_travel_distance: float) -> GunProjectile:
	travel_distance = _travel_distance
	return self

func with_is_fire(_is_fire: bool) -> GunProjectile:
	is_fire = _is_fire
	return self
	
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > travel_distance:
		queue_free()

func _on_body_entered(body):
	if body is Ennemy:
		await get_tree().create_timer(0.01).timeout
		queue_free()
