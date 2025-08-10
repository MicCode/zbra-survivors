extends CanvasLayer

func _ready() -> void:
    AudioServer.playback_speed_scale = 1.0
    Engine.time_scale = 1.0

    %SubTitle.visible_ratio = 0.0
    create_tween().tween_property(%SubTitle, "visible_ratio", 1.0, 0.5)
    %SubTitle.modulate = Color.RED
    create_tween().tween_property(%SubTitle, "modulate", Color.WHITE, 0.75)
    Settings.apply_audio_settings()
    MusicManager.set_music(MusicManager.Music.METAL_1)
    MusicManager.set_layer(MusicManager.MusicLayer.MUFFLED)

    match Settings.game_settings.language:
        "fr_FR": %LanguageSwitcher.select(1)
        _: %LanguageSwitcher.select(0) # fallback on english
    %StartButton.grab_focus()
    GameState.change_state(GameState.State.NOT_STARTED)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("debug_mode"):
        GameState.start_new_game()
        SceneManager.switch_to("res://scenes/test/test_equipment_scene.tscn")

func _on_start_button_pressed() -> void:
    Sounds.start_game()
    GameState.start_new_game()
    SceneManager.switch_to("res://scenes/level_1.tscn")


func _on_quit_button_pressed() -> void:
    Sounds.button_press()
    get_tree().quit()

func _on_language_switcher_item_selected(index: int) -> void:
    match index:
        0: TranslationServer.set_locale("en_US")
        1: TranslationServer.set_locale("fr_FR")
    Settings.game_settings.language = TranslationServer.get_locale()
    Settings.save_to_file()


func _on_settings_button_pressed() -> void:
    Sounds.button_press()
    SceneManager.switch_to("res://ui/menu/settings_menu.tscn")
