@tool
extends Button

@export var label: String:
    set(value):
        label = value
        if has_node("%Label") and is_instance_valid(%Label):
            %Label.text = label

@export var action: Controls.PlayerAction

func _enter_tree() -> void:
    %Label.text = tr(label)
    %ButtonIcon.action = action
    shortcut = Shortcut.new()
    var input_event = InputEventAction.new()
    input_event.action = E.to_str(Controls.PlayerAction, action).to_lower()
    shortcut.events.append(input_event)
