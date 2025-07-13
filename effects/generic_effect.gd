extends Node2D
class_name GenericEffect

var fade_duration = 0.25

func fade_in() -> PropertyTweener:
    modulate = Color.TRANSPARENT
    return get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, fade_duration)

func fade_out() -> PropertyTweener:
    modulate = Color.WHITE
    return get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
