extends Node2D

func _ready() -> void:
    if Settings.WORLD_GENERATION_DEBUG:
        %RenderDistanceCircle.custom_minimum_size = Vector2(
            Settings.CHUNK_RENDER_DISTANCE * Settings.CHUNK_SIZE * 2,
            Settings.CHUNK_RENDER_DISTANCE * Settings.CHUNK_SIZE * 2
        )
        %RenderDistanceCircle.show()

        %DisapearDistanceCircle.custom_minimum_size = Vector2(
            Settings.CHUNK_UNLOAD_DISTANCE * Settings.CHUNK_SIZE * 2,
            Settings.CHUNK_UNLOAD_DISTANCE * Settings.CHUNK_SIZE * 2
        )
        %DisapearDistanceCircle.show()
