extends Enemy
class_name Boss1

var is_ready = false
var is_shooting = false

const MINIMUM_TIME_BETWEEN_SHOTS_S: float = 3.0
const MAXIMUM_TIME_BETWEEN_SHOTS_S: float = 5.0

const SHOOT_WARN_DELAY: float = 1.0
const SHOOT_START_DELAY_S: float = 0.3

func _ready() -> void:
    object_type = Minimap.ObjectType.BOSS
    %ShootTimer.timeout.connect(func():
        call_deferred("shoot")
    )
    super._ready()

func _physics_process(delta):
    is_sprite_reversed = true
    if is_ready && !is_dead && !is_shooting && player != null:
        super._physics_process(delta)


func start_chase():
    %Sprite.play("walk")
    %ShootTimer.start(randf_range(MINIMUM_TIME_BETWEEN_SHOTS_S, MAXIMUM_TIME_BETWEEN_SHOTS_S))

func shoot():
    if !is_dead and PlayerService.player_stats.is_alive:
        var danger_zone: DangerZoneRect = preload("res://ui/in-game/components/danger_zone_rect.tscn").instantiate()
        danger_zone.animation_time = SHOOT_WARN_DELAY + SHOOT_START_DELAY_S / 2
        danger_zone.track_player = true
        danger_zone.height = 30
        danger_zone.base_modulate = Color(Color.WHITE, 0.5)
        %ShootPoint.add_child(danger_zone)

        get_tree().create_timer((SHOOT_WARN_DELAY + SHOOT_START_DELAY_S) - 0.9).timeout.connect(func():
            Sounds.shoot_boss_1()
        )
        get_tree().create_timer(SHOOT_WARN_DELAY).timeout.connect(func():
            var target = PlayerService.player_instance.global_position
            danger_zone.track_player = false
            %Sprite.play("shoot")
            get_tree().create_timer(SHOOT_START_DELAY_S).timeout.connect(func():
                var bullet = preload("res://enemies/boss_1/boss_bullet.tscn").instantiate()
                SceneManager.current_scene.add_child(bullet)
                bullet.global_position = %ShootPoint.global_position
                bullet.scale = scale * 1.5
                bullet.direction = (target - bullet.global_position).normalized()
                bullet.look_at(target)
                is_shooting = false
            )
            # shoot again after cooldown
            %ShootTimer.start(randf_range(MINIMUM_TIME_BETWEEN_SHOTS_S, MAXIMUM_TIME_BETWEEN_SHOTS_S))
            is_shooting = true
        )

func handle_bullet_hit(bullet: Bullet):
    if bullet is BossBullet:
        return
    if is_ready && !is_dead:
        super.handle_bullet_hit(bullet)

func take_damage(damage: float, damage_type: E.DamageType):
    super.take_damage(damage, damage_type)
    health -= damage
    %AnimationPlayer.play("hurt")
    if health <= 0:
        die()
    GameService.boss_changed.emit(stats, health)

func die(_game_over: bool = false):
    if !is_dead:
        is_dead = true
        %Sprite.play("die")
        Sounds.death_boss_1()
        %AnimationPlayer.play("die")
        VisualEffects.gore_death(%Sprite, 1.0).connect("finished", func(): queue_free())
        set_collision_layer_value(2, false)
        set_collision_layer_value(8, false)

func _on_sprite_animation_finished() -> void:
    if !is_ready:
        is_ready = true
        call_deferred("start_chase")
        GameService.boss_changed.emit(stats, health)
    elif !is_dead && is_shooting:
        %Sprite.play("walk")

func _on_wither_radius_body_entered(body: Node2D) -> void:
    if body is EnvTree:
        if !body.is_destroyed:
            body.wither()
