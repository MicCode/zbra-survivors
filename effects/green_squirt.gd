extends Bleed

func _init() -> void:
    sprite_from_left = true

func _enter_tree() -> void:
    var animations = ["horizontal-1", "horizontal-2"]
    play(animations[randi_range(0, 1)])
