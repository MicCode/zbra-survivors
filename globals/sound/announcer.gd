extends Node

const DELAY_BEFORE_KILL_ANNOUNCEMENT = 0.5
const SCREEN_STICKERS_PADDING: float = 100.0

var kill_in_one_shot: int = 0
var kill_announcement_timer: SceneTreeTimer

var announcer_player: AudioStreamPlayer

#region announcements ---------------------------------------------------------------------------------------
func gun_shoot():
    kill_in_one_shot = 0

func double_kill():
    _announce("double_kill.ogg")
    _draw_announcement_sticker(tr("LABEL_ANNOUNCEMENT_DOUBLE_KILL"), 50)

func triple_kill():
    _announce("triple_kill.ogg")
    _draw_announcement_sticker(tr("LABEL_ANNOUNCEMENT_TRIPLE_KILL"), 65)

func rampage():
    _announce("rampage.ogg")
    _draw_announcement_sticker(tr("LABEL_ANNOUNCEMENT_RAMPAGE"), 90)
#endregion

#region internal ---------------------------------------------------------------------------------------
func ennemy_died():
    kill_in_one_shot += 1
    kill_announcement_timer = get_tree().create_timer(DELAY_BEFORE_KILL_ANNOUNCEMENT)
    kill_announcement_timer.connect("timeout", func():
        if kill_in_one_shot == 2:
            double_kill()
        elif kill_in_one_shot == 3:
            triple_kill()
        elif kill_in_one_shot > 3:
            rampage()
        kill_in_one_shot = 0
    )

func _announce(file_name: String, options: SfxOptions = SfxOptions.new()):
    var stream = SoundPlayer.load_sfx_stream("announcements/" + file_name)
    if stream == null:
        return
    if announcer_player != null and announcer_player.playing:
        announcer_player.stop()
    announcer_player = await SoundPlayer.play_sound(stream, SoundPlayer.Bus.ANNOUNCEMENTS, options)

func _draw_announcement_sticker(text: String, size: int):
    if !Settings.game_settings.display_announcement_stickers:
        return

    var sticker = preload("res://ui/in-game/components/annoucement_sticker.tscn").instantiate()
    sticker.set_text(text)
    sticker.set_size(size)
    if PlayerService.player_instance != null:
        sticker.global_position = PlayerService.player_instance.global_position
    else:
        var screen_size = get_window().get_size()
        sticker.global_position = Vector2(
            randf_range(SCREEN_STICKERS_PADDING, screen_size.x - SCREEN_STICKERS_PADDING * 2),
            randf_range(SCREEN_STICKERS_PADDING / 2, screen_size.y - SCREEN_STICKERS_PADDING),
        )
    SceneManager.current_scene.add_child(sticker)
#endregion
