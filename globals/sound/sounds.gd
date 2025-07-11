extends Node

#region UI
func start_game():
    SoundPlayer.play_sfx("reload.wav", {pitch = 0.7})

func click():
    SoundPlayer.play_sfx("hit.wav", {pitch = 3.5})
#endregion

#region Player
func player_hit():
    SoundPlayer.play_sfx("ouch.wav", {pitch = 1.7, volume = -7.0})

func player_die():
    SoundPlayer.play_sfx("die.wav", {pitch = 1.4})

func dash():
    SoundPlayer.play_sfx("lazercannon.mp3", {pitch = 2.0, volume = -16.0})

func dash_ready():
    SoundPlayer.play_sfx("beep.mp3", {pitch = 2.8, volume = -24.0})

func level_up():
    SoundPlayer.play_sfx("lvlup.wav", {volume = -16.0})

func heal():
    SoundPlayer.play_sfx("drink.mp3", {volume = 3.0, pitch = 1.5, pitch_variation = 0.1})

func start_burning():
    SoundPlayer.start_effect("burning.wav", {volume = -0.7, pitch = 2.0})

func stop_burning():
    SoundPlayer.stop_effect("burning.wav")
#endregion

#region Equipment
func zap():
    SoundPlayer.play_sfx("zap.wav", {pitch = 0.9, volume = -12.0})

func shoot(volume: float = 0.0, pitch_shift: float = 0.0):
    SoundPlayer.play_sfx("shoot.wav", {volume = volume, pitch_variation = 0.1, pitch = max(0.0, 1.0 + pitch_shift)})
#endregion

#region Ennemies
func hit():
    SoundPlayer.play_sfx("hit2.wav", {pitch = 0.65, pitch_variation = 0.5, volume = 12.5})

func death_mob_1():
    SoundPlayer.play_sfx("meow.mp3", {pitch = 0.8, pitch_variation = 0.1, volume = 15.0})

func death_boss_1():
    SoundPlayer.play_sfx("boss_death.wav", {pitch = 0.8})
#endregion

#region Environment
func tree_destroyed():
    SoundPlayer.play_sfx("falling-leaves.wav", {volume = -6.0})
#endregion
