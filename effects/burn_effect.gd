extends GenericEffect

func fade_in() -> PropertyTweener:
    super.fade_in()
    return get_tree().create_tween().tween_property(%Light, "energy", 2.0 , fade_duration)

func fade_out() -> PropertyTweener:
    super.fade_out()
    return get_tree().create_tween().tween_property(%Light, "energy", 1.4 , fade_duration)
