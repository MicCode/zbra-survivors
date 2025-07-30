extends Resource
class_name PlayerState

@export_group("Health")
@export var is_alive: bool
@export var max_health: float
@export var health: float

@export_group("XP")
@export var xp: float
@export var xp_collect_radius: float
@export var level: int
@export var next_level_xp: float

@export_group("Movements")
@export var move_speed: float
@export var move_speed_factor: float

@export_group("Damages")
@export var damage_cooldown: float

@export_group("Dash")
@export var dash_duration: float
@export var dash_cooldown: float
@export var dash_speed_multiplier: float
@export var is_dashing: bool
@export var can_dash: bool
@export var dash_gauge_value: int

@export_group("Drop chances")
@export var life_drop_chance: float
@export var radiance_drop_chance: float
@export var timewrap_drop_change: float
@export var xp_collector_drop_chance: float
@export var land_mine_chance: float

static func apply_modifiers(current_state: PlayerState, base_state: PlayerState, modifiers: Array[StatsModifier]) -> PlayerState:
    for mod in modifiers.filter(func(m: StatsModifier): return m.is_type(Modifiers.ModifierType.PLAYER)):
        if current_state.get(mod.get_stat_name()) == null:
            push_error("Unable to apply player stat modifier, stat name [%s] not found in class PlayerState" % mod.get_stat_name())
        else:
            var base_value = base_state.get(mod.get_stat_name())
            if typeof(base_value) != typeof(mod.modifier_value):
                push_error("PlayerState property [%s] is expecting type [%d] but provided modifier is of type [%d]" % [mod.get_stat_name(), typeof(base_value), typeof(mod.modifier_value)])
            else:
                if mod.is_absolute:
                    base_value += mod.modifier_value
                else:
                    base_value *= 1 + (mod.modifier_value / 100)
            current_state.set(mod.get_stat_name(), base_value)
    return current_state
