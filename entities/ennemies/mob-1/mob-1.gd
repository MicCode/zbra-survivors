extends CharacterBody2D
class_name Ennemy # TODO extract to abstract class and inherit from it

signal dead

@export var health = 3
@export var speed = 200.0
@export var chase_player = true
@onready var player = get_node("/root/Game/Player")

var is_dead = false

func _ready():
	%Sprite.connect("animation_finished", _on_animation_finished)
	%Health.max_health = health
	%Health.current_health = health

func _physics_process(delta):
	if !is_dead && chase_player && player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity = direction_to_player * speed
		move_and_slide()

func take_damage(damage: int):
	%Sprite.play("hurt")
	%Health.take_damage(damage)
	%HitSound.play()

func _on_animation_finished():
	if !is_dead:
		%Sprite.play("walk")

func _on_health_depleted():
	is_dead = true
	dead.emit()
	%Sprite.play("dead")
	set_collision_layer_value(2, false)
	%DeathTimer.start(1.0)
	remove_child(%Health)

func _on_death_timer_timeout():
	queue_free()
