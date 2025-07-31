extends Node

const MODIFIERS_TEXTURES_FOLDER: String = "res://assets/sprites/modifiers"

var all: Array[Mod] = [
    # PLAYER MODS
    Mod.create(Name.PLAYER_MAX_HEALTH, Type.PLAYER, "max_health", "max-heath-up", 1.0, true),
    Mod.create(Name.PLAYER_XP_COLLECT_RADIUS, Type.PLAYER, "xp_collect_radius", "xp-collect-range-up", 10.0),
    Mod.create(Name.PLAYER_MOVE_SPEED, Type.PLAYER, "move_speed", "speed-up", 5.0),
    Mod.create(Name.PLAYER_DASH_DURATION, Type.PLAYER, "dash_duration", "dash-duration-up", 10.0),
    Mod.create(Name.PLAYER_DASH_COOLDOWN, Type.PLAYER, "dash_cooldown", "dash-cooldown-down", -10.0),
    Mod.create(Name.PLAYER_DASH_SPEED_MULTIPLIER, Type.PLAYER, "dash_speed_multiplier", "dash-speed-up", 5.0),

    # GUN MODS
    # Mod.create(Name.GUN_COOLDOWN, Type.GUN, "stat_name", "", 0.0),
    # Mod.create(Name.GUN_FIRE_RATE, Type.GUN, "stat_name", "", 0.0),
    # Mod.create(Name.BULLET_DAMAGE, Type.GUN, "stat_name", "", 0.0),
    # Mod.create(Name.BULLET_NUMBER, Type.GUN, "stat_name", "", 0.0),
    # Mod.create(Name.BULLET_SPEED, Type.GUN, "stat_name", "", 0.0),
    # Mod.create(Name.BULLET_SPREAD_ANGLE_MORE, Type.GUN, "stat_name", "", 0.0),
    # Mod.create(Name.BULLET_SPREAD_ANGLE_LESS, Type.GUN, "stat_name", "", 0.0),

    # EXPLOSION MODS
    # Mod.create(Name.EXPLOSION_RADIUS, Type.EXPLOSION, "stat_name", "", 0.0),
    # Mod.create(Name.EXPLOSION_DAMAGE, Type.EXPLOSION, "stat_name", "", 0.0),
]

enum Name {
    # PLAYER MODIFIERS
    PLAYER_MAX_HEALTH,
    PLAYER_XP_COLLECT_RADIUS,
    PLAYER_MOVE_SPEED,
    PLAYER_DASH_DURATION,
    PLAYER_DASH_COOLDOWN,
    PLAYER_DASH_SPEED_MULTIPLIER,

    # GUN MODIFIERS
    GUN_COOLDOWN,
    GUN_FIRE_RATE,
    BULLET_DAMAGE,
    BULLET_NUMBER,
    BULLET_SPEED,
    BULLET_SPREAD_ANGLE_MORE,
    BULLET_SPREAD_ANGLE_LESS,

    # EXPLOSION MODIFIERS
    EXPLOSION_RADIUS,
    EXPLOSION_DAMAGE,
}

func get_name_label(mod_name: Name) -> String:
    match mod_name:
        # PLAYER MODIFIERS
        Name.PLAYER_MAX_HEALTH: return "PLAYER_MAX_HEALTH"
        Name.PLAYER_XP_COLLECT_RADIUS: return "PLAYER_XP_COLLECT_RADIUS"
        Name.PLAYER_MOVE_SPEED: return "PLAYER_MOVE_SPEED"
        Name.PLAYER_DASH_DURATION: return "PLAYER_DASH_DURATION"
        Name.PLAYER_DASH_COOLDOWN: return "PLAYER_DASH_COOLDOWN"
        Name.PLAYER_DASH_SPEED_MULTIPLIER: return "PLAYER_DASH_SPEED_MULTIPLIER"

        # GUN MODIFIERS
        Name.GUN_COOLDOWN: return "GUN_COOLDOWN"
        Name.GUN_FIRE_RATE: return "GUN_FIRE_RATE"
        Name.BULLET_DAMAGE: return "BULLET_DAMAGE"
        Name.BULLET_NUMBER: return "BULLET_NUMBER"
        Name.BULLET_SPEED: return "BULLET_SPEED"
        Name.BULLET_SPREAD_ANGLE_MORE: return "BULLET_SPREAD_ANGLE_MORE"
        Name.BULLET_SPREAD_ANGLE_LESS: return "BULLET_SPREAD_ANGLE_LESS"

        # EXPLOSION MODIFIERS
        Name.EXPLOSION_RADIUS: return "EXPLOSION_RADIUS"
        Name.EXPLOSION_DAMAGE: return "EXPLOSION_DAMAGE"

        _:
            push_warning("Unknown Modifiers.Name with index [%d]" % mod_name)
            return "???"

enum Type {
    UNKNOWN,
    PLAYER,
    GUN,
    EXPLOSION,
}

func get_type_label(type: Type) -> String:
    match type:
        Type.PLAYER: return "PLAYER"
        Type.GUN: return "GUN"
        Type.EXPLOSION: return "EXPLOSION"
        _:
            push_warning("Unknown Modifiers.Type with index [%d]" % type)
            return "???"

class Mod:
    var name: Name
    var type: Type
    var stat_name: String
    var texture_image_name: String
    var modification_value: float
    var is_absolute: bool

    static func create(_name: Name, _type: Type, _stat_name: String, _texture_image_name: String, _modification_value: float, _is_absolute: bool = false) -> Mod:
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
        var texture_path = "%s/%s.png" % [Modifiers.MODIFIERS_TEXTURES_FOLDER, texture_image_name]
        var found_texture = load(texture_path)
        var is_error = false
        if !found_texture:
            push_warning("Texture for [%s] not found at path [%s]" % [
                Modifiers.get_name_label(name),
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

func get_stat_name(mod_name: Name) -> String:
    var found_mod: Array[Mod] = all.filter(func(m: Mod): return m.name == mod_name)
    if found_mod.is_empty():
        push_warning("Cannot get stat_name for unknown mod_name [%s]" % mod_name)
        return "???"
    return found_mod[0].stat_name

func get_type(mod_name: Name) -> Type:
    var found_mod: Array[Mod] = all.filter(func(m: Mod): return m.name == mod_name)
    if found_mod.is_empty():
        push_warning("Cannot get type for unknown mod_name [%s]" % mod_name)
        return Type.UNKNOWN
    return found_mod[0].type
