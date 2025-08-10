extends CanvasLayer
class_name PauseMenu

const ANIMATION_TIME: float = 0.1

func _ready() -> void:
    slide_in().finished.connect(func():
        %QuitButton.grab_focus()
    )

func _on_quit_button_pressed() -> void:
    Sounds.button_press()
    reset_effects()
    slide_out().finished.connect(func():
        GameState.change_state(GameState.State.NOT_STARTED)
        SceneManager.switch_to("res://ui/menu/game_logs/game_logs_menu.tscn")
        queue_free()
    )


func reset_effects():
    Engine.time_scale = 1.0
    AudioServer.playback_speed_scale = 1.0
    SoundPlayer.stop_all_effects()

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
