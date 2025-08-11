extends Bullet

func _physics_process(delta: float) -> void:
    if exploded:
        modulate = Color.WEB_MAROON
    super._physics_process(delta)
