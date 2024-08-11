extends Area2D

@export var range = 200.0
@export var fire_rate = 1.0
var flipped = false
var firing = false

const BULLET = preload("res://entities/projectiles/simple-bullet/simple-bullet.tscn")

func _ready():
	%Reach.shape.radius = range
	%Timer.wait_time = 1 / fire_rate # FIXME: possible division by 0
	
func _physics_process(delta):
	target_nearest_ennemy()
	if self.global_rotation_degrees > 90 || self.global_rotation_degrees < -90:
		if !flipped:
			flipped = true
			%ShootingPoint.translate(Vector2(0, 6))
		%Sprite.set_flip_v(true)
	else:
		if flipped:
			flipped = false
			%ShootingPoint.translate(Vector2(0, -6))
		%Sprite.set_flip_v(false)
	
func target_nearest_ennemy():
	var in_range = get_overlapping_bodies()
	if in_range.size() > 0:
		var target
		var closest_distance = 1000000000;
		for ennemy in in_range:
			var distance = self.global_position.distance_to(ennemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				target = ennemy
		
		if target != null:
			look_at(target.global_position)


func _on_timer_timeout():
	shoot_bullet()

func shoot_bullet():
	firing = true
	var new_bullet = BULLET.instantiate().with_damage(1)
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	get_node("/root/Game").add_child(new_bullet)
	%Sprite.play("firing")
	%ShootSound.play()

func _on_sprite_animation_finished():
	if firing:
		%Sprite.play("idle")
