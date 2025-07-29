extends Node

enum Modifier {
    MAX_HEALTH,
    XP_COLLECT_RADIUS,
    MOVE_SPEED,
    DASH_DURATION,
    DASH_COOLDOWN,
    DASH_SPEED_MULTIPLIER,
}
enum ModifierType {
    UNKNOWN,
    PLAYER,
    GUN
}

var all_modifiers: Array[StatsModifier] = [
    StatsModifier.create_absolute(Modifier.MAX_HEALTH, 1.0),
    StatsModifier.create_relative(Modifier.XP_COLLECT_RADIUS, 5.0),
    StatsModifier.create_relative(Modifier.MOVE_SPEED, 5.0),
    StatsModifier.create_relative(Modifier.DASH_DURATION, 5.0),
    StatsModifier.create_relative(Modifier.DASH_COOLDOWN, -5.0),
    StatsModifier.create_relative(Modifier.DASH_SPEED_MULTIPLIER, 5.0),
]

func get_stat_name(mod: Modifier) -> String:
    match mod:
        Modifier.MAX_HEALTH: return "max_health"
        Modifier.XP_COLLECT_RADIUS: return "xp_collect_radius"
        Modifier.MOVE_SPEED: return "move_speed"
        Modifier.DASH_DURATION: return "dash_duration"
        Modifier.DASH_COOLDOWN: return "dash_cooldown"
        Modifier.DASH_SPEED_MULTIPLIER: return "dash_speed_multiplier"
        _:
            push_error("Stat name not defined for modifier [%d]" % mod)
            return ""

func get_texture(mod: Modifier) -> Texture2D:
    match mod:
        Modifier.MAX_HEALTH: return load("res://assets/sprites/player/max-heath-up.png")
        # TODO add other textures
        _: return load("res://assets/sprites/player/player.png")

func get_type(mod: Modifier) -> ModifierType:
    if [
        Modifier.MAX_HEALTH,
        Modifier.XP_COLLECT_RADIUS,
        Modifier.MOVE_SPEED,
        Modifier.DASH_DURATION,
        Modifier.DASH_COOLDOWN,
        Modifier.DASH_SPEED_MULTIPLIER,
    ].has(mod):
        return ModifierType.PLAYER
    elif [
        # TODO create gun modifiers
    ].has(mod):
        return ModifierType.GUN
    else:
        push_error("ModifierType not defined for modifier [%d]" % mod)
        return ModifierType.UNKNOWN
