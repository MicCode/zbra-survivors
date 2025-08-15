extends CanvasLayer

signal picked_modifier(mod: ModifierDefinition)

const CHOICE_DISAPPEAR_TIME: float = 0.25
const ANIMATION_TIME: float = 0.1

var choices: Array[LvlUpChoice] = []
var in_animation = false

func _ready() -> void:
    reroll()
    refresh_counters()
    slide_in()

func _input(_event: InputEvent) -> void:
    if Controls.is_just_pressed(Controls.PlayerAction.GRAB) and !in_animation and PlayerService.lvl_up_rerolls_remaining > 0:
        slide_out().finished.connect(func():
            PlayerService.lvl_up_rerolls_remaining -= 1
            refresh_counters()
            reroll()
            slide_in()
        )

func set_remaining_times(times: int):
    %RemainingTimesLabel.text = str("(%d)" % times)

func _on_choice_clicked(clicked_choice: LvlUpChoice, mod: ModifierDefinition):
    for choice in choices:
        choice.disable()
        if choice != clicked_choice:
            create_tween().tween_property(choice, "modulate", Color.TRANSPARENT, CHOICE_DISAPPEAR_TIME)
    get_tree().create_timer(CHOICE_DISAPPEAR_TIME).timeout.connect(func():
        picked_modifier.emit(mod)
    )

func _on_choice_excluded_changed(clicked_choice: LvlUpChoice, mod: ModifierDefinition, excluded: bool):
    var existing_exclusions = ModsService.excluded_mods.filter(func(n: E.ModName): return n == mod.name)
    if excluded and existing_exclusions.is_empty():
        ModsService.excluded_mods.append(mod.name)
        clicked_choice.modulate = Color(Color.WHITE, 0.5)
        PlayerService.lvl_up_exclusions_remaining -= 1
        refresh_counters()
        #print("excluded mod [%s]" % mod.name)
    elif !excluded and !existing_exclusions.is_empty():
        ModsService.excluded_mods = ModsService.excluded_mods.filter(func(n: E.ModName): return n != mod.name)
        clicked_choice.modulate = Color.WHITE
        PlayerService.lvl_up_exclusions_remaining += 1
        refresh_counters()
        #print("removed exclusion of mod [%s]" % mod.name)

    # to avoid soft lock we prevent player from excluding all available choices
    if PlayerService.lvl_up_exclusions_remaining == 1 and count_excluded_choices() != 0:
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

    for mod: ModifierDefinition in ModsService.random_pick_n(3):
        var choice: LvlUpChoice = preload("res://ui/menu/lvl_up/lvl_up_choice.tscn").instantiate()
        choice.mod_definition = mod
        %Choices.add_child(choice)
        choice.clicked.connect(func(): _on_choice_clicked(choice, mod))
        choice.excluded_changed.connect(func(excluded: bool): _on_choice_excluded_changed(choice, mod, excluded))
        choices.append(choice)

    if Controls.is_joypad_connected():
        choices[0].force_focus()

func refresh_counters():
    %ExcludeCountLabel.text = str("(%d)" % PlayerService.lvl_up_exclusions_remaining)
    if PlayerService.lvl_up_exclusions_remaining <= 0:
        %ExcludeInfo.modulate = Color(Color.WHITE, 0.5)
        %ExcludeButtonIcon.animate = false
    else:
        %ExcludeInfo.modulate = Color.WHITE
        %ExcludeButtonIcon.animate = true

    %RerollCountLabel.text = str("(%d)" % PlayerService.lvl_up_rerolls_remaining)
    if PlayerService.lvl_up_rerolls_remaining <= 0:
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
