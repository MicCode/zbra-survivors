extends Resource
class_name ModifierDefinition

@export var name: E.ModName
## if set to false, modifier will apply a percent change
@export var is_absolute: bool
@export var sprite: Texture2D

## Returns a translation ready label string of the modified statistic name
func get_display_label() -> String:
    return tr(str("LABEL_%s" % E.mod_stat_name(name)).to_upper())

func get_description() -> String:
    var tr_key = "LABEL_" + E.mod_stat_name(name).to_upper() + "_DESCRIPTION"
    var description = tr(tr_key)
    if description != tr_key:
        return description
    else:
        return ""
