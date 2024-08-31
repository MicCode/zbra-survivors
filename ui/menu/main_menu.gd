extends CanvasLayer

func _on_start_button_pressed() -> void:
	SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_music_toggle_toggled(toggled_on: bool) -> void:
	GameSettings.enable_music = toggled_on
