extends CharacterBody2D
class_name Ennemy

const DAMAGE_MARKER_DELAY: float = 0.25
const HIT_SOUND_REPETITION_DELAY: float = 0.25

# TODO make burning related stats variable
const BURN_DURATION_S: float = 1.1
const BURN_TICK_S: float = 0.25
const BURN_DAMAGE: float = 2

@export var is_sprite_reversed = false
@export var stats: EnnemyStats

var player: Player
var health: float = 100
var is_dead: bool = false
var is_burning: bool = false
var object_type = Minimap.ObjectType.ENNEMY

var hit_sound_repetition_timer: SceneTreeTimer

var previous_damage_indicator: DamageIndicator
var accumulated_damages: float = 0.0


func _enter_tree() -> void:
    if !stats:
        push_error("ennemy has no stats defined")

func _ready():
    stats.resource_local_to_scene = true
    if stats.is_elite:
        stats.max_health = floor(stats.max_health * 1.5)
        stats.xp_value = stats.xp_value * 1.5
        stats.speed = stats.speed * 1.25
        scale = scale * 1.5

    health = stats.max_health
    player = GameState.player_instance
    %Sprite.connect("animation_finished", _on_animation_finished)
    %Health.max_health = stats.max_health
    %Health.current_health = health
    %Health.update_display()
    Minimap.track(self, object_type)

func _physics_process(_delta):
    if !is_dead && stats.chase_player && player != null:
        var direction_to_player = global_position.direction_to(player.global_position)
        velocity = direction_to_player * stats.speed
        var distance_to_player = global_position.distance_to(player.global_position)
        if distance_to_player < 10.0:
            var push_away = global_position.direction_to(player.global_position) * -1
            velocity += push_away * 20.0
        move_and_slide()
        Minimap.moved(self, global_position)
        %Sprite.flip_h = !is_sprite_reversed && direction_to_player.x < 0 || is_sprite_reversed && direction_to_player.x >= 0

func handle_bullet_hit(bullet: Bullet):
    if !is_dead:
        take_damage(bullet.bullet_stats.damage)
        if bullet.bullet_stats.inflicts_fire:
            play_hit_sound(true)
            set_burning()
        else:
            play_hit_sound()
            VisualEffects.bleed(global_position, bullet.position)

func take_damage(damage: float):
    accumulated_damages += damage
    if %Health:
        %Health.take_damage(damage)
    if %DamageSpawnTimer.is_stopped() or previous_damage_indicator == null:
        %Sprite.play("hurt")
        play_hit_sound()
        VisualEffects.emphases(%Sprite, %Sprite.scale.x, 1.3, Color.RED)
        previous_damage_indicator = preload("res://ui/in-game/DamageIndicator.tscn").instantiate().with_damage(accumulated_damages)
        previous_damage_indicator.global_position = %DamageAnchor.global_position
        SceneManager.current_scene.add_child(previous_damage_indicator)
        accumulated_damages = 0.0
        %DamageSpawnTimer.start(DAMAGE_MARKER_DELAY)
    else:
        previous_damage_indicator.set_damage(accumulated_damages)


func play_hit_sound(burn_sound: bool = false):
    if hit_sound_repetition_timer != null:
        return
    if burn_sound:
        Sounds.burn_hit()
    else:
        Sounds.hit()
    hit_sound_repetition_timer = get_tree().create_timer(HIT_SOUND_REPETITION_DELAY)
    hit_sound_repetition_timer.timeout.connect(func():
        hit_sound_repetition_timer = null
    )

func _on_animation_finished():
    if !is_dead:
        %Sprite.play("walk")

func _on_health_depleted():
    if stats.can_die:
        is_dead = true
        if stats.is_elite:
            Sounds.death_mob_1(1.2)
        else:
            Sounds.death_mob_1()
        %Sprite.play("dead")
        set_collision_layer_value(2, false)
        set_collision_layer_value(8, false)
        VisualEffects.gore_death(%Sprite, 1.0).connect("finished", func(): queue_free())
        remove_child(%Health)
        GameState.register_ennemy_death(self)
        Minimap.untrack(self)

func _on_hurt_box_area_entered(area: Area2D) -> void:
    if area is Bullet:
        handle_bullet_hit(area as Bullet)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "fade_away":
        queue_free()

#region Burn
###############################################################################################
## Burn
###############################################################################################
func set_burning():
    %BurnTimer.start(BURN_DURATION_S)
    %BurnTickTimer.start(BURN_TICK_S)
    if !is_burning:
        %Effects.start_effect("burn", preload("res://effects/burn_effect.tscn"), Vector2(0, -15))
        is_burning = true

func _on_burn_timer_timeout() -> void:
    %Effects.stop_effect("burn")
    is_burning = false

func _on_burn_tick_timer_timeout() -> void:
    if is_burning && !is_dead:
        take_damage(BURN_DAMAGE)
        %BurnTickTimer.start(BURN_TICK_S)

func _on_fire_animation_animation_finished(anim_name: StringName) -> void:
    if anim_name == "fadeout":
        %FireAnimation.stop()
        %FireLight.hide()
#endregion
