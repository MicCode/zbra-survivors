extends GenericEffect

@export var intensity: float = 1.0:
    set(new_intensity):
        intensity = new_intensity
        if transition_tween and transition_tween.is_running():
            transition_tween.stop()
        if has_node("%Light"):
            %Light.energy = intensity + 1.0

var transition_tween: Tween

func fade_in() -> PropertyTweener:
    super.fade_in()
    return get_tree().create_tween().tween_property(%Light, "energy", intensity + 1.0 , fade_duration)

func fade_out() -> PropertyTweener:
    super.fade_out()
    return get_tree().create_tween().tween_property(%Light, "energy", (intensity + 1.0) / 2 , fade_duration)

func alter_intensity(offset: float):
    var final_energy = intensity + 1.0 + offset
    if transition_tween and transition_tween.is_running():
        transition_tween.stop()
    transition_tween = get_tree().create_tween()
    transition_tween.tween_property(%Light, "energy", final_energy, 0.2)
