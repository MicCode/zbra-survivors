extends Area2D
class_name SimpleBullet

@export var speed = 2000
@export var range = 2000

var damage = 1
var travelled_distance = 0

func with_damage(_damage: int) -> SimpleBullet:
	damage = _damage
	return self
	
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > range:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body is Ennemy:
		body.take_damage(damage)
