extends Resource
class_name GameSettings

@export var language: String
@export var camera_zoom: float

func to_dict() -> Dictionary:
    var dict: Dictionary = {
        "language": TranslationServer.get_locale(),
        "camera_zoom": camera_zoom
    }
    return dict

static func from_dict(dict: Dictionary) -> GameSettings:
    var settings: GameSettings = GameSettings.new()
    if dict.has("language"):
        settings.language = dict.get("language", "en")
        settings.camera_zoom = dict.get("camera_zoom", 1.3)
        TranslationServer.set_locale(settings.language)
    return settings
