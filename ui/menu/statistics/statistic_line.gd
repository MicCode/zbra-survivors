extends HBoxContainer
class_name StatisticLine

@export var label: String = "label"
@export var value: float = 0.0
@export var is_int: bool = true
@export var unit: String = ""

func _ready() -> void:
    update_display()

func set_label(_label: String):
    label = _label
    update_display()

func set_value(_value: float):
    value = _value
    update_display()

func update_display():
    %Label.text = label
    if is_int:
        %Value.text = str("%d %s" % [value, tr(unit)])
    else:
        %Value.text = str("%.1f %s" % [value, tr(unit)])
