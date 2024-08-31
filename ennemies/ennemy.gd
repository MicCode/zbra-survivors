extends CharacterBody2D
class_name Ennemy

signal dead

@export var chase_player = true
@onready var player = get_node("/root/Game/Player")

var is_dead = false
var is_burning = false
var sprite_reversed = false
var info: EnnemyInfo

func _ready():
	info = EnnemiesService.get_info(self)
	%Sprite.connect("animation_finished", _on_animation_finished)
	%Health.max_health = info.max_health
	%Health.current_health = info.health
	%Health.update_display()
	%DeathSound.pitch_scale = randf_range(0.8, 1.1)

func _physics_process(_delta):
	if !is_dead && chase_player && player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity = direction_to_player * info.speed
		move_and_slide()
		%Sprite.flip_h = !sprite_reversed && direction_to_player.x < 0 || sprite_reversed && direction_to_player.x >= 0

func take_damage(bullet: Bullet):
	if !is_dead:
		%Sprite.play("hurt")
		%HitSound.pitch_scale = randf_range(0.5, 2)
		%HitSound.play()
		if %Health:
			%Health.take_damage(bullet.damage)
		var damage_marker = preload("res://ui/DamageIndicator.tscn").instantiate().with_damage(bullet.damage)
		damage_marker.global_position = %DamageAnchor.global_position
		get_node("/root").get_node("./").add_child(damage_marker)
		if bullet.is_fire:
			set_burning()
		else:
			bleed(bullet.global_position)
			
func set_burning():
	%BurnTimer.start()
	if !is_burning:
		%FireLight.show()
		%FireAnimation.play("emit")
		

func bleed(hit_position: Vector2):
	var direction: Enums.Orientations
	if hit_position.x < global_position.x:
		direction = Enums.Orientations.RIGHT
	else:
		direction = Enums.Orientations.LEFT
	var bleed_effect = preload("res://effects/bleed.tscn").instantiate().at(global_position, direction)
	get_node("/root").get_node("./").add_child(bleed_effect)

func _on_animation_finished():
	if !is_dead:
		%Sprite.play("walk")

func _on_health_depleted():
	if info.can_die:
		is_dead = true
		dead.emit(self)
		%DeathSound.play()
		%Sprite.play("dead")
		set_collision_layer_value(2, false)
		%DeathTimer.start(1.0)
		remove_child(%Health)

func _on_death_timer_timeout():
	%AnimationPlayer.play("fade_away")


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area is Bullet:
		take_damage(area as Bullet)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_away":
		queue_free()

func _on_burn_timer_timeout() -> void:
	%FireAnimation.play("fadeout")
	is_burning = false

func _on_fire_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fadeout":
		%FireAnimation.stop()
		%FireLight.hide()
