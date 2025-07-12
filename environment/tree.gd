extends StaticBody2D
class_name EnvTree

var is_destroyed = false

func explode():
    if !is_destroyed:
        is_destroyed = true
        destroy("explode")
        %LightOccluder2D.hide()

func burn():
    if !is_destroyed:
        is_destroyed = true
        destroy("burn")
        %FireLight.show()
        %FireLightAnimation.play("fadeout")

func wither():
    if !is_destroyed:
        is_destroyed = true
        destroy("wither")
        %LightOccluder2D.hide()

func destroy(effect_name: String):
    %Sprite.play(effect_name)
    Sounds.tree_destroyed()
    set_collision_layer_value(3, false)
    set_collision_layer_value(8, false)

func _on_sprite_animation_finished():
    if is_destroyed:
        %Shadow.queue_free()
        %FireLight.hide()

func _on_explode_zone_area_entered(body: Node2D) -> void:
    if !is_destroyed:
        if body is Bullet:
            if body.bullet_stats.inflicts_fire:
                burn()
                return
        explode()
