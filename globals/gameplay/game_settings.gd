extends Resource
class_name GameSettings

@export var language: String = TranslationServer.get_locale()

func to_dict() -> Dictionary:
    var dict: Dictionary = {
        "language": TranslationServer.get_locale()
    }
    return dict

static func from_dict(dict: Dictionary) -> GameSettings:
    var settings: GameSettings = GameSettings.new()
    if dict.has("language"):
        settings.language = dict.get("language")
        TranslationServer.set_locale(settings.language)
    return settings
