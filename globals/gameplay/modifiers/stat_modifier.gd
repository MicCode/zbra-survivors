class_name StatModifier

var name: E.ModName
var value: float = 0.0
## if set to false, modifier will apply a percent change
var is_absolute = true

## Creates a modifier which value is applied as an absolute value (+ or - value)
static func create_absolute(_name: E.ModName, _absolute_value: float) -> StatModifier:
    var new_modifier = StatModifier.new()
    new_modifier.name = _name
    new_modifier.value = _absolute_value
    return new_modifier

## Creates a modifier which value is applied as a percentage
static func create_percent(_name: E.ModName, _percentage: float) -> StatModifier:
    var new_modifier = StatModifier.new()
    new_modifier.name = _name
    new_modifier.value = _percentage
    new_modifier.is_absolute = false
    return new_modifier

## Deep duplicate a StatModifier, not by reference but by creating a new instance, not sure if this is mandatory but I noticed sometimes when copied, having only the reference to the object may have side effects and leak out of the current game
func deep_duplicate() -> StatModifier:
    if is_absolute:
        return create_absolute(name, value)
    else:
        return create_percent(name, value)

## Returns the name of the statistic this modifier is intended to modify, it must be a known property of a modified class (PlayerStats, GunStats, BulletStats...)
func get_stat_name() -> String:
    return ModsService.get_stat_name(name)

## Returns a translation ready label string of the modified statistic name
func get_label() -> String:
    return tr(str("LABEL_%s" % get_stat_name()).to_upper())

## Determines if this modifier is of given ModType, to know on which statistics class it can be applied (PlayerStats, GunStats, BulletStats...)
func is_type(type: E.ModType) -> bool:
    return ModsService.get_type(name) == type
