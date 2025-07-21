extends ConsumableItem
class_name XpCollector

func _ready() -> void:
    _rotate()
    %AnimationPlayer.active = false
    super._ready()

func _rotate():
    %Sprite.rotation_degrees = 0
    get_tree().create_tween().tween_property(%Sprite, "rotation_degrees", 360, 1.0).connect("finished", _rotate)
