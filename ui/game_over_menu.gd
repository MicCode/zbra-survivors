extends CanvasLayer


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
