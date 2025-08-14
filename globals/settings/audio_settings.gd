extends Resource
class_name AudioSettings

@export var master_volume_db: float
@export var music_volume_db: float
@export var effects_volume_db: float
@export var announcements_volume_db: float

func to_dict() -> Dictionary:
    return {
        "master_volume_db": master_volume_db,
        "music_volume_db": music_volume_db,
        "effects_volume_db": effects_volume_db,
        "announcements_volume_db": announcements_volume_db,
    }

static func from_dict(dict: Dictionary) -> AudioSettings:
    var settings = AudioSettings.new()
    settings.master_volume_db = dict.get("master_volume_db", 0.0)
    settings.music_volume_db = dict.get("music_volume_db", -6.0)
    settings.effects_volume_db = dict.get("effects_volume_db", 0.0)
    settings.announcements_volume_db = dict.get("announcements_volume_db", 0.0)
    return settings
