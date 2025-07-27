extends Node

const DELAY_BEFORE_KILL_ANNOUNCEMENT = 0.5
var kill_in_one_shot: int = 0
var kill_announcement_timer: SceneTreeTimer

func gun_shoot():
    kill_in_one_shot = 0

func ennemy_died():
    kill_in_one_shot += 1
    kill_announcement_timer = get_tree().create_timer(DELAY_BEFORE_KILL_ANNOUNCEMENT)
    kill_announcement_timer.connect("timeout", _on_kill_announcement_timer_finished)

func _on_kill_announcement_timer_finished():
    if kill_in_one_shot == 2:
        Sounds.double_kill()
    elif kill_in_one_shot == 3:
        Sounds.triple_kill()
    elif kill_in_one_shot > 3:
        Sounds.rampage()
    kill_in_one_shot = 0
