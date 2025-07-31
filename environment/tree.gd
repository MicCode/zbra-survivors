extends StaticBody2D
class_name EnvTree

const BURN_DURATION_S: float = 1.1
const DAMAGE_TICK_RATE: float = 0.5

var is_destroyed = false
var life: int = 6

func _physics_process(_delta: float) -> void:
    if !%DamageTimer.is_stopped():
        return

    var overlapping_bodies = %EnnemyDetector.get_overlapping_bodies()
    if overlapping_bodies.size() > 0:
        life -= 1
        if life <= 0:
            explode()
        %DamageTimer.start(DAMAGE_TICK_RATE)

func explode():
    if !is_destroyed:
        is_destroyed = true
        destroy("explode")

func burn():
    if !is_destroyed:
        is_destroyed = true
        %Effects.start_effect("burn", preload("res://effects/burn_effect.tscn"), Vector2(0, -25))
        destroy("burn")

func wither():
    if !is_destroyed:
        is_destroyed = true
        destroy("wither")

func destroy(effect_name: String):
    %Sprite.play(effect_name)
    Sounds.tree_destroyed()
    set_collision_layer_value(3, false)
    set_collision_layer_value(8, false)
    %LightOccluder2D.hide()

func _on_sprite_animation_finished():
    if is_destroyed:
        %Shadow.queue_free()
        %Effects.stop_all()

func _on_explode_zone_area_entered(body: Node2D) -> void:
    if !is_destroyed:
        if body is Bullet:
            if body.bullet_stats.inflicts_fire:
                burn()
                return
        explode()
