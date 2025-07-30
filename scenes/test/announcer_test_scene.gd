extends CanvasLayer


func _on_double_kill_pressed() -> void:
    Announcer.double_kill()

func _on_triple_kill_pressed() -> void:
    Announcer.triple_kill()

func _on_rampage_pressed() -> void:
    Announcer.rampage()
