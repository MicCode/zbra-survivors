extends Ennemy
class_name Boss1

var is_ready = false
var is_shooting = false

const MINIMUM_TIME_BETWEEN_SHOTS_S: float = 3.0
const MAXIMUM_TIME_BETWEEN_SHOTS_S: float = 5.0
const SHOOT_START_DELAY_S: float = 0.3

func _ready() -> void:
    object_type = Minimap.ObjectType.BOSS
    super._ready()

func _physics_process(delta):
    is_sprite_reversed = true
    if is_ready && !is_dead && !is_shooting && player != null:
        super._physics_process(delta)


func start_chase():
    %Sprite.play("walk")
    get_tree().create_timer(randf_range(MINIMUM_TIME_BETWEEN_SHOTS_S, MAXIMUM_TIME_BETWEEN_SHOTS_S)).timeout.connect(func():
        call_deferred("shoot")
    )

func shoot():
    if !is_dead and PlayerService.player_stats.is_alive:
        %Sprite.play("shoot")
        get_tree().create_timer(SHOOT_START_DELAY_S).timeout.connect(func():
            var bullet = preload("res://ennemies/boss_1/boss_bullet.tscn").instantiate()
            SceneManager.current_scene.add_child(bullet)
            bullet.global_position = %ShootPoint.global_position
            bullet.scale = scale * 1.5
            bullet.look_at(player.global_position)
            Sounds.zap()
        )
        # shoot again after cooldown
        get_tree().create_timer(randf_range(MINIMUM_TIME_BETWEEN_SHOTS_S, MAXIMUM_TIME_BETWEEN_SHOTS_S)).timeout.connect(func():
            call_deferred("shoot")
        )
        is_shooting = true

func handle_bullet_hit(bullet: Bullet):
    if bullet is BossBullet:
        return
    if is_ready && !is_dead:
        super.handle_bullet_hit(bullet)

func take_damage(damage: float):
    health -= damage
    # TODO change sprite modulation on hit
    play_hit_sound()
    var damage_marker = preload("res://ui/in-game/components/DamageIndicator.tscn").instantiate().with_damage(damage)
    damage_marker.global_position = %DamageAnchor.global_position
    SceneManager.current_scene.add_child(damage_marker)
    %AnimationPlayer.play("hurt")

    if health <= 0:
        die()

    GameService.boss_changed.emit(stats, health)

func die():
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
        is_shooting = false
        %Sprite.play("walk")

func _on_wither_radius_body_entered(body: Node2D) -> void:
    if body is EnvTree:
        if !body.is_destroyed:
            body.wither()
