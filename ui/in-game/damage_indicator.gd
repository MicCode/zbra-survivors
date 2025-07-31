extends Node2D
class_name DamageIndicator

var damage: float = 0.0

func with_damage(_damage: float) -> DamageIndicator:
    damage = _damage
    return self

func _ready() -> void:
    set_damage(damage)

func set_damage(new_damage: float):
    damage = new_damage
    %Label.text = str("%d" % ceil(new_damage))


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
    queue_free()
