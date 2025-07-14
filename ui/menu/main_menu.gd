extends Control

func _ready() -> void:
    %MusicToggle.button_pressed = SoundPlayer.settings.enable_music
    %SubTitle.visible_ratio = 0.0
    create_tween().tween_property(%SubTitle, "visible_ratio", 1.0, 0.5)
    %SubTitle.modulate = Color.RED
    create_tween().tween_property(%SubTitle, "modulate", Color.WHITE, 0.75)
    SoundPlayer.apply_audio_settings()
    Musics.main_menu()

func _on_start_button_pressed() -> void:
    Sounds.click()
    Sounds.start_game()
    SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_music_toggle_toggled(toggled_on: bool) -> void:
    SoundPlayer.settings.enable_music = toggled_on
    SoundPlayer.apply_audio_settings()

func _on_music_toggle_button_down() -> void:
    Sounds.click()


func _on_quit_button_pressed() -> void:
    Sounds.click()
    get_tree().quit()
