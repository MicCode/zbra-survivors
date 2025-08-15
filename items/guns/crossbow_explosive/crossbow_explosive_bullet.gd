extends Bullet

func _physics_process(delta: float) -> void:
    if has_exploded:
        modulate = Color.WEB_MAROON
    super._physics_process(delta)
