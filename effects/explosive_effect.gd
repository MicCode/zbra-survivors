extends Node2D
class_name ExplosiveEffect

signal explosion_finished

@export var damage = 50.0
@export var explosion_radius = 200.0

var is_from_bullet = false
var expansion_time = 0.15
var triggered = false
var already_damaged_nodes = []

func explode():
    GameService.shake_screen.emit(5.0)
    if is_from_bullet:
        Sounds.explosion(-15.0)
    else:
        Sounds.explosion()
    var damage_radius = %DamageRadius.shape as CircleShape2D
    damage_radius.radius = 1.0
    %ExplosionPanel.size = Vector2(0, 0)
    %ExplosionPanel.position = Vector2(0, 0)
    %ExplosionPanel.show()

    var modified_explosion_radius = explosion_radius * PlayerService.explosions_radius / 100
    triggered = true
    #get_tree().create_tween().tween_property(%Sprite2D, "modulate", Color.TRANSPARENT, expansion_time / 10)
    get_tree().create_tween().tween_property(%ExplosionPanel, "size", Vector2(modified_explosion_radius * 4, modified_explosion_radius * 4), expansion_time).finished.connect(func():
        %ExplosionPanel.hide()
    )
    get_tree().create_tween().tween_property(%ExplosionPanel, "position", Vector2(-modified_explosion_radius * 2, -modified_explosion_radius * 2), expansion_time)
    get_tree().create_tween().tween_property(damage_radius, "radius", modified_explosion_radius, expansion_time).connect("finished", func():
        explosion_finished.emit()
        queue_free()
    )

func _on_damage_area_area_entered(_area: Area2D) -> void:
    if triggered:
        deal_damage()

func _on_damage_area_body_entered(_body: Node2D) -> void:
    if triggered:
        deal_damage()

func deal_damage():
    for overlapping_body in %DamageArea.get_overlapping_bodies():
        var body_id = (overlapping_body as Node2D).get_instance_id()
        if !already_damaged_nodes.has(body_id):
            already_damaged_nodes.append(body_id)
            if overlapping_body is Enemy:
                (overlapping_body as Enemy).take_damage(damage * PlayerService.explosions_damage / 100)
            elif overlapping_body is EnvTree:
                (overlapping_body as EnvTree).explode()
            elif overlapping_body is LandMine:
                (overlapping_body as LandMine).explode()
