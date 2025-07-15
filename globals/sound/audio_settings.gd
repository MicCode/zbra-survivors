extends Resource
class_name AudioSettings

@export var enable_music: bool = true
@export var master_volume_db: float = 0.0
@export var music_volume_db: float = -6.0
@export var effects_volume_db: float = 0.0

func to_dict() -> Dictionary:
    return {
        "enable_music": enable_music,
        "master_volume_db": master_volume_db,
        "music_volume_db": music_volume_db,
        "effects_volume_db": effects_volume_db,
    }

static func from_dict(dict: Dictionary) -> AudioSettings:
    var settings = AudioSettings.new()
    settings.enable_music = dict.get("enable_music", false)
    settings.master_volume_db = dict.get("master_volume_db", 0.0)
    settings.music_volume_db = dict.get("music_volume_db", -6.0)
    settings.effects_volume_db = dict.get("effects_volume_db", 0.0)
    return settings
