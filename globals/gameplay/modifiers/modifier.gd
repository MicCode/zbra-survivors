class_name Mod

var name: E.ModName
var type: E.ModType
var stat_name: String
var texture_image_name: String
var modification_value: float
var is_absolute: bool

static func create(_name: E.ModName, _type: E.ModType, _stat_name: String, _texture_image_name: String, _modification_value: float, _is_absolute: bool = false) -> Mod:
    var mod = Mod.new()
    mod.name = _name
    mod.type = _type
    mod.stat_name = _stat_name
    mod.texture_image_name = _texture_image_name
    mod.modification_value = _modification_value
    mod.is_absolute = _is_absolute
    return mod

func to_stats_modifier() -> StatsModifier:
    if is_absolute:
        return StatsModifier.create_absolute(name, modification_value)
    else:
        return StatsModifier.create_percent(name, modification_value)

func get_display_label() -> String:
    return tr(str("LABEL_%s" % stat_name).to_upper())

func get_sprite() -> Texture2D:
    var texture_path = "%s/%s.png" % [ModsService.MODIFIERS_TEXTURES_FOLDER, texture_image_name]
    var found_texture = load(texture_path)
    var is_error = false
    if !found_texture:
        push_warning("Texture for [%s] not found at path [%s]" % [
            E.mod_name(name),
            texture_path,
        ])
        is_error = true
    elif found_texture is not Texture2D:
        push_warning("Found texture with path [%s] but it's not a Texture2D" % texture_path)
        is_error = true

    if is_error:
        return preload("res://assets/sprites/modifiers/unknown.png")
    else:
        return found_texture
