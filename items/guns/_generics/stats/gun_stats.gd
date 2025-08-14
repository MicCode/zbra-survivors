extends Resource
class_name GunStats

@export_group("Attack")
@export var shots_per_s: float = 1.0
@export var bullets_spread_angle_deg: float = 0.0
@export var bullets_per_shot: float = 1.0

@export_group("Sound")
## Path to the sound file to play on shoot, can also be a folder path (without extension) if `is_sound_folder` option is set
@export var shoot_sound: String = "shoot.ogg"
## Wether the value provided in `shoot_sound` is pointing to a folder name, and thus we will need to load randomly one of the sound in this folder each time
@export var is_sound_folder: bool = false
@export var shoot_sfx_options: SfxOptions = preload("res://globals/settings/defaults/default_sfx_options.tres")

@export_group("Effects")
@export var eject_cartridges: bool = true
@export var show_muzzle_flash: bool = true
@export var has_laser_dot: bool = false
@export var recoil_distance: float = 10.0
@export var haptic_feedback: E.HapticFeedback = E.HapticFeedback.ONE_SHOT

static func apply_modifiers(base_stats: GunStats, modifiers: Array[StatsModifier]) -> GunStats:
    var new_stats: GunStats = base_stats.duplicate(true)
    for mod in modifiers.filter(func(m: StatsModifier): return m.is_type(E.ModType.GUN)):
        if new_stats.get(mod.get_stat_name()) == null:
            push_error("Unable to apply gun stat modifier, stat name [%s] not found in class GunStats" % mod.get_stat_name())
        else:
            var base_value = base_stats.get(mod.get_stat_name())
            if typeof(base_value) != typeof(mod.modifier_value):
                push_error("GunStats property [%s] is expecting type [%d] but provided modifier is of type [%d]" % [mod.get_stat_name(), typeof(base_value), typeof(mod.modifier_value)])
            else:
                if mod.is_absolute:
                    base_value += mod.modifier_value
                else:
                    base_value *= 1 + (mod.modifier_value / 100)
            new_stats.set(mod.get_stat_name(), base_value)
    return new_stats
