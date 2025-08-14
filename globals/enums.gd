extends Node

enum GameState {
    NOT_STARTED,
    RUNNING,
    PAUSED,
    CHOOSING_UPGRADE,
    GAME_OVER
}

enum Orientation {
    LEFT,
    RIGHT,
    BELOW,
    ABOVE,
}

enum HapticFeedback {
    ONE_SHOT,
    ONE_SHOT_HEAVY,
    AUTOMATIC,
    CONTINUOUS,
}

#region modifiers
enum ModName {
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

    # FIRE MODIFIERS
    FIRE_DAMAGE,
    FIRE_DURATION,
    FIRE_FREQUENCY
}

func mod_name(_mod_name: ModName) -> String:
    match _mod_name:
        # PLAYER MODIFIERS
        ModName.PLAYER_MAX_HEALTH: return "PLAYER_MAX_HEALTH"
        ModName.PLAYER_XP_COLLECT_RADIUS: return "PLAYER_XP_COLLECT_RADIUS"
        ModName.PLAYER_MOVE_SPEED: return "PLAYER_MOVE_SPEED"
        ModName.PLAYER_DASH_DURATION: return "PLAYER_DASH_DURATION"
        ModName.PLAYER_DASH_COOLDOWN: return "PLAYER_DASH_COOLDOWN"
        ModName.PLAYER_DASH_SPEED_MULTIPLIER: return "PLAYER_DASH_SPEED_MULTIPLIER"

        # GUN MODIFIERS
        ModName.GUN_FIRE_RATE: return "GUN_FIRE_RATE"
        ModName.GUN_SPREAD_ANGLE_MORE: return "GUN_SPREAD_ANGLE_MORE"
        ModName.GUN_SPREAD_ANGLE_LESS: return "GUN_SPREAD_ANGLE_LESS"
        ModName.GUN_BULLET_NUMBER: return "GUN_BULLET_NUMBER"

        # BULLET MODIFIERS
        ModName.BULLET_DAMAGE: return "BULLET_DAMAGE"
        ModName.BULLET_SPEED: return "BULLET_SPEED"
        ModName.BULLET_RANGE: return "BULLET_RANGE"
        ModName.BULLET_PIERCE_COUNT: return "BULLET_PIERCE_COUNT"

        # EXPLOSION MODIFIERS
        ModName.EXPLOSION_RADIUS: return "EXPLOSION_RADIUS"
        ModName.EXPLOSION_DAMAGE: return "EXPLOSION_DAMAGE"

        # FIRE MODIFIERS
        ModName.FIRE_DAMAGE: return "FIRE_DAMAGE"
        ModName.FIRE_DURATION: return "FIRE_DURATION"
        ModName.FIRE_FREQUENCY: return "FIRE_FREQUENCY"

        _:
            push_warning("Unknown E.ModName with index [%d]" % _mod_name)
            return "???"

enum ModType {
    UNKNOWN,
    PLAYER,
    GUN,
    BULLET,
    EXPLOSION,
    FIRE,
}

func mod_type(_mod_type: ModType) -> String:
    match _mod_type:
        ModType.PLAYER: return "PLAYER"
        ModType.GUN: return "GUN"
        ModType.BULLET: return "BULLET"
        ModType.EXPLOSION: return "EXPLOSION"
        ModType.FIRE: return "FIRE"
        _:
            push_warning("Unknown E.ModType with index [%d]" % _mod_type)
            return "???"
#endregion

#region musics
enum MusicLayer {
    NOT_SET,
    MUFFLED,
    SOFT,
    MEDIUM,
    HARD
}

## Util function to display MusicLayer enum member as a string
func music_layer(_layer: MusicLayer) -> String:
    match _layer:
        MusicLayer.NOT_SET: return "NOT_SET"
        MusicLayer.MUFFLED: return "MUFFLED"
        MusicLayer.SOFT: return "SOFT"
        MusicLayer.MEDIUM: return "MEDIUM"
        MusicLayer.HARD: return "HARD"
        _:
            push_error("Unknown MusicLayer [%d]" % _layer)
            return "???"
#endregion
