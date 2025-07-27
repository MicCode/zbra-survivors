extends CanvasLayer

func _ready() -> void:
    GameState.state_changed.connect(func(new_state: GameState.State):
        if new_state == GameState.State.PAUSED:
            show()
            %QuitButton.grab_focus()
        else:
            hide()
    )

func _on_quit_button_pressed() -> void:
    Sounds.click()
    reset_effects()
    GameState.change_state(GameState.State.NOT_STARTED)
    SceneManager.switch_to("res://ui/menu/main_menu.tscn")

func reset_effects():
    Engine.time_scale = 1.0
    AudioServer.playback_speed_scale = 1.0
    SoundPlayer.stop_all_effects()
