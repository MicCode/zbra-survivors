extends HBoxContainer
class_name StatisticLine

const POSITIVE_MODULATION = Color("46ce00")
const NEGATIVE_MODULATION = Color("ff503f")
const NEUTRAL_MODULATION = Color.WHITE

@export var label: String = "label"
@export var value: float = 0.0
@export var is_int: bool = true
@export var unit: String = ""
@export var label_color: Color = Color.WHITE

var compare_mode: bool = false
var compare_to: float
var do_color_value: bool = true
var forced_color: String = ""

func _ready() -> void:
    _update_display()
    %Label.modulate = label_color

func set_label(_label: String):
    label = _label
    _update_display()

func set_value(_value: float):
    value = _value
    _update_display()

func set_compare_to(_value: float, _do_color_value: bool = true, _forced_color: String = ""):
    compare_mode = true
    compare_to = _value
    do_color_value = _do_color_value
    forced_color = _forced_color
    _update_display()

func _update_display():
    %Label.text = label
    if is_int: %Value.text = str("%d %s" % [value, tr(unit)])
    else: %Value.text = str("%.2f %s" % [value, tr(unit)])
    if compare_mode:
        %Diff.show()
        var diff: float = value - compare_to

        if diff > 0:
            if is_int: %Diff.text = str("(+%d)" % diff)
            else: %Diff.text = str("(+%.2f)" % diff)
            if do_color_value: %Value.modulate = POSITIVE_MODULATION
            %Diff.modulate = POSITIVE_MODULATION
        elif diff < 0:
            if is_int: %Diff.text = str("(%d)" % diff)
            else: %Diff.text = str("(%.2f)" % diff)
            if do_color_value: %Value.modulate = NEGATIVE_MODULATION
            %Diff.modulate = NEGATIVE_MODULATION
        else:
            %Diff.text = "(=)"
            %Value.modulate = NEUTRAL_MODULATION
            %Diff.modulate = NEUTRAL_MODULATION

        if !forced_color.is_empty():
            if do_color_value: %Value.modulate = Color(forced_color)
            %Diff.modulate = Color(forced_color)
    else:
        %Diff.hide()
