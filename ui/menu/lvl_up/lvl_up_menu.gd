extends CanvasLayer

const CHOICE_DISAPPEAR_TIME: float = 0.25

var pickable_modifiers: Array[PlayerStatModifier] = [
    PlayerStatModifier.create_absolute("max_health", 1.0),
    PlayerStatModifier.create_relative("xp_collect_radius", 5.0),
    PlayerStatModifier.create_relative("move_speed", 5.0),
    PlayerStatModifier.create_relative("dash_duration", 5.0),
    PlayerStatModifier.create_relative("dash_cooldown", -5.0),
    PlayerStatModifier.create_relative("dash_speed_multiplier", 5.0),
    # TODO add drop chances ?
]

var choices: Array[LvlUpChoice] = []

func _ready() -> void:
    var children = %Choices.get_children()
    choices = []
    for child in children:
        if child is LvlUpChoice:
            child.queue_free()

    for modifier in pick(3):
        var choice: LvlUpChoice = preload("res://ui/menu/lvl_up/lvl_up_choice.tscn").instantiate()
        choice.set_stat_modifier(modifier)
        %Choices.add_child(choice)
        choice.clicked.connect(func(): _on_choice_clicked(choice))
        choices.append(choice)

    choices[0].force_focus()

func _on_choice_clicked(clicked_choice: LvlUpChoice):
    for choice in choices:
        choice.disable()
        if choice != clicked_choice:
            get_tree().create_tween().tween_property(choice, "modulate", Color.TRANSPARENT, CHOICE_DISAPPEAR_TIME)

func pick(n: int) -> Array[PlayerStatModifier]:
    # TODO implement a more context aware picking system ? like better modifiers as the player level increases
    var picked: Array[PlayerStatModifier] = []
    for i in n:
        var pickable = pickable_modifiers.filter(func(m: PlayerStatModifier):
            return not picked.any(func(p: PlayerStatModifier):
                return p.stat_name == m.stat_name
            )
        )
        if not pickable.is_empty():
            var rnd = randi_range(0, pickable.size() - 1)
            picked.append(pickable[rnd])
    return picked
