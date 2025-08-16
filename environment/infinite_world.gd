extends Node2D

var loaded_chunks := {}
var is_init = true

var is_one_chest_on_map = false
var can_spawn_chest = false

func _init() -> void:
    PlayerService.reset()
    PlayerService.player_moved.connect(_on_player_moved)
    PlayerService.player_openned_chest.connect(func():
        is_one_chest_on_map = false # FIXME this may not be correct the day we spawn chests in other way (not in world generation)
        restart_chest_spawn_timer()
    )

func _ready() -> void:
    restart_chest_spawn_timer()

func _on_player_moved(player_position: Vector2):
    if !%UpdateTimer.is_stopped():
        return

    update_chunks(player_position)
    if !is_one_chest_on_map and can_spawn_chest:
        create_chest_on_map(player_position)

    is_init = false
    %UpdateTimer.start(Settings.CHUNK_UPDATE_INTERVAL)

func restart_chest_spawn_timer():
    can_spawn_chest = false
    var time_to_spawn = randf_range(Settings.MINIMAL_TIME_BETWEEN_CHEST_SPAWN, Settings.MAXIMAL_TIME_BETWEEN_CHEST_SPAWN)
    time_to_spawn = max(Utils.sub_percent(time_to_spawn, PlayerService.player_stats.luck * 10), Settings.MINIMAL_TIME_BETWEEN_CHEST_SPAWN)
    %ChestSpawnTimer.start(time_to_spawn)

func _on_chest_spawn_timer_timeout() -> void:
    can_spawn_chest = true

func create_chest_on_map(player_position: Vector2):
    var random_position = _get_random_position_around_player(player_position)
    var new_chest = preload("res://items/loot_chest.tscn").instantiate()
    new_chest.global_position = random_position
    add_child(new_chest)
    Sounds.chest_available()

    is_one_chest_on_map = true

func _get_random_position_around_player(player_position: Vector2) -> Vector2:
    var angle = randf_range(0.0, TAU)
    var distance = randf_range(Settings.MINIMAL_DISTANCE_FROM_CHEST, Settings.MAXIMAL_DISTANCE_FROM_CHEST)
    var offset = Vector2.RIGHT.rotated(angle) * Utils.sub_percent(distance, PlayerService.player_stats.luck * 10)
    return player_position + offset

func get_chunk_coords(player_position: Vector2) -> Vector2i:
    return Vector2i(floor(player_position.x / Settings.CHUNK_SIZE), floor(player_position.y / Settings.CHUNK_SIZE))

func update_chunks(player_position: Vector2):
    var player_chunk = get_chunk_coords(player_position)
    var new_chunks = {}
    for x in range(player_chunk.x - Settings.CHUNK_RENDER_DISTANCE, player_chunk.x + Settings.CHUNK_RENDER_DISTANCE + 1):
        for y in range(player_chunk.y - Settings.CHUNK_RENDER_DISTANCE, player_chunk.y + Settings.CHUNK_RENDER_DISTANCE + 1):
            var chunk_key = Vector2i(x, y)
            var distance_to_player = player_chunk.distance_to(chunk_key)
            if distance_to_player <= Settings.CHUNK_RENDER_DISTANCE:
                if not loaded_chunks.has(chunk_key):
                    loaded_chunks[chunk_key] = generate_chunk(chunk_key, chunk_key == player_chunk)
                new_chunks[chunk_key] = true

    var chunks_to_keep = {}
    for x in range(player_chunk.x - Settings.CHUNK_UNLOAD_DISTANCE, player_chunk.x + Settings.CHUNK_UNLOAD_DISTANCE + 1):
        for y in range(player_chunk.y - Settings.CHUNK_UNLOAD_DISTANCE, player_chunk.y + Settings.CHUNK_UNLOAD_DISTANCE + 1):
            var chunk_key = Vector2i(x, y)
            var distance_to_player = player_chunk.distance_to(chunk_key)
            if distance_to_player <= Settings.CHUNK_UNLOAD_DISTANCE:
                chunks_to_keep[chunk_key] = true

    # Supprimer les chunks devenus hors-champ
    for chunk_key in loaded_chunks.keys():
        if not chunks_to_keep.has(chunk_key):
            unload_chunk(chunk_key)


func generate_chunk(chunk_coords: Vector2i, is_same_as_player = false) -> Node2D:
    var world_pos = Vector2(chunk_coords.x * Settings.CHUNK_SIZE, chunk_coords.y * Settings.CHUNK_SIZE)
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
