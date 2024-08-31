extends CanvasLayer

func _on_restart_button_pressed() -> void:
	SceneSwitcher.switch_to("res://game.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneSwitcher.switch_to("res://ui/main_menu.tscn")
