extends Node2D

var CHUNK_SIZE = Settings.CHUNK_SIZE
var is_spawn_zone = false

func _ready() -> void:
    %Background.custom_minimum_size = Vector2(CHUNK_SIZE, CHUNK_SIZE)
    %Boundaries.custom_minimum_size = Vector2(CHUNK_SIZE, CHUNK_SIZE)
    if Settings.WORLD_GENERATION_DEBUG:
        %Boundaries.show()
    else:
        %Boundaries.hide()

    if !is_spawn_zone:
        place_random(preload("res://environment/tree.tscn"), 20)
    place_random(preload("res://environment/grass1.tscn"), 20)
    place_random(preload("res://environment/grass2.tscn"), 20)
    place_random(preload("res://environment/grass3.tscn"), 20)
    place_random(preload("res://environment/grass4.tscn"), 20)


func place_random(scene: Resource, n: int):
    for i in n:
        var random_position_in_chunk = Vector2(
            randi_range(0, CHUNK_SIZE - 1),
            randi_range(0, CHUNK_SIZE - 1),
        )
        var instance = scene.instantiate()
        instance.position = random_position_in_chunk
        instance.y_sort_enabled = true
        instance.z_as_relative = false
        add_child(instance)
