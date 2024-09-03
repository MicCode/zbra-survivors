extends CharacterBody2D
class_name Ennemy

@export var ennemy_name: String
@export var is_chasing_player = true
@export var is_sprite_reversed = false

var player: Player
var ennemy_info: EnnemyInfo
var is_dead = false
var is_burning = false

# TODO make burning related stats variable
const BURN_DURATION_S: float = 1.1
const BURN_TICK_S: float = 0.25
const BURN_DAMAGE: float = 2

func _ready():
	ennemy_info = EnnemiesService.get_info(ennemy_name)
	player = GameService.player_instance
	%Sprite.connect("animation_finished", _on_animation_finished)
	%Health.max_health = ennemy_info.max_health
	%Health.current_health = ennemy_info.health
	%Health.update_display()
	%DeathSound.pitch_scale = randf_range(0.8, 1.1)

func _physics_process(_delta):
	if !is_dead && is_chasing_player && player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity = direction_to_player * ennemy_info.speed
		move_and_slide()
		%Sprite.flip_h = !is_sprite_reversed && direction_to_player.x < 0 || is_sprite_reversed && direction_to_player.x >= 0

func handle_bullet_hit(bullet: Bullet):
	if !is_dead:
		take_damage(bullet.damage)
		if bullet.is_fire:
			set_burning()
		else:
			bleed(bullet.global_position)

func take_damage(damage: float):
	%Sprite.play("hurt")
	%HitSound.pitch_scale = randf_range(0.5, 2)
	%HitSound.play()
	if %Health:
		%Health.take_damage(damage)
	var damage_marker = preload("res://ui/in-game/DamageIndicator.tscn").instantiate().with_damage(damage)
	damage_marker.global_position = %DamageAnchor.global_position
	SceneManager.current_scene.add_child(damage_marker)

func bleed(hit_position: Vector2):
	var direction: Enums.Orientations
	if hit_position.x < global_position.x:
		direction = Enums.Orientations.RIGHT
	else:
		direction = Enums.Orientations.LEFT
	var bleed_effect = preload("res://effects/bleed.tscn").instantiate().at(global_position, direction)
	SceneManager.current_scene.add_child(bleed_effect)

func _on_animation_finished():
	if !is_dead:
		%Sprite.play("walk")

func _on_health_depleted():
	if ennemy_info.can_die:
		is_dead = true
		%DeathSound.play()
		%Sprite.play("dead")
		set_collision_layer_value(2, false)
		set_collision_layer_value(8, false)
		%DeathTimer.start(1.0)
		remove_child(%Health)
		GameService.register_ennemy_death(self)

func _on_death_timer_timeout():
	%AnimationPlayer.play("fade_away")


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area is Bullet:
		handle_bullet_hit(area as Bullet)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_away":
		queue_free()

###############################################################################################
## Burn
###############################################################################################
func set_burning():
	%BurnTimer.start(BURN_DURATION_S)
	%BurnTickTimer.start(BURN_TICK_S)
	if !is_burning:
		%FireLight.show()
		%FireAnimation.play("emit")
		is_burning = true

func _on_burn_timer_timeout() -> void:
	%FireAnimation.play("fadeout")
	is_burning = false
	
func _on_burn_tick_timer_timeout() -> void:
	if is_burning && !is_dead:
		take_damage(BURN_DAMAGE)
		%BurnTickTimer.start(BURN_TICK_S)

func _on_fire_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fadeout":
		%FireAnimation.stop()
		%FireLight.hide()
