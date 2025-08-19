@tool
extends Node

enum GameState {
    NOT_STARTED,
    RUNNING,
    PAUSED,
    CHOOSING_UPGRADE,
    GAME_OVER
}

enum HapticFeedback {
    ONE_SHOT,
    ONE_SHOT_HEAVY,
    AUTOMATIC,
    CONTINUOUS,
}

enum EventLogType {
    LEVEL_LOADED,
    WEAPON_CHANGED,
    ITEM_PICKED_UP,
    ITEM_USED,
    MODIFIER_PICKED_UP,
    GAME_STATE_CHANGED,
    CHEST_SPAWNED,
    CHEST_OPENED,
    BOSS_SPAWNED,
    BOSS_DIED,
    GAME_FINISHED,
    MUSIC_CHANGED,
}

enum DamageType {
    BULLET,
    MELEE,
    FIRE,
    EXPLOSION
}

#region modifiers
# ATTENTION ! Do not change order in this enum as members are referenced as integers in resources using them
enum ModName {
    PLAYER_MAX_HEALTH,
    PLAYER_XP_COLLECT_RADIUS,
    PLAYER_MOVE_SPEED,
    PLAYER_DASH_DURATION,
    PLAYER_DASH_COOLDOWN,
    PLAYER_DASH_SPEED_MULTIPLIER,
    WEAPON_FIRE_RATE,
    WEAPON_SPREAD_ANGLE_MORE,
    WEAPON_SPREAD_ANGLE_LESS,
    WEAPON_BULLET_NUMBER,
    BULLET_DAMAGE,
    BULLET_SPEED,
    BULLET_RANGE,
    BULLET_PIERCE_COUNT,
    EXPLOSION_RADIUS,
    EXPLOSION_DAMAGE,
    FIRE_DAMAGE,
    FIRE_DURATION,
    FIRE_FREQUENCY,

    PLAYER_LUCK,
}

func mod_stat_name(n: ModName) -> String:
    match n:
        # PlayerStats
        ModName.PLAYER_MAX_HEALTH: return "max_health"
        ModName.PLAYER_XP_COLLECT_RADIUS: return "xp_collect_radius"
        ModName.PLAYER_MOVE_SPEED: return "move_speed"
        ModName.PLAYER_DASH_DURATION: return "dash_duration"
        ModName.PLAYER_DASH_COOLDOWN: return "dash_cooldown"
        ModName.PLAYER_DASH_SPEED_MULTIPLIER: return "dash_speed_multiplier"
        ModName.PLAYER_LUCK: return "luck"
        # WeaponStats
        ModName.WEAPON_FIRE_RATE: return "shots_per_s"
        ModName.WEAPON_SPREAD_ANGLE_MORE: return "bullets_spread_angle_deg"
        ModName.WEAPON_SPREAD_ANGLE_LESS: return "bullets_spread_angle_deg"
        ModName.WEAPON_BULLET_NUMBER: return "bullets_per_shot"
        # BulletStats
        ModName.BULLET_DAMAGE: return "damage"
        ModName.BULLET_SPEED: return "speed"
        ModName.BULLET_RANGE: return "fly_range"
        ModName.BULLET_PIERCE_COUNT: return "pierce_count"
        # Explosion
        ModName.EXPLOSION_RADIUS: return "explosion_radius"
        ModName.EXPLOSION_DAMAGE: return "explosion_damage"
        # Fire
        ModName.FIRE_DAMAGE: return "fire_damage"
        ModName.FIRE_DURATION: return "fire_duration"
        ModName.FIRE_FREQUENCY: return "fire_tick_per_s"
        _:
            push_warning("Unknown E.ModStatName with index [%d]" % n)
            return "???"

enum ModType {
    UNKNOWN,
    PLAYER,
    WEAPON,
    BULLET,
    EXPLOSION,
    FIRE,
}
#endregion

#region musics
enum MusicLayer {
    NOT_SET,
    MUFFLED,
    SOFT,
    MEDIUM,
    HARD
}
#endregion

func to_str(enum_dict: Dictionary, value: int) -> String:
    var _str = enum_reverse(enum_dict).get(value, "???")
    if _str == "???":
        push_error("enum member with value [%d] not found in dictionary:" % value)
        push_error(enum_dict)
    return _str

func from_str(enum_dict: Dictionary, _str: String) -> int:
    if not enum_dict.keys().has(_str):
        push_error("enum key [%s] not found in dictionary:" % _str)
        push_error(enum_dict)
        return -1
    return enum_dict[_str]

func enum_reverse(enum_dict: Dictionary) -> Dictionary:
    var dict: Dictionary = {}
    for _key in enum_dict:
        dict.set(enum_dict[_key], _key)
    return dict
