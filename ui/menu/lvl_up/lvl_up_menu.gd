extends CanvasLayer

signal picked_modifier(mod: Modifiers.Mod)

const CHOICE_DISAPPEAR_TIME: float = 0.25
const ANIMATION_TIME: float = 0.1

var choices: Array[LvlUpChoice] = []
var in_animation = false

func _ready() -> void:
    reroll()
    refresh_counters()
    slide_in()

func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("grab") and !in_animation and GameState.lvl_up_rerolls_remaining > 0:
        slide_out().finished.connect(func():
            GameState.lvl_up_rerolls_remaining -= 1
            refresh_counters()
            reroll()
            slide_in()
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

func _on_choice_excluded_changed(clicked_choice: LvlUpChoice, mod: Modifiers.Mod, excluded: bool):
    var existing_exclusion = Modifiers.excluded.filter(func(m: Modifiers.Mod): return is_same(m, mod))
    if excluded and existing_exclusion.is_empty():
        Modifiers.excluded.append(mod)
        clicked_choice.modulate = Color(Color.WHITE, 0.5)
        GameState.lvl_up_exclusions_remaining -= 1
        refresh_counters()
        #print("excluded mod [%s]" % mod.name)
    elif !excluded and !existing_exclusion.is_empty():
        Modifiers.excluded = Modifiers.excluded.filter(func(m: Modifiers.Mod): return !is_same(m, mod))
        clicked_choice.modulate = Color.WHITE
        GameState.lvl_up_exclusions_remaining += 1
        refresh_counters()
        #print("removed exclusion of mod [%s]" % mod.name)

    # to avoid soft lock we prevent player from excluding all available choices
    if GameState.lvl_up_exclusions_remaining == 1 and count_excluded_choices() != 0:
        prevent_exclusions(false)
    else:
        prevent_exclusions(true)

func prevent_exclusions(can_be_excluded: bool):
    var children = %Choices.get_children()
    for child in children:
        if child is LvlUpChoice:
            if !child.excluded:
                child.can_be_excluded = can_be_excluded

func count_excluded_choices() -> int:
    var count = 0
    var children = %Choices.get_children()
    for child in children:
        if child is LvlUpChoice:
            if child.excluded:
                count += 1
    return count

func reroll():
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
        choice.excluded_changed.connect(func(excluded: bool): _on_choice_excluded_changed(choice, mod, excluded))
        choices.append(choice)

    choices[0].force_focus()

func pick_random_modifiers(n: int) -> Array[Modifiers.Mod]:
    # TODO implement a more context aware picking system ? like better modifiers as the player level increases
    var picked: Array[Modifiers.Mod] = []
    for i in n:
        var pickable: Array[Modifiers.Mod] = Modifiers.all.filter(func(m: Modifiers.Mod):
            if Modifiers.excluded.any(func(p: Modifiers.Mod): return is_same(p, m)):
                return false

            return not picked.any(func(p: Modifiers.Mod):
                return is_same(p, m)
            )
        )
        if not pickable.is_empty():
            var rnd = randi_range(0, pickable.size() - 1)
            picked.append(pickable[rnd])
    return picked

func refresh_counters():
    %ExcludeCountLabel.text = str("(%d)" % GameState.lvl_up_exclusions_remaining)
    if GameState.lvl_up_exclusions_remaining <= 0:
        %ExcludeInfo.modulate = Color(Color.WHITE, 0.5)
        %ExcludeButtonIcon.animate = false
    else:
        %ExcludeInfo.modulate = Color.WHITE
        %ExcludeButtonIcon.animate = true

    %RerollCountLabel.text  = str("(%d)" % GameState.lvl_up_rerolls_remaining)
    if GameState.lvl_up_rerolls_remaining <= 0:
        %RerollInfo.modulate = Color(Color.WHITE, 0.5)
        %RerollButtonIcon.animate = false
    else:
        %RerollInfo.modulate = Color.WHITE
        %RerollButtonIcon.animate = true

func slide_in() -> PropertyTweener:
    in_animation = true
    %Panel.position = Vector2(0.0, %Panel.size.y)
    %Panel.scale = Vector2(1.0, 0.0)
    create_tween().tween_property(%Panel, "scale", Vector2(1.0, 1.0), ANIMATION_TIME).finished.connect(func():
        in_animation = false
    )
    return create_tween().tween_property(%Panel, "position", Vector2(0.0, 0.0), ANIMATION_TIME)

func slide_out() -> PropertyTweener:
    in_animation = true
    %Panel.position = Vector2(0.0, 0.0)
    %Panel.scale = Vector2(1.0, 1.0)
    create_tween().tween_property(%Panel, "scale", Vector2(1.0, 0.0), ANIMATION_TIME).finished.connect(func():
        in_animation = false
    )
    return create_tween().tween_property(%Panel, "position", Vector2(0.0, %Panel.size.y), ANIMATION_TIME)

func is_same(mod1: Modifiers.Mod, mod2: Modifiers.Mod) -> bool:
    return mod1.name == mod2.name and mod1.type == mod2.type
