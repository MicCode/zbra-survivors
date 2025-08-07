extends Node

const SFX_BASE_PATH := "res://assets/sounds/"
const MAX_SFX_PLAYERS := 32
const MAX_EFFECTS_PLAYERS := 32

var sfx_players: Array = []
var sfx_cache: Dictionary = {}

var effects_players: Dictionary = {}
var effects_cache: Dictionary = {}

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS

#region SFX ---------------------------------------------------------------------------------------
func play_sfx(file_name: String, options: SfxOptions = SfxOptions.new()):
    var stream = load_sfx_stream(file_name, true)
    if stream == null:
        return

    if sfx_players.size() >= MAX_SFX_PLAYERS:
        var oldest_player = sfx_players.pop_front()
        if is_instance_valid(oldest_player):
            oldest_player.queue_free()

    var player = await play_sound(stream, "SFX", options)
    player.finished.connect(_on_sfx_finished.bind(player))
    sfx_players.append(player)

func load_sfx_stream(file_name: String, use_cache: bool = false) -> AudioStream:
    if use_cache and sfx_cache.has(file_name):
        return sfx_cache[file_name]

    var path = file_name
    if !path.begins_with(SFX_BASE_PATH):
        path = SFX_BASE_PATH + path
    var stream = load(path)
    if stream is AudioStream:
        if use_cache:
            sfx_cache[file_name] = stream
        return stream
    push_error("SFX file not found: " + path)
    return null

func _on_sfx_finished(player: AudioStreamPlayer):
    if sfx_players.has(player):
        sfx_players.erase(player)
    if is_instance_valid(player):
        player.queue_free()
#endregion

#region effects ---------------------------------------------------------------------------------------
func start_effect(file_name: String, options: SfxOptions = SfxOptions.new()):
    if effects_players.has(file_name):
        return

    var stream = load_effect_stream(file_name)
    if stream == null:
        return

    if effects_players.size() >= MAX_EFFECTS_PLAYERS:
        var oldest_player = effects_players.get(effects_players.keys().pop_front())
        if is_instance_valid(oldest_player):
            oldest_player.queue_free()

    var player = await play_sound(stream, "Effects", options)
    player.finished.connect(_on_effect_finished.bind(player))
    effects_players.set(file_name, player)

func stop_effect(file_name: String):
    var existing_player = effects_players.get(file_name)
    if existing_player:
        effects_players.erase(file_name)
        # TODO add fade out effect ?
        if is_instance_valid(existing_player):
            existing_player.queue_free()

func stop_all_effects():
    for player in effects_players:
        effects_players.get(player).queue_free()
    effects_players = {}

func load_effect_stream(file_name: String) -> AudioStream:
    if effects_cache.has(file_name):
        return effects_cache[file_name]

    var path = file_name
    if !path.begins_with(SFX_BASE_PATH):
        path = SFX_BASE_PATH + path
    var stream = load(path)
    if stream is AudioStream:
        effects_cache[file_name] = stream
        return stream
    push_error("Effect file not found: " + path)
    return null

func _on_effect_finished(player: AudioStreamPlayer):
    player.play()
#endregion

#region player ---------------------------------------------------------------------------------------
func play_sound(stream: AudioStream, bus: String, options: SfxOptions) -> AudioStreamPlayer:
    var player = AudioStreamPlayer.new()
    player.stream = stream
    player.bus = bus
    player.volume_db = options.volume
    player.pitch_scale = max(0.01, randf_range(options.pitch - options.pitch_variation, options.pitch + options.pitch_variation))
    player.name = bus + "_" + str(Time.get_ticks_msec())

    add_child(player)
    if options.start_delay_ms + options.start_delay_variation_ms > 0:
        await get_tree().create_timer(max(0.01, options.start_delay_ms + randf_range(0.0, options.start_delay_variation_ms)) / 1000.0).timeout
    player.play()

    return player
#endregion