extends Node

const MODIFIERS_TEXTURES_FOLDER: String = "res://assets/sprites/modifiers"

var all: Array[Mod] = [
    # PLAYER MODS
    Mod.create(Name.PLAYER_MAX_HEALTH, Type.PLAYER, "max_health", "max-heath-up", 1, true),
    Mod.create(Name.PLAYER_XP_COLLECT_RADIUS, Type.PLAYER, "xp_collect_radius", "xp-collect-range-up", 50.0),
    Mod.create(Name.PLAYER_MOVE_SPEED, Type.PLAYER, "move_speed", "speed-up", 10.0),
    Mod.create(Name.PLAYER_DASH_DURATION, Type.PLAYER, "dash_duration", "dash-duration-up", 20.0),
    Mod.create(Name.PLAYER_DASH_COOLDOWN, Type.PLAYER, "dash_cooldown", "dash-cooldown-down", -20.0),
    Mod.create(Name.PLAYER_DASH_SPEED_MULTIPLIER, Type.PLAYER, "dash_speed_multiplier", "dash-speed-up", 10.0),

    # GUN MODS
    Mod.create(Name.GUN_FIRE_RATE, Type.GUN, "shots_per_s", "gun-fire-rate-up", 25.0),
    Mod.create(Name.GUN_SPREAD_ANGLE_MORE, Type.GUN, "bullets_spread_angle_deg", "bullet-spread-angle-up", 30.0),
    Mod.create(Name.GUN_SPREAD_ANGLE_LESS, Type.GUN, "bullets_spread_angle_deg", "bullet-spread-angle-down", -30.0),
    Mod.create(Name.GUN_BULLET_NUMBER, Type.GUN, "bullets_per_shot", "bullet-per-shot-up", 2, true),

    # BULLET MODS
    Mod.create(Name.BULLET_DAMAGE, Type.BULLET, "damage", "damage-up", 10.0),
    Mod.create(Name.BULLET_SPEED, Type.BULLET, "speed", "bullet-speed-up", 20.0),
    Mod.create(Name.BULLET_RANGE, Type.BULLET, "fly_range", "bullet-range-up", 20.0),
    Mod.create(Name.BULLET_PIERCE_COUNT, Type.BULLET, "pierce_count", "piercing-plus", 1, true),

    # EXPLOSION MODS
    Mod.create(Name.EXPLOSION_RADIUS, Type.EXPLOSION, "explosion_radius", "explosion-damage-radius-up", 25.0),
    Mod.create(Name.EXPLOSION_DAMAGE, Type.EXPLOSION, "explosion_damage", "explosion-damage-up", 10.0),
]
var excluded: Array[Mod] = []

enum Name {
    # PLAYER MODIFIERS
    PLAYER_MAX_HEALTH,
    PLAYER_XP_COLLECT_RADIUS,
    PLAYER_MOVE_SPEED,
    PLAYER_DASH_DURATION,
    PLAYER_DASH_COOLDOWN,
    PLAYER_DASH_SPEED_MULTIPLIER,

    # GUN MODIFIERS
    GUN_FIRE_RATE,
    GUN_SPREAD_ANGLE_MORE,
    GUN_SPREAD_ANGLE_LESS,
    GUN_BULLET_NUMBER,

    # BULLET MODIFIERS
    BULLET_DAMAGE,
    BULLET_SPEED,
    BULLET_RANGE,
    BULLET_PIERCE_COUNT,

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
        Name.GUN_FIRE_RATE: return "GUN_FIRE_RATE"
        Name.GUN_SPREAD_ANGLE_MORE: return "GUN_SPREAD_ANGLE_MORE"
        Name.GUN_SPREAD_ANGLE_LESS: return "GUN_SPREAD_ANGLE_LESS"
        Name.GUN_BULLET_NUMBER: return "GUN_BULLET_NUMBER"

        # BULLET MODIFIERS
        Name.BULLET_DAMAGE: return "BULLET_DAMAGE"
        Name.BULLET_SPEED: return "BULLET_SPEED"
        Name.BULLET_RANGE: return "BULLET_RANGE"
        Name.BULLET_PIERCE_COUNT: return "BULLET_PIERCE_COUNT"

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
    BULLET,
    EXPLOSION,
}

func get_type_label(type: Type) -> String:
    match type:
        Type.PLAYER: return "PLAYER"
        Type.GUN: return "GUN"
        Type.BULLET: return "BULLET"
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
