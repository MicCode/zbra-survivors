extends Node

var sound_resources: Array[Resource] = []

func _ready() -> void:
    # print("Loading sound resources")
    var resources_group: ResourceGroup = load("res://assets/sounds/sounds.tres")
    var resources = resources_group.load_all()
    # for r in resources:
    #     print(r.resource_path)
    sound_resources = resources

## Randomly picks a sound ressource from a given folder, or if parameter is a fully qualified file name returns the corresponding resource path.
## In the case a filename is given this function does nothing particular but it allows the function to be used in any condition, when we dont know
## by advance if the string we have is a folder name or a filename
func pick_random(folder_or_filename: String) -> String:
    var path = "res://assets/sounds/" + folder_or_filename
    var filtered = sound_resources.filter(
        func(r: Resource):
            return (
                r.resource_path == path
                or (
                    r.resource_path.begins_with(path)
                    and r.resource_path.substr(path.length()).begins_with("/")
                )
            )
    )
    if not filtered or filtered.size() == 0:
        push_error("No sound asset found in path [%s]" % path)
        return "click.ogg"

    return filtered.pick_random().resource_path

#region UI
func start_game():
    SoundPlayer.play_sfx("reload.ogg", SfxOptions.from_dict({pitch = 0.7}))

func click():
    SoundPlayer.play_sfx("click.ogg", SfxOptions.from_dict({pitch = 3.5}))

func button_press():
    SoundPlayer.play_sfx(pick_random("button-press"), SfxOptions.from_dict({pitch = 3.5}))

func toggle():
    SoundPlayer.play_sfx("toggle.ogg", SfxOptions.from_dict({pitch = 0.9, volume = -6.0}))
#endregion

#region Player
func player_hit():
    SoundPlayer.play_sfx("ouch.ogg", SfxOptions.from_dict({pitch = 1.7, volume = -7.0}))

func player_die():
    SoundPlayer.play_sfx("die.ogg", SfxOptions.from_dict({pitch = 1.4}))

func dash():
    SoundPlayer.play_sfx(pick_random("dash"), SfxOptions.from_dict({volume = -3.0}))

func dash_ready():
    SoundPlayer.play_sfx("dash-ready.ogg", SfxOptions.from_dict({pitch = 1.5, volume = -6.0}))

func level_up():
    SoundPlayer.play_sfx("lvlup.ogg", SfxOptions.from_dict({volume = -16.0}))

func heal():
    SoundPlayer.play_sfx("drink.mp3", SfxOptions.from_dict({volume = 3.0, pitch = 1.5, pitch_variation = 0.1}))

func start_burning():
    SoundPlayer.start_effect("burning.ogg", SfxOptions.from_dict({volume = -0.7, pitch = 2.0}))

func stop_burning():
    SoundPlayer.stop_effect("burning.ogg")

func start_timewarping():
    SoundPlayer.start_effect("clock.ogg", SfxOptions.from_dict({pitch = 10.0})) # high pitch because when timewarping everything goes low

func stop_timewarping():
    SoundPlayer.stop_effect("clock.ogg")

func absorb():
    SoundPlayer.play_sfx("absorb.ogg", SfxOptions.from_dict({volume = -3.0}))

func coin():
    SoundPlayer.play_sfx("coin.ogg", SfxOptions.from_dict({pitch = 1.2, pitch_variation = 0.2, volume = -1.0}))

func chest_open():
    SoundPlayer.play_sfx("chest-open.ogg")

func game_over():
    SoundPlayer.play_sfx("game-over.ogg", SfxOptions.from_dict({volume = -6.0}))
#endregion

#region Equipment
func zap():
    SoundPlayer.play_sfx("zap.ogg", SfxOptions.from_dict({pitch = 0.9, volume = -12.0}))

func shoot(options: SfxOptions, file_name: String = "shoot.ogg"):
    SoundPlayer.play_sfx(pick_random(file_name), options)

func reload():
    SoundPlayer.play_sfx(pick_random("reload"), SfxOptions.from_dict({volume = -3.0}))

func take():
    SoundPlayer.play_sfx(pick_random("object-take"), SfxOptions.from_dict({volume = 3.0}))

func chest_available():
    SoundPlayer.play_sfx("chest.ogg", SfxOptions.from_dict({volume = -6.0}))
#endregion

#region Enemies
func hit():
    SoundPlayer.play_sfx(pick_random("hits"), SfxOptions.from_dict({pitch = 0.9, pitch_variation = 0.1, volume = -12.0}))

func burn_hit():
    SoundPlayer.play_sfx(pick_random("burn"), SfxOptions.from_dict({pitch = 0.8, volume = -6.0}))

func death_mob_1(pitch: float = 3.0):
    SoundPlayer.play_sfx(pick_random("enemy-death-1"), SfxOptions.from_dict({pitch = pitch, pitch_variation = 0.1}))

func shoot_boss_1():
    SoundPlayer.play_sfx("boss_1-shoot.ogg", SfxOptions.from_dict({volume = -5.0}))

func death_boss_1():
    SoundPlayer.play_sfx("boss_death.ogg", SfxOptions.from_dict({pitch = 0.8, volume = -3.0}))
#endregion

#region Environment
func tree_destroyed():
    SoundPlayer.play_sfx("falling-leaves.ogg", SfxOptions.from_dict({volume = -15.0, pitch_variation = 0.1}))

func explosion(volume: float = -9.0):
    SoundPlayer.play_sfx(pick_random("explosions"), SfxOptions.from_dict({volume = volume}))

func drop():
    SoundPlayer.play_sfx(pick_random("drops"), SfxOptions.from_dict({volume = -3.0}))
#endregion
