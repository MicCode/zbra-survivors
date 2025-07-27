extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _ready() -> void:
    GameService.shake_screen.connect(shake)

func shake(strength: float):
    shake_strength = strength
    
func _process(delta: float) -> void:
    if shake_strength > 0.01:
        offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
        shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)
    else:
        offset = Vector2.ZERO
