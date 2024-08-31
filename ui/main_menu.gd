extends CanvasLayer

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_music_toggle_toggled(toggled_on: bool) -> void:
	GameSettings.enable_music = toggled_on
