extends Node2D

const CHUNK_SIZE = Settings.CHUNK_SIZE
const CHUNK_RENDER_DISTANCE = Settings.CHUNK_RENDER_DISTANCE
const CHUNK_UNLOAD_DISTANCE = Settings.CHUNK_UNLOAD_DISTANCE
const CHUNK_UNLOAD_TIME = Settings.CHUNK_UNLOAD_TIME

var loaded_chunks := {}
var is_init = true

func _init() -> void:
    GameService.player_moved.connect(_on_player_moved)

func _on_player_moved(player_position: Vector2):
    update_chunks(player_position)
    is_init = false

func get_chunk_coords(player_position: Vector2) -> Vector2i:
    return Vector2i(floor(player_position.x / CHUNK_SIZE), floor(player_position.y / CHUNK_SIZE))

func update_chunks(player_position: Vector2):
    var player_chunk = get_chunk_coords(player_position)
    var new_chunks = {}
    for x in range(player_chunk.x - CHUNK_RENDER_DISTANCE, player_chunk.x + CHUNK_RENDER_DISTANCE + 1):
        for y in range(player_chunk.y - CHUNK_RENDER_DISTANCE, player_chunk.y + CHUNK_RENDER_DISTANCE + 1):
            var chunk_key = Vector2i(x, y)
            var distance_to_player = player_chunk.distance_to(chunk_key)
            if distance_to_player <= CHUNK_RENDER_DISTANCE:
                if not loaded_chunks.has(chunk_key):
                    loaded_chunks[chunk_key] = generate_chunk(chunk_key, chunk_key == player_chunk)
                new_chunks[chunk_key] = true

    var chunks_to_keep = {}
    for x in range(player_chunk.x - CHUNK_UNLOAD_DISTANCE, player_chunk.x + CHUNK_UNLOAD_DISTANCE + 1):
        for y in range(player_chunk.y - CHUNK_UNLOAD_DISTANCE, player_chunk.y + CHUNK_UNLOAD_DISTANCE + 1):
            var chunk_key = Vector2i(x, y)
            var distance_to_player = player_chunk.distance_to(chunk_key)
            if distance_to_player <= CHUNK_UNLOAD_DISTANCE:
                chunks_to_keep[chunk_key] = true

    # Supprimer les chunks devenus hors-champ
    for chunk_key in loaded_chunks.keys():
        if not chunks_to_keep.has(chunk_key):
            unload_chunk(chunk_key)


func generate_chunk(chunk_coords: Vector2i, is_same_as_player = false) -> Node2D:
    var world_pos = Vector2(chunk_coords.x * CHUNK_SIZE, chunk_coords.y * CHUNK_SIZE)
    var chunk_node = preload("res://environment/world_tiles/world_tile_1.tscn").instantiate()
    chunk_node.position = world_pos
    if is_init and is_same_as_player:
        chunk_node.is_spawn_zone = true
    add_child(chunk_node)

    return chunk_node

func unload_chunk(chunk_coords: Vector2i):
    var chunk = loaded_chunks[chunk_coords]
    if is_instance_valid(chunk):
        chunk.queue_free()
    loaded_chunks.erase(chunk_coords)
