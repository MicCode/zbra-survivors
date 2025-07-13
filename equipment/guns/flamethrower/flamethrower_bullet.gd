extends Bullet

const SCALE_FACTOR = 40

func _ready() -> void:
    %Effects.start_effect("burn", preload("res://effects/burn_effect.tscn"))
    %Effects.scale = Vector2(0.2, 0.2)

func _physics_process(delta):
    var scale_factor = travelled_distance / SCALE_FACTOR
    var new_scale = Vector2(scale_factor, scale_factor)
    %BulletSprite.scale = new_scale
    %Effects.scale = new_scale / 10
    super._physics_process(delta)
