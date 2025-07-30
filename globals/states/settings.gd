extends Node
signal settings_changed

const WORLD_GENERATION_DEBUG: bool = false
const CHUNK_SIZE: int = 512
const CHUNK_RENDER_DISTANCE: int = 3
const CHUNK_UNLOAD_DISTANCE: int = 10
const CHUNK_UNLOAD_TIME: float = 30.0
const CHUNK_UPDATE_INTERVAL: float = 0.5

const MINIMAL_TIME_BETWEEN_CHEST_SPAWN: float = 10.0
const MAXIMAL_TIME_BETWEEN_CHEST_SPAWN: float = 20.0
const MINIMAL_DISTANCE_FROM_CHEST: float = 3_000
const MAXIMAL_DISTANCE_FROM_CHEST: float = 4_000

var audio_settings: AudioSettings = AudioSettings.new()
var game_settings: GameSettings = GameSettings.new()

func load_from_file():
    var dict_from_file: Dictionary = Files.read_settings()
    if dict_from_file.has("audio_settings"):
        audio_settings = AudioSettings.from_dict(dict_from_file.get("audio_settings"))
    else:
        audio_settings = preload("res://globals/sound/default_audio_settings.tres").duplicate()

    if dict_from_file.has("game_settings"):
        game_settings = GameSettings.from_dict(dict_from_file.get("game_settings"))
    else:
        game_settings = preload("res://globals/gameplay/default_game_settings.tres").duplicate()
    settings_changed.emit()

func save_to_file():
    var dict = {
        "audio_settings": audio_settings.to_dict(),
        "game_settings": game_settings.to_dict()
    }
    Files.write_settings(dict)
