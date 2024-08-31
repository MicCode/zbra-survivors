extends CanvasLayer

var paused = false

func _input(event):
	if event.is_action_pressed("pause_game") && !GameState.is_game_over:
		paused = !paused
		get_tree().paused = paused
		if paused:
			show()
		else:
			hide()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneSwitcher.switch_to("res://ui/main_menu.tscn")
