extends CanvasLayer

func _on_restart_button_pressed() -> void:
    get_tree().paused = false
    Sounds.click()
    SceneManager.switch_to("res://scenes/level_1.tscn")

func _on_menu_button_pressed() -> void:
    get_tree().paused = false
    Sounds.click()
    SceneManager.switch_to("res://ui/menu/main_menu.tscn")
