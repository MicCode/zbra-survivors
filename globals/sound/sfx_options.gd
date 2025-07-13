extends Resource
class_name SfxOptions

@export var pitch: float = 1.0
@export var pitch_variation: float = 0.0
@export var volume: float = 0.0
@export var start_delay_ms: float = 0.0
@export var start_delay_variation_ms: float = 0.0
@export var max_per_s: float = 10.0

static func from_dict(dict: Dictionary) -> SfxOptions:
    var options = SfxOptions.new()
    var properties_names = options.get_property_list().map(func(prop): return prop["name"])
    for option_name in dict.keys():
        if properties_names.has(option_name):
            var expected_type = typeof(options[option_name])
            var value = dict.get(option_name)
            if typeof(value) == expected_type:
                options[option_name] = value
            else:
                push_error("Type mismatch for SfxOptions property [%s]: expected [%s], got [%s]" % [
                    option_name,
                    type_string(expected_type),
                    type_string(typeof(value))
                ])
        else:
            push_error("Unknown SfxOptions property [%s]" % option_name)
    return options
