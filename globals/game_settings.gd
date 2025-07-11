extends Node

var enable_music: bool = true
var master_volume_db: float = 0.0
var music_volume_db: float = -15.2
var effects_volume_db: float = 3.4

func apply_audio_settings():
    var master_bus = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(master_bus, master_volume_db)

    var music_bus = AudioServer.get_bus_index("Music")
    if enable_music:
        AudioServer.set_bus_mute(music_bus, false)
        AudioServer.set_bus_volume_db(music_bus, music_volume_db)
    else:
        AudioServer.set_bus_mute(music_bus, true)

    var effects_bus = AudioServer.get_bus_index("Effects")
    AudioServer.set_bus_volume_db(effects_bus, effects_volume_db)
