extends CanvasLayer
class_name GameUI

const ANIMATION_TIME: float = 0.25
@export var debug_mode: bool = false

var player_xp: float = -1
var player_level: int = -1

func _ready() -> void:
    %MinimapViewer.modulate = Color(Color.WHITE, Settings.game_settings.map_opacity)

    GameState.score_changed.connect(_on_score_changed)
    GameState.player_state_changed.connect(_on_player_state_changed)
    GameState.player_timewarping_changed.connect(_on_player_timewarping_changed)
    GameState.notify_level_gain.connect(play_lvl_up_effect)
    GameState.state_changed.connect(func(new_state: GameState.State):
        if [GameState.State.PAUSED, GameState.State.GAME_OVER, GameState.State.CHOOSING_UPGRADE].has(new_state): slide_out()
        else: slide_in()
    )
    GameState.equipped_gun_changed.connect(func(new_gun: Gun, _previous_gun_name: String):
        %EquippedGun.change_gun(new_gun)
    )

    if debug_mode:
        %FPSCounter.show()
    else:
        %FPSCounter.hide()

    _on_player_state_changed(GameState.player_state)
    %Score.text = str(GameState.score)
    slide_in()

func _process(_delta: float) -> void:
    if debug_mode:
        %FPSCounter.text = str("%.1f fps" % Engine.get_frames_per_second())

func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("debug_mode"):
        debug_mode = !debug_mode
        if debug_mode:
            %FPSCounter.show()
        else:
            %FPSCounter.hide()

func slide_in():
    %TopContainer.offset_top = -220
    create_tween().tween_property(%TopContainer, "offset_top", 0, ANIMATION_TIME)
    %BottomContainer.offset_bottom = 100
    create_tween().tween_property(%BottomContainer, "offset_bottom", 0, ANIMATION_TIME)
    %Modulate.color = Color.TRANSPARENT
    create_tween().tween_property(%Modulate, "color", Color.WHITE, ANIMATION_TIME)

func slide_out():
    %TopContainer.offset_top = 0
    create_tween().tween_property(%TopContainer, "offset_top", -220, ANIMATION_TIME)
    %BottomContainer.offset_bottom = 0
    create_tween().tween_property(%BottomContainer, "offset_bottom", 100, ANIMATION_TIME)
    %Modulate.color = Color.WHITE
    create_tween().tween_property(%Modulate, "color", Color.TRANSPARENT, ANIMATION_TIME)

func _on_score_changed(new_score: int):
    %Score.text = str(new_score)

func _on_player_state_changed(player_state: PlayerState):
    update_health_bar()

    if player_state.xp != player_xp:
        player_xp = player_state.xp
        %XpLabel.text = str(floor(player_xp)) + " / " + str(floor(player_state.next_level_xp))
        #VisualEffects.emphases(%XpLabel, %XpLabel.scale.x, 1.2, Color.YELLOW)
        var tween = get_tree().create_tween()
        tween.tween_property(%XpBar, "value", player_state.xp, 0.25)

    if player_state.level != player_level:
        player_level = player_state.level
        %LevelLabel.text = str(player_state.level)
        #VisualEffects.emphases(%LevelLabel, %LevelLabel.scale.x, 1.2, Color.YELLOW)

    %XpBar.max_value = player_state.next_level_xp


func update_health_bar():
    %HealthBar.max_value = GameState.player_state.max_health
    %HealthBar.value = GameState.player_state.health
    %HealthBarLabel.text = str("%d / %d" % [GameState.player_state.health, GameState.player_state.max_health])

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

func play_lvl_up_effect():
    # print("play lvl up !")
    var overlay_material = %LvlUpEffect.material as ShaderMaterial
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_OUT)
    %LvlUpEffect.show()
    %LvlUpEffect.modulate = Color.TRANSPARENT
    Controls.vibrate(0.5, 0.5, 1.0)
    overlay_material.set_shader_parameter("size", -10)
    tween.tween_property(overlay_material, "shader_parameter/size", 0, 0.25).connect("finished", func(): %LvlUpEffect.hide())
    get_tree().create_tween().tween_property(%LvlUpEffect, "modulate", Color.WHITE, 0.05)
