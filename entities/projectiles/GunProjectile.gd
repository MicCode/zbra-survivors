extends Area2D
class_name GunProjectile

@export var speed: float = 2000
@export var travel_distance: float = 2000

var damage: float = 1.0
var travelled_distance = 0.0

func with_damage(_damage: float) -> GunProjectile:
	damage = _damage
	return self
	
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > travel_distance:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body is Ennemy:
		body.take_damage(damage)
	elif body is EnvTree:
		body.explode()
