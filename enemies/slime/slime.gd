extends Enemy

var is_original = true

func _ready() -> void:
    if is_original:
        scale = Vector2(2, 2)
    super._ready()

func bleed(impact_from: Vector2):
    VisualEffects.green_squirt(global_position, impact_from)


func _on_squirt_timer_timeout() -> void:
    bleed(PlayerService.player_instance.global_position)

func die():
    if is_original:
        var children_to_spawn = 3
        if stats.is_elite:
            children_to_spawn = 5
        call_deferred("spawn_children", children_to_spawn)
    super.die()

func spawn_children(n: int):
    for i in n:
        var child = preload("res://enemies/slime/slime.tscn").instantiate()
        child.stats = stats.duplicate()
        child.stats.max_health /= 2
        child.stats.xp_value /= 2
        child.global_position = global_position + Vector2(randf_range(-1, 1), randf_range(-1, 1))
        if child.stats.is_elite:
            child.stats.is_elite = false
            child.is_original = true
        else:
            child.is_original = false
        SceneManager.current_scene.add_child(child)
