extends CanvasLayer

func _ready() -> void:
    %MusicToggle.button_pressed = SoundPlayer.enable_music

func _on_start_button_pressed() -> void:
    Sounds.start_game()
    SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_music_toggle_toggled(toggled_on: bool) -> void:
    SoundPlayer.enable_music = toggled_on

func _on_music_toggle_button_down() -> void:
    Sounds.click()
