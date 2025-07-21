extends CanvasLayer

func _ready() -> void:
    GameService.game_paused_changed.connect(func(is_game_paused: bool):
        if is_game_paused: show()
        else: hide()
    )

func _on_quit_button_pressed() -> void:
    Sounds.click()
    reset_effects()
    SceneManager.switch_to("res://ui/menu/main_menu.tscn")

func reset_effects():
    GameService.set_game_paused(false)
    Engine.time_scale = 1.0
    AudioServer.playback_speed_scale = 1.0
    SoundPlayer.stop_all_effects()
