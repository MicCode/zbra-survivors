extends HBoxContainer
class_name StatisticLine

const POSITIVE_MODULATION = Color("46ce00")
const NEGATIVE_MODULATION = Color("ff503f")
const NEUTRAL_MODULATION = Color.WHITE

@export var label: String = "label"
@export var value: float = 0.0
@export var is_int: bool = true
@export var unit: String = ""

var compare_mode: bool = false
var compare_to: float

func _ready() -> void:
    _update_display()

func set_label(_label: String):
    label = _label
    _update_display()

func set_value(_value: float):
    value = _value
    _update_display()

func set_compare_to(_value: float):
    compare_mode = true
    compare_to = _value
    _update_display()

func _update_display():
    %Label.text = label
    if is_int: %Value.text = str("%d %s" % [value, tr(unit)])
    else: %Value.text = str("%.1f %s" % [value, tr(unit)])
    if compare_mode:
        %Diff.show()
        var diff: float = value - compare_to
        if diff > 0:
            if is_int: %Diff.text = str("(+%d)" % diff)
            else: %Diff.text = str("(+%.1f)" % diff)
            %Value.modulate = POSITIVE_MODULATION
            %Diff.modulate = POSITIVE_MODULATION
        elif diff < 0:
            if is_int: %Diff.text = str("(%d)" % diff)
            else: %Diff.text = str("(%.1f)" % diff)
            %Value.modulate = NEGATIVE_MODULATION
            %Diff.modulate = NEGATIVE_MODULATION
        else:
            %Diff.text = "(=)"
            %Value.modulate = NEUTRAL_MODULATION
            %Diff.modulate = NEUTRAL_MODULATION
    else:
        %Diff.hide()
