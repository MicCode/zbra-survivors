extends Bullet
class_name MeleeShockWave

const SCALE_FACTOR = 20

func _physics_process(delta):
    var scale_factor = travelled_distance / SCALE_FACTOR
    scale = Vector2(scale_factor, scale_factor)
    super._physics_process(delta)
