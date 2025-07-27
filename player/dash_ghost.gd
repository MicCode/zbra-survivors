extends Sprite2D
class_name DashGhost

@export var speed_scale: float = 5.0

func _ready() -> void:
    %AnimationPlayer.speed_scale = speed_scale

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
    queue_free()
