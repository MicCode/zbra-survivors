extends Node

const DELAY_BEFORE_KILL_ANNOUNCEMENT = 0.5
const SCREEN_STICKERS_PADDING = 100

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
        double_kill()
    elif kill_in_one_shot == 3:
        triple_kill()
    elif kill_in_one_shot > 3:
        rampage()
    kill_in_one_shot = 0

func draw_announcement_sticker(text: String, size: int):
    var sticker = preload("res://ui/in-game/annoucement_sticker.tscn").instantiate()
    sticker.set_text(text)
    sticker.set_size(size)
    if GameState.player_instance != null:
        sticker.global_position = GameState.player_instance.global_position
    else:
        var screen_size = get_window().get_size()
        sticker.global_position = Vector2(
            randi_range(SCREEN_STICKERS_PADDING, screen_size.x - (SCREEN_STICKERS_PADDING * 2)),
            randi_range(floor(float(SCREEN_STICKERS_PADDING) / 2), screen_size.y - SCREEN_STICKERS_PADDING),
        )
    get_tree().root.add_child(sticker)

func double_kill():
    Sounds.double_kill()
    draw_announcement_sticker(tr("LABEL_ANNOUNCEMENT_DOUBLE_KILL"), 50)

func triple_kill():
    Sounds.triple_kill()
    draw_announcement_sticker(tr("LABEL_ANNOUNCEMENT_TRIPLE_KILL"), 65)

func rampage():
    Sounds.rampage()
    draw_announcement_sticker(tr("LABEL_ANNOUNCEMENT_RAMPAGE"), 90)
