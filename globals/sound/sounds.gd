extends Node

#region UI
func start_game():
    SoundPlayer.play_sfx("reload.wav", SfxOptions.from_dict({pitch = 0.7}))

func click():
    SoundPlayer.play_sfx("hit.wav", SfxOptions.from_dict({pitch = 3.5}))
#endregion

#region Player
func player_hit():
    SoundPlayer.play_sfx("ouch.wav", SfxOptions.from_dict({pitch = 1.7, volume = -7.0}))

func player_die():
    SoundPlayer.play_sfx("die.wav", SfxOptions.from_dict({pitch = 1.4}))

func dash():
    SoundPlayer.play_sfx("lazercannon.mp3", SfxOptions.from_dict({pitch = 2.0, volume = -16.0}))

func dash_ready():
    SoundPlayer.play_sfx("beep.mp3", SfxOptions.from_dict({pitch = 2.8, volume = -24.0}))

func level_up():
    SoundPlayer.play_sfx("lvlup.wav", SfxOptions.from_dict({volume = -16.0}))

func heal():
    SoundPlayer.play_sfx("drink.mp3", SfxOptions.from_dict({volume = 3.0, pitch = 1.5, pitch_variation = 0.1}))

func start_burning():
    SoundPlayer.start_effect("burning.wav", SfxOptions.from_dict({volume = -0.7, pitch = 2.0}))

func stop_burning():
    SoundPlayer.stop_effect("burning.wav")

func start_timewarping():
    SoundPlayer.start_effect("clock.wav", SfxOptions.from_dict({pitch = 10.0})) # high pitch because when timewarping everything goes low

func stop_timewarping():
    SoundPlayer.stop_effect("clock.wav")
#endregion

#region Equipment
func zap():
    SoundPlayer.play_sfx("zap.wav", SfxOptions.from_dict({pitch = 0.9, volume = -12.0}))

func shoot(options: SfxOptions, file_name: String = "shoot.wav"):
    SoundPlayer.play_sfx(file_name, options)

func reload():
    SoundPlayer.play_sfx("reload.wav", SfxOptions.from_dict({pitch = 0.9}))
#endregion

#region Ennemies
func hit():
    SoundPlayer.play_sfx("hit2.wav", SfxOptions.from_dict({pitch = 0.65, pitch_variation = 0.5, volume = 12.5}))

func burn_hit():
    SoundPlayer.play_sfx(Files.get_random_from_folder("res://assets/sounds/burn"), SfxOptions.from_dict({pitch = 0.5}))

func death_mob_1():
    SoundPlayer.play_sfx("meow.mp3", SfxOptions.from_dict({pitch = 0.8, pitch_variation = 0.1, volume = 15.0}))

func death_boss_1():
    SoundPlayer.play_sfx("boss_death.wav", SfxOptions.from_dict({pitch = 0.8}))
#endregion

#region Environment
func tree_destroyed():
    SoundPlayer.play_sfx("falling-leaves.wav", SfxOptions.from_dict({volume = -6.0}))
#endregion

#region Announcements
func double_kill():
    SoundPlayer.play_sfx("double_kill.ogg")

func triple_kill():
    SoundPlayer.play_sfx("triple_kill.ogg")

func rampage():
    SoundPlayer.play_sfx("rampage.ogg")
#endregion
