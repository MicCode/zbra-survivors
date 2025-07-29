extends Node
class_name PlayerStatModifier

var stat_name: String
var modifier_value: float = 0.0
var is_absolute = true

static func create_absolute(_stat_name: String, value: float) -> PlayerStatModifier:
    var new_modifier = PlayerStatModifier.new()
    new_modifier.stat_name = _stat_name
    new_modifier.modifier_value = value
    return new_modifier

static func create_relative(_stat_name: String, percentage: float) -> PlayerStatModifier:
    var new_modifier = PlayerStatModifier.new()
    new_modifier.stat_name = _stat_name
    new_modifier.modifier_value = percentage
    new_modifier.is_absolute = false
    return new_modifier
