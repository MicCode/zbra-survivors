extends CharacterBody2D
class_name Ennemy

signal dead

@export var chase_player = true
@onready var player = get_node("/root/Game/Player")

var is_dead = false
var sprite_reversed = false
var stats: EnnemyStats

func _ready():
	stats = EnnemiesService.get_ennemy_stats(self)
	%Sprite.connect("animation_finished", _on_animation_finished)
	%Health.max_health = stats.max_health
	%Health.current_health = stats.health
	%Health.update_display()
	%DeathSound.pitch_scale = randf_range(0.8, 1.1)

func _physics_process(_delta):
	if !is_dead && chase_player && player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity = direction_to_player * stats.speed
		move_and_slide()
		%Sprite.flip_h = !sprite_reversed && direction_to_player.x < 0 || sprite_reversed && direction_to_player.x >= 0

func take_damage(damage: float):
	%Sprite.play("hurt")
	%Health.take_damage(damage)
	%HitSound.pitch_scale = randf_range(0.5, 2)
	%HitSound.play()

func _on_animation_finished():
	if !is_dead:
		%Sprite.play("walk")

func _on_health_depleted():
	is_dead = true
	dead.emit()
	%DeathSound.play()
	%Sprite.play("dead")
	set_collision_layer_value(2, false)
	%DeathTimer.start(1.0)
	remove_child(%Health)

func _on_death_timer_timeout():
	queue_free()
