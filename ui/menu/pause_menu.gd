extends CanvasLayer

var paused = false

func _input(event):
    if event.is_action_pressed("pause_game") && !GameService.is_game_over:
        paused = !paused
        Sounds.click()
        get_tree().paused = paused
        if paused:
            show()
        else:
            hide()

func _on_quit_button_pressed() -> void:
    Sounds.click()
    reset_effects()
    SceneManager.switch_to("res://ui/menu/main_menu.tscn")

func reset_effects():
    get_tree().paused = false
    Engine.time_scale = 1.0
    AudioServer.playback_speed_scale = 1.0
    SoundPlayer.stop_all_effects()
