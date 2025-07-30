extends Node

const SFX_BASE_PATH := "res://assets/sounds/"
const MUSIC_BASE_PATH := "res://assets/musics/"

const MAX_SFX_PLAYERS := 32
const MAX_EFFECTS_PLAYERS := 32

var music_player_1: AudioStreamPlayer
var music_player_2: AudioStreamPlayer
var current_music_player_id = 1
var music_cache: Dictionary = {}

var sfx_players: Array = []
var sfx_cache: Dictionary = {}

var announcer_player: AudioStreamPlayer

var effects_players: Dictionary = {}
var effects_cache: Dictionary = {}

func apply_audio_settings():
    var master_bus = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(master_bus, Settings.audio_settings.master_volume_db)

    var music_bus = AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(music_bus, Settings.audio_settings.music_volume_db - 6.0)
    var effects_bus = AudioServer.get_bus_index("Effects")
    AudioServer.set_bus_volume_db(effects_bus, Settings.audio_settings.effects_volume_db)
    var sfx_bus = AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(sfx_bus, Settings.audio_settings.effects_volume_db)

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    music_player_1 = AudioStreamPlayer.new()
    add_child(music_player_1)
    music_player_1.name = "MusicPlayer 1"
    music_player_1.set_autoplay(false)

    music_player_2 = AudioStreamPlayer.new()
    add_child(music_player_2)
    music_player_2.name = "MusicPlayer 2"
    music_player_2.set_autoplay(false)

func _load_sfx_stream(file_name: String) -> AudioStream:
    if sfx_cache.has(file_name):
        return sfx_cache[file_name]

    var path = file_name
    if !path.begins_with(SFX_BASE_PATH):
        path = SFX_BASE_PATH + path
    var stream = load(path)
    if stream is AudioStream:
        sfx_cache[file_name] = stream
        return stream
    push_error("SFX file not found: " + path)
    return null

func _load_effect_stream(file_name: String) -> AudioStream:
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

func _load_music_stream(file_name: String) -> AudioStream:
    if music_cache.has(file_name):
        return music_cache[file_name]

    var path = MUSIC_BASE_PATH + file_name
    var stream = load(path)
    if stream is AudioStream:
        music_cache[file_name] = stream
        return stream
    push_error("Music file not found: " + path)
    return null

func start_effect(file_name: String, options: SfxOptions = SfxOptions.new()):
    if effects_players.has(file_name):
        return

    var stream = _load_effect_stream(file_name)
    if stream == null:
        return

    if effects_players.size() >= MAX_EFFECTS_PLAYERS:
        var oldest_player = effects_players.get(effects_players.keys().pop_front())
        if is_instance_valid(oldest_player):
            oldest_player.queue_free()

    var player = await _play_sound(stream, "Effects", options)
    player.finished.connect(_on_effect_finished.bind(player))
    effects_players.set(file_name, player)

func _on_effect_finished(player: AudioStreamPlayer):
    player.play()

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

func play_sfx(file_name: String, options: SfxOptions = SfxOptions.new()):
    var stream = _load_sfx_stream(file_name)
    if stream == null:
        return

    if sfx_players.size() >= MAX_SFX_PLAYERS:
        var oldest_player = sfx_players.pop_front()
        if is_instance_valid(oldest_player):
            oldest_player.queue_free()

    var player = await _play_sound(stream, "SFX", options)
    player.finished.connect(_on_sfx_finished.bind(player))
    sfx_players.append(player)

func _on_sfx_finished(player: AudioStreamPlayer):
    if sfx_players.has(player):
        sfx_players.erase(player)
    if is_instance_valid(player):
        player.queue_free()

func _play_sound(stream: AudioStream, bus: String, options: SfxOptions) -> AudioStreamPlayer:

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

func announce(file_name: String, options: SfxOptions = SfxOptions.new()):
    var stream = _load_sfx_stream(file_name)
    if stream == null:
        return
    if announcer_player != null and announcer_player.playing:
        announcer_player.stop()
    announcer_player = await _play_sound(stream, "Announcements", options)

func play_music(file_name: String, transition_duration: float = 1.0, loop: bool = true):
    var new_stream = _load_music_stream(file_name)
    if new_stream == null:
        return

    var current_music_player: AudioStreamPlayer
    if current_music_player_id == 1:
        current_music_player = music_player_1
    else:
        current_music_player = music_player_2

    if current_music_player.stream and current_music_player.stream.resource_path.get_file() == file_name:
        return

    create_tween().tween_property(current_music_player, "volume_db", -40.0, transition_duration).finished.connect(func():
        current_music_player.stop()
    )
    _fade_music_in(new_stream, 0.0, transition_duration, loop)

func _fade_music_in(new_stream: AudioStream, target_volume: float, transition_duration: float, loop: bool):
    var new_music_player: AudioStreamPlayer
    if current_music_player_id == 1:
        current_music_player_id = 2
        new_music_player = music_player_2
    else:
        current_music_player_id = 1
        new_music_player = music_player_1

    new_music_player.stream = new_stream
    new_music_player.bus = "Music"
    new_music_player.volume_db = -40.0  # démarrage silencieux
    new_music_player.play()

    if loop:
        if !new_music_player.finished.is_connected(_on_music_finished):
            new_music_player.finished.connect(_on_music_finished)
    else:
        if new_music_player.finished.is_connected(_on_music_finished):
            new_music_player.finished.disconnect(_on_music_finished)

    create_tween().tween_property(new_music_player, "volume_db", target_volume, transition_duration)

func _on_music_finished():
    if current_music_player_id == 1:
        music_player_1.play()
    else:
        music_player_2.play()

func stop_music():
    if current_music_player_id == 1:
        music_player_1.stop()
    else:
        music_player_2.stop()
