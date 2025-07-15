extends CanvasLayer

func _ready() -> void:
    %MusicToggle.button_pressed = Settings.audio_settings.enable_music
    %SubTitle.visible_ratio = 0.0
    create_tween().tween_property(%SubTitle, "visible_ratio", 1.0, 0.5)
    %SubTitle.modulate = Color.RED
    create_tween().tween_property(%SubTitle, "modulate", Color.WHITE, 0.75)
    SoundPlayer.apply_audio_settings()
    Musics.main_menu()

    match Settings.game_settings.language:
        "fr_FR": %LanguageSwitcher.select(1)
        _: %LanguageSwitcher.select(0) # fallback on english

func _on_start_button_pressed() -> void:
    Sounds.click()
    Sounds.start_game()
    SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_music_toggle_toggled(toggled_on: bool) -> void:
    Settings.audio_settings.enable_music = toggled_on
    SoundPlayer.apply_audio_settings()
    Settings.save_to_file()

func _on_music_toggle_button_down() -> void:
    Sounds.click()


func _on_quit_button_pressed() -> void:
    Sounds.click()
    get_tree().quit()

func _on_language_switcher_item_selected(index: int) -> void:
    match index:
        0: TranslationServer.set_locale("en_US")
        1: TranslationServer.set_locale("fr_FR")
    Settings.game_settings.language = TranslationServer.get_locale()
    Settings.save_to_file()
