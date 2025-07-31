extends CanvasLayer

signal picked_modifier(mod: Modifiers.Mod)

const CHOICE_DISAPPEAR_TIME: float = 0.25
const ANIMATION_TIME: float = 0.1

var choices: Array[LvlUpChoice] = []

func _enter_tree() -> void:
    if Input.is_action_pressed("ui_accept"):
        Input.action_release("ui_accept")

func _ready() -> void:
    slide_in().finished.connect(func():
        var children = %Choices.get_children()
        choices = []
        for child in children:
            if child is LvlUpChoice:
                child.queue_free()

        for mod in pick_random_modifiers(3):
            var choice: LvlUpChoice = preload("res://ui/menu/lvl_up/lvl_up_choice.tscn").instantiate()
            choice.set_stat_modifier(mod)
            %Choices.add_child(choice)
            choice.clicked.connect(func(): _on_choice_clicked(choice, mod))
            choices.append(choice)

        choices[0].force_focus()
    )

func set_remaining_times(times: int):
    %RemainingTimesLabel.text = str("(%d)" % times)

func _on_choice_clicked(clicked_choice: LvlUpChoice, mod: Modifiers.Mod):
    for choice in choices:
        choice.disable()
        if choice != clicked_choice:
            create_tween().tween_property(choice, "modulate", Color.TRANSPARENT, CHOICE_DISAPPEAR_TIME)
    get_tree().create_timer(CHOICE_DISAPPEAR_TIME).timeout.connect(func():
        picked_modifier.emit(mod)
    )

func pick_random_modifiers(n: int) -> Array[Modifiers.Mod]:
    # TODO implement a more context aware picking system ? like better modifiers as the player level increases
    var picked: Array[Modifiers.Mod] = []
    for i in n:
        var pickable: Array[Modifiers.Mod] = Modifiers.all.filter(func(m: Modifiers.Mod):
            return not picked.any(func(p: Modifiers.Mod):
                return p.name == m.name and p.type == p.type
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
