extends Resource
class_name BulletStats

@export_group("Attributes")
@export_subgroup("Damages")
@export var damage: float = 10.0

@export_subgroup("Movement")
@export var speed: float = 200
@export var speed_variation: float = 0.0
@export var disapear_delay: float = 0.0
@export var fly_range = 2000.0

@export_subgroup("Size")
@export var size: float = 1.0
@export var size_variation: float = 0.0

@export_group("Effects")
@export var pierce_count: float = 0.0
@export var inflicts_fire: bool = false
@export var is_explosive: bool = false

@export_group("Explosion")
@export var explosion_damage: float = 0.0
@export var explosion_radius: float = 0.0

@export_group("Fire")
@export var fire_tick_per_s: float = 0.0
@export var fire_damage: float = 0.0
@export var fire_duration: float = 0.0

static func apply_modifiers(base_stats: BulletStats, modifiers: Array[StatModifier]) -> BulletStats:
    var new_stats: BulletStats = base_stats.duplicate(true)
    for mod in modifiers.filter(func(m: StatModifier): return m.is_type(E.ModType.BULLET) or m.is_type(E.ModType.FIRE)):
        if new_stats.get(mod.get_stat_name()) == null:
            push_error("Unable to apply bullet stat modifier, stat name [%s] not found in class BulletStats" % mod.get_stat_name())
        else:
            var base_value = base_stats.get(mod.get_stat_name())
            if typeof(base_value) != typeof(mod.value):
                push_error("BulletStats property [%s] is expecting type [%d] but provided modifier is of type [%d]" % [mod.get_stat_name(), typeof(base_value), typeof(mod.value)])
            else:
                if mod.is_absolute:
                    base_value += mod.value
                else:
                    base_value *= 1 + (mod.value / 100)
            new_stats.set(mod.get_stat_name(), base_value)
    return new_stats
