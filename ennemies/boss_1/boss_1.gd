extends CharacterBody2D
class_name Boss1

var is_ready = false
var is_dead = false
var is_burning = false
var boss_info: EnnemyInfo
var player: Player
var is_shooting = false

const MINIMUM_TIME_BETWEEN_SHOTS_S: float = 3.0
const MAXIMUM_TIME_BETWEEN_SHOTS_S: float = 5.0
const SHOOT_START_DELAY_S: float = 0.3

# TODO there are many similarities with Ennemy class, there is probably a lot of refactoring to do

func _init() -> void:
	boss_info = EnnemyInfo.new()
	boss_info.name = "boss-1"
	boss_info.nice_name = "ZBRA, Devourer Of Worlds"
	boss_info.max_health = 100
	boss_info.health = boss_info.max_health
	boss_info.speed = 150.0
	boss_info.xp_value = 50.0
	boss_info.can_die = true
	
func _ready():
	player = GameService.player_instance
	
func _physics_process(delta):
	if is_ready && !is_dead && !is_shooting && player != null:
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity = direction_to_player * boss_info.speed
		move_and_collide(velocity * delta)
		%Sprite.flip_h = direction_to_player.x > 0

	
func start_chase():
	%Sprite.play("walk")
	%ShootTimer.start(randf_range(MINIMUM_TIME_BETWEEN_SHOTS_S, MAXIMUM_TIME_BETWEEN_SHOTS_S))
	
func shoot():
	if !is_dead:
		%Sprite.play("shoot")
		%ShootDelayTimer.start(SHOOT_START_DELAY_S)
		is_shooting = true

func _on_shoot_delay_timer_timeout() -> void:
	var bullet = preload("res://ennemies/boss_1/boss_bullet.tscn").instantiate().with_damage(1).with_speed(1000)
	get_tree().root.add_child(bullet)
	bullet.global_position = %ShootPoint.global_position
	bullet.look_at(player.global_position)
	%ShootSound.play()
	
func handle_bullet_hit(bullet: Bullet):
	if bullet is BossBullet:
		return
	if is_ready && !is_dead:
		take_damage(bullet.damage)
		#if bullet.is_fire:
			#set_burning()
		#else:
			#bleed(bullet.global_position)

func take_damage(damage: int):
	boss_info.health -= damage
	# TODO change sprite modulation on hit
	%HitSound.pitch_scale = randf_range(0.5, 2)
	%HitSound.play()
	var damage_marker = preload("res://ui/in-game/DamageIndicator.tscn").instantiate().with_damage(damage)
	damage_marker.global_position = %DamageAnchor.global_position
	SceneManager.current_scene.add_child(damage_marker)
	%AnimationPlayer.play("hurt")
	
	if boss_info.health <= 0:
		die()
		
	GameService.boss_changed.emit(boss_info)

func bleed(hit_position: Vector2):
	var direction: Enums.Orientations
	if hit_position.x < global_position.x:
		direction = Enums.Orientations.RIGHT
	else:
		direction = Enums.Orientations.LEFT
	var bleed_effect = preload("res://effects/bleed.tscn").instantiate().at(global_position, direction)
	SceneManager.current_scene.add_child(bleed_effect)

func die():
	is_dead = true
	%Sprite.play("die")
	%DeathSound.play()
	%AnimationPlayer.play("die")
	set_collision_layer_value(2, false)
	set_collision_layer_value(8, false)

func _on_sprite_animation_finished() -> void:
	if !is_ready:
		is_ready = true
		call_deferred("start_chase")
		GameService.boss_changed.emit(boss_info)
	elif !is_dead && is_shooting:
		is_shooting = false
		%Sprite.play("walk")

func _on_shoot_timer_timeout() -> void:
	call_deferred("shoot")

func _on_wither_radius_body_entered(body: Node2D) -> void:
	if body is EnvTree:
		if !body.is_destroyed:
			body.wither()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area is Bullet:
		handle_bullet_hit(area as Bullet)
