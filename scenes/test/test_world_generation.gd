extends Node2D

func _ready() -> void:
    if GameSettings.WORLD_GENERATION_DEBUG:
        %RenderDistanceCircle.custom_minimum_size = Vector2(
            GameSettings.CHUNK_RENDER_DISTANCE * GameSettings.CHUNK_SIZE * 2,
            GameSettings.CHUNK_RENDER_DISTANCE * GameSettings.CHUNK_SIZE * 2
        )
        %RenderDistanceCircle.show()

        %DisapearDistanceCircle.custom_minimum_size = Vector2(
            GameSettings.CHUNK_UNLOAD_DISTANCE * GameSettings.CHUNK_SIZE * 2,
            GameSettings.CHUNK_UNLOAD_DISTANCE * GameSettings.CHUNK_SIZE * 2
        )
        %DisapearDistanceCircle.show()
