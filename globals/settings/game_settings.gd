extends Resource
class_name GameSettings

@export var language: String
@export var camera_zoom: float
@export var map_opacity: float
@export var show_enemies_healthbar: bool
@export var enable_vibrations: bool
@export var display_xp_capture_radius: bool
@export var display_announcement_stickers: bool

func to_dict() -> Dictionary:
    var dict: Dictionary = {
        "language": TranslationServer.get_locale(),
        "camera_zoom": camera_zoom,
        "enable_vibrations": enable_vibrations,
        "map_opacity": map_opacity,
        "display_xp_capture_radius": display_xp_capture_radius,
        "display_announcement_stickers": display_announcement_stickers,
        "show_enemies_healthbar": show_enemies_healthbar
    }
    return dict

static func from_dict(dict: Dictionary) -> GameSettings:
    var settings: GameSettings = GameSettings.new()
    if dict.has("language"):
        settings.language = dict.get("language", "en")
        settings.camera_zoom = dict.get("camera_zoom", 1.3)
        settings.enable_vibrations = dict.get("enable_vibrations", true)
        settings.map_opacity = dict.get("map_opacity", 1.0)
        settings.display_xp_capture_radius = dict.get("display_xp_capture_radius", true)
        settings.display_announcement_stickers = dict.get("display_announcement_stickers", true)
        settings.show_enemies_healthbar = dict.get("show_enemies_healthbar", true)
        TranslationServer.set_locale(settings.language)
    return settings
