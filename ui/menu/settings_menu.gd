extends CanvasLayer

func _ready() -> void:
    apply_settings()
    %Language.grab_focus()

func apply_settings():
    var game = Settings.game_settings
    match game.language:
        "fr_FR":
            %Language.select(1)
            TranslationServer.set_locale("fr_FR")
        _:
            %Language.select(0) # fallback on english
            TranslationServer.set_locale("en_US")
    %CameraZoom.value = game.camera_zoom
    %EnableVibrations.button_pressed = game.enable_vibrations
    %MapOpacity.value = game.map_opacity
    %EnableAnnouncementStickers.button_pressed = game.display_announcement_stickers
    %EnableXpRadius.button_pressed = game.display_xp_capture_radius

    var audio = Settings.audio_settings
    %MasterVolume.value = to_linear(audio.master_volume_db)
    %SFXVolume.value = to_linear(audio.effects_volume_db)
    %AnnouncementsVolume.value = to_linear(audio.announcements_volume_db)
    %MusicVolume.value = to_linear(audio.music_volume_db)

func _on_language_item_selected(index: int) -> void:
    Sounds.button_press()
    match index:
        0: TranslationServer.set_locale("en_US")
        1: TranslationServer.set_locale("fr_FR")
    Settings.game_settings.language = TranslationServer.get_locale()
    Settings.save_to_file()

func _on_save_button_pressed() -> void:
    Sounds.button_press()
    save_settings()

func _on_default_button_pressed() -> void:
    Settings.reset_to_default()
    apply_settings()

func save_settings():
    Settings.game_settings.camera_zoom = %CameraZoom.value
    Settings.game_settings.enable_vibrations = %EnableVibrations.button_pressed
    Settings.game_settings.map_opacity = %MapOpacity.value
    Settings.game_settings.display_announcement_stickers = %EnableAnnouncementStickers.button_pressed
    Settings.game_settings.display_xp_capture_radius = %EnableXpRadius.button_pressed

    Settings.audio_settings.master_volume_db = to_db(%MasterVolume.value)
    Settings.audio_settings.effects_volume_db = to_db(%SFXVolume.value)
    Settings.audio_settings.announcements_volume_db = to_db(%AnnouncementsVolume.value)
    Settings.audio_settings.music_volume_db = to_db(%MusicVolume.value)

    Settings.save_to_file()
    Settings.settings_changed.emit()
    SceneManager.switch_to("res://ui/menu/main_menu.tscn") # TODO when settings menu is invoked from a game we will not want to return to main menu but only destroy this overlay

func to_db(linear: float) -> float:
    if linear < 0.0001:
        return -80.0
    return clamp(20.0 * log(linear) / log(10.0), -80.0, 0.0)

func to_linear(db: float) -> float:
    return clamp(pow(10.0, db / 20.0), 0.0, 1.0)
