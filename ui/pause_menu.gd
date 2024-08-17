extends CanvasLayer

var paused = false

func _input(event):
	if event.is_action_pressed("pause_game"):
		paused = !paused
		get_tree().paused = paused
		if paused:
			show()
		else:
			hide()
