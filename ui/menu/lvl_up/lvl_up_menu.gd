extends CanvasLayer

signal picked_modifier(modifier: PlayerModifier)
const CHOICE_DISAPPEAR_TIME: float = 0.25
const ANIMATION_TIME: float = 0.1

var pickable_modifiers: Array[PlayerModifier] = [
    PlayerModifier.create_absolute("max_health", 1.0),
    PlayerModifier.create_relative("xp_collect_radius", 5.0),
    PlayerModifier.create_relative("move_speed", 5.0),
    PlayerModifier.create_relative("dash_duration", 5.0),
    PlayerModifier.create_relative("dash_cooldown", -5.0),
    PlayerModifier.create_relative("dash_speed_multiplier", 5.0),
    # TODO add drop chances ?
]

var choices: Array[LvlUpChoice] = []

func _ready() -> void:
    slide_in().finished.connect(func():
        var children = %Choices.get_children()
        choices = []
        for child in children:
            if child is LvlUpChoice:
                child.queue_free()

        for modifier in pick(3):
            var choice: LvlUpChoice = preload("res://ui/menu/lvl_up/lvl_up_choice.tscn").instantiate()
            choice.set_stat_modifier(modifier)
            %Choices.add_child(choice)
            choice.clicked.connect(func(): _on_choice_clicked(choice, modifier))
            choices.append(choice)

        choices[0].force_focus()
    )

func _on_choice_clicked(clicked_choice: LvlUpChoice, modifier: PlayerModifier):
    for choice in choices:
        choice.disable()
        if choice == clicked_choice:
            create_tween().tween_property(choice, "modulate", Color.TRANSPARENT, CHOICE_DISAPPEAR_TIME).finished.connect(func():
                picked_modifier.emit(modifier)
            )

func pick(n: int) -> Array[PlayerModifier]:
    # TODO implement a more context aware picking system ? like better modifiers as the player level increases
    var picked: Array[PlayerModifier] = []
    for i in n:
        var pickable = pickable_modifiers.filter(func(m: PlayerModifier):
            return not picked.any(func(p: PlayerModifier):
                return p.stat_name == m.stat_name
            )
        )
        if not pickable.is_empty():
            var rnd = randi_range(0, pickable.size() - 1)
            picked.append(pickable[rnd])
    return picked

func slide_in() -> PropertyTweener:
    %MainContainer.position = Vector2(0.0, %MainContainer.size.y)
    %MainContainer.scale = Vector2(1.0, 0.0)
    create_tween().tween_property(%MainContainer, "scale", Vector2(1.0, 1.0), ANIMATION_TIME)
    return create_tween().tween_property(%MainContainer, "position", Vector2(0.0, 0.0), ANIMATION_TIME)

func slide_out() -> PropertyTweener:
    %MainContainer.position = Vector2(0.0, 0.0)
    %MainContainer.scale = Vector2(1.0, 1.0)
    create_tween().tween_property(%MainContainer, "scale", Vector2(1.0, 0.0), ANIMATION_TIME)
    return create_tween().tween_property(%MainContainer, "position", Vector2(0.0, %MainContainer.size.y), ANIMATION_TIME)
