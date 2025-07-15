extends Node

const WORLD_GENERATION_DEBUG = false
const CHUNK_SIZE = 512
const CHUNK_RENDER_DISTANCE = 3
const CHUNK_UNLOAD_DISTANCE = 10
const CHUNK_UNLOAD_TIME = 30.0

var audio_settings: AudioSettings = AudioSettings.new()
var game_settings: GameSettings = GameSettings.new()

func load_from_file():
    var dict_from_file: Dictionary = Files.read_settings()
    if dict_from_file.has("audio_settings"):
        audio_settings = AudioSettings.from_dict(dict_from_file.get("audio_settings"))
    if dict_from_file.has("game_settings"):
        game_settings = GameSettings.from_dict(dict_from_file.get("game_settings"))

func save_to_file():
    var dict = {
        "audio_settings": audio_settings.to_dict(),
        "game_settings": game_settings.to_dict()
    }
    Files.write_settings(dict)
