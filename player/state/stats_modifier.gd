extends Node
class_name StatsModifier

var modifier: Modifiers.Name
var modifier_value: float = 0.0
var is_absolute = true

static func create_absolute(mod: Modifiers.Name, value: float) -> StatsModifier:
    var new_modifier = StatsModifier.new()
    new_modifier.modifier = mod
    new_modifier.modifier_value = value
    return new_modifier

static func create_percent(mod: Modifiers.Name, percentage: float) -> StatsModifier:
    var new_modifier = StatsModifier.new()
    new_modifier.modifier = mod
    new_modifier.modifier_value = percentage
    new_modifier.is_absolute = false
    return new_modifier

func deep_duplicate() -> StatsModifier:
    if is_absolute:
        return create_absolute(modifier, modifier_value)
    else:
        return create_percent(modifier, modifier_value)

func get_stat_name() -> String:
    return Modifiers.get_stat_name(modifier)

func get_label() -> String:
    return tr(str("LABEL_%s" % get_stat_name()).to_upper())

func is_type(type: Modifiers.Type) -> bool:
    return Modifiers.get_type(modifier) == type
