extends CanvasLayer

var paused = false

func _input(event):
	if event.is_action_pressed("pause_game") && !GameService.is_game_over:
		paused = !paused
		get_tree().paused = paused
		if paused:
			show()
		else:
			hide()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.switch_to("res://ui/menu/main_menu.tscn")
