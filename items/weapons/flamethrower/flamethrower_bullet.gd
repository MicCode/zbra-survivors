extends Bullet

const SCALE_FACTOR = 40

func _enter_tree() -> void:
    %BulletSprite.scale = Vector2(0,0)
    %BurnEffect.scale = Vector2(0,0)
    %BurnEffect.intensity = 1.0

func _physics_process(delta):
    var scale_factor = travelled_distance / SCALE_FACTOR
    var new_scale = Vector2(scale_factor, scale_factor)
    %BulletSprite.scale = new_scale
    %BurnEffect.scale = new_scale / 10
    %BurnEffect.intensity = clamp((bullet_stats.fly_range / travelled_distance) + 1, 1.0, 2.0)
    super._physics_process(delta)
