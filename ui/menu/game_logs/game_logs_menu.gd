extends CanvasLayer

func _init():
    Settings.load_from_file()

func _ready() -> void:
    %RestartButton.grab_focus()

func _on_main_menu_button_pressed() -> void:
    Sounds.click()
    SceneManager.switch_to("res://ui/menu/main_menu.tscn")

func _on_restart_button_pressed() -> void:
    Sounds.start_game()
    GameState.start_new_game()
    SceneManager.switch_to("res://scenes/level_1.tscn")
