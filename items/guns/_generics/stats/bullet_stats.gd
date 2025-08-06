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
@export var explosion_damage: float = 50.0
@export var explosion_radius: float = 200.0

static func apply_modifiers(base_stats: BulletStats, modifiers: Array[StatsModifier]) -> BulletStats:
    var new_stats: BulletStats = base_stats.duplicate(true)
    for mod in modifiers.filter(func(m: StatsModifier): return m.is_type(Modifiers.Type.BULLET)):
        if new_stats.get(mod.get_stat_name()) == null:
            push_error("Unable to apply bullet stat modifier, stat name [%s] not found in class BulletStats" % mod.get_stat_name())
        else:
            var base_value = base_stats.get(mod.get_stat_name())
            if typeof(base_value) != typeof(mod.modifier_value):
                push_error("BulletStats property [%s] is expecting type [%d] but provided modifier is of type [%d]" % [mod.get_stat_name(), typeof(base_value), typeof(mod.modifier_value)])
            else:
                if mod.is_absolute:
                    base_value += mod.modifier_value
                else:
                    base_value *= 1 + (mod.modifier_value / 100)
            new_stats.set(mod.get_stat_name(), base_value)
    return new_stats
