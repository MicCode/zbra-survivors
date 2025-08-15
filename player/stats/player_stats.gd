extends Resource
class_name PlayerStats

@export_group("Health")
@export var is_alive: bool
@export var max_health: float
@export var health: float

@export_group("XP")
@export var xp: float
@export var total_xp: float
@export var xp_collect_radius: float
@export var level: int
@export var next_level_xp: float

@export_group("Movements")
@export var move_speed: float
@export var move_speed_factor: float

@export_group("Damages")
@export var damage_cooldown: float
@export var total_damage_dealt: float
@export var total_damage_taken: float

@export_group("Dash")
@export var dash_duration: float
@export var dash_cooldown: float
@export var dash_speed_multiplier: float
@export var is_dashing: bool
@export var can_dash: bool
@export var dash_gauge_value: int

@export_group("Others")
@export var luck: float

static func apply_modifiers(base_stats: PlayerStats, modifiers: Array[StatModifier]) -> PlayerStats:
    var new_stats: PlayerStats = base_stats.duplicate(true)
    for mod in modifiers.filter(func(m: StatModifier): return m.is_type(E.ModType.PLAYER)):
        if new_stats.get(mod.get_stat_name()) == null:
            push_error("Unable to apply player stat modifier, stat name [%s] not found in class PlayerStats" % mod.get_stat_name())
        else:
            var base_value = base_stats.get(mod.get_stat_name())
            if typeof(base_value) != typeof(mod.value):
                push_error("PlayerStats property [%s] is expecting type [%d] but provided modifier is of type [%d]" % [mod.get_stat_name(), typeof(base_value), typeof(mod.value)])
            else:
                if mod.is_absolute:
                    base_value += mod.value
                else:
                    base_value *= 1 + (mod.value / 100)
            new_stats.set(mod.get_stat_name(), base_value)
    return new_stats
