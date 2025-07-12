extends Panel

var player_health: int = -1
var player_max_health: int = -1
var player_xp: float = -1
var player_level: int = -1


func _ready() -> void:
    %Score.text = str(GameService.score)
    GameService.score_changed.connect(_on_score_changed)
    GameService.player_state_changed.connect(_on_player_state_changed)
    GameService.player_timewarping_changed.connect(_on_player_timewarping_changed)
    GameService.player_gained_level.connect(play_lvl_up_effect)
    _on_player_state_changed(GameService.player_state)

func _on_score_changed(new_score: int):
    %Score.text = str(new_score)

func _on_player_state_changed(player_state: PlayerState):
    if player_state.max_health != player_max_health:
        player_max_health = player_state.max_health
        redraw_hearts()

    if player_state.health != player_health:
        player_health = player_state.health
        update_hearts_filling()

    if player_state.xp != player_xp:
        player_xp = player_state.xp
        %XpLabel.text = str(floor(player_xp)) + " / " + str(floor(player_state.next_level_xp))
        VisualEffects.emphases(%XpLabel, 1.2, Color.YELLOW)
        var tween = get_tree().create_tween()
        tween.tween_property(%XpBar, "value", player_state.xp, 0.25)

    if player_state.level != player_level:
        player_level = player_state.level
        %LevelLabel.text = "Niv. " + str(player_state.level)
        VisualEffects.emphases(%LevelLabel, 1.2, Color.YELLOW)

    %XpBar.max_value = player_state.next_level_xp


func redraw_hearts():
    var hearts = %Hearts.get_children()
    for heart in hearts:
        heart.queue_free()
    for i in range(0, player_max_health, 1):
        var new_heart = preload("res://ui/in-game/heart.tscn").instantiate()
        new_heart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        new_heart.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        %Hearts.add_child(new_heart)

func update_hearts_filling():
    for i in range(0, player_max_health, 1):
        var heart = %Hearts.get_children().get(i)
        if heart and heart is HeartUI:
            if i > player_health - 1:
                heart.change_state(Enums.HeartStates.Empty)
            else:
                heart.change_state(Enums.HeartStates.Full)

func set_remaining_time(remaining_s: float):
    var remaining_minutes = floor(remaining_s / 60)
    var remaining_seconds = floor(remaining_s - remaining_minutes * 60)
    %RemainingTime.text = format_time(remaining_minutes, remaining_seconds)

func format_time(minutes: int, seconds: int) -> String:
    return str("%02d:%02d" % [minutes, seconds])

func _on_player_timewarping_changed(timewarping: bool):
    if timewarping:
        start_slow_down_effect()
    else:
        stop_slow_down_effect()

func start_slow_down_effect():
    var overlay_material = %SlowDownEffect.material as ShaderMaterial
    var tween = get_tree().create_tween()
    tween.tween_property(overlay_material, "shader_parameter/fire_alpha", 1.0, 0.2)

func stop_slow_down_effect():
    var overlay_material = %SlowDownEffect.material as ShaderMaterial
    var tween = get_tree().create_tween()
    tween.tween_property(overlay_material, "shader_parameter/fire_alpha", 0.0, 0.2)

func play_lvl_up_effect(_new_level: int):
    print("play lvl up !")
    var overlay_material = %LvlUpEffect.material as ShaderMaterial
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_OUT)
    %LvlUpEffect.show()
    %LvlUpEffect.modulate = Color.TRANSPARENT
    overlay_material.set_shader_parameter("size", -10)
    tween.tween_property(overlay_material, "shader_parameter/size", 0, 0.25).connect("finished", func(): %LvlUpEffect.hide())
    get_tree().create_tween().tween_property(%LvlUpEffect, "modulate", Color.WHITE, 0.05)
