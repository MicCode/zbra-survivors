extends Bullet

const SCALE_FACTOR = 30

func _ready() -> void:
    bullet_disapear_delay = 0.1

func _physics_process(delta):
    var scale_factor = travelled_distance / SCALE_FACTOR
    scale = Vector2(scale_factor, scale_factor)
    super._physics_process(delta)
