extends CanvasLayer

func _ready() -> void:
    %RestartButton.grab_focus()

func _on_restart_button_pressed() -> void:
    Sounds.button_press()
    reset_effects()
    SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_menu_button_pressed() -> void:
    Sounds.button_press()
    reset_effects()
    SceneManager.switch_to("res://ui/menu/main_menu.tscn")

func reset_effects():
    get_tree().paused = false
    Engine.time_scale = 1.0
    AudioServer.playback_speed_scale = 1.0
    SoundPlayer.stop_all_effects()
