extends Control

func _ready() -> void:
    %MusicToggle.button_pressed = SoundPlayer.enable_music
    %SubTitle.visible_ratio = 0.0
    create_tween().tween_property(%SubTitle, "visible_ratio", 1.0, 0.5)
    %SubTitle.modulate = Color.RED
    create_tween().tween_property(%SubTitle, "modulate", Color.WHITE, 0.75)

func _on_start_button_pressed() -> void:
    Sounds.start_game()
    SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_music_toggle_toggled(toggled_on: bool) -> void:
    SoundPlayer.enable_music = toggled_on

func _on_music_toggle_button_down() -> void:
    Sounds.click()


func _on_quit_button_pressed() -> void:
    get_tree().quit()
